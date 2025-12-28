import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amar_bari/features/auth/data/auth_repository.dart';
import 'package:amar_bari/core/theme/app_gradients.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../data/document_repository.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nidController = TextEditingController();
  bool _isLoading = false;
  String? _localNidFrontUrl;
  String? _localPhotoUrl;

  @override
  void dispose() {
    _nidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final docsAsync = ref.watch(residentDocumentsProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: Text('My Documents', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: docsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (existingDocs) {
          if (existingDocs != null) {
            if (_nidController.text.isEmpty) _nidController.text = existingDocs.nidNumber ?? '';
            _localNidFrontUrl ??= existingDocs.nidFrontUrl;
            _localPhotoUrl ??= existingDocs.photoUrl;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('${existingDocs?.status.toUpperCase() ?? "PENDING"} VERIFICATION', 
                       existingDocs?.status == 'verified' ? Colors.green : Colors.orange),
                  const SizedBox(height: 24),
                  
                  Text("NID Number", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nidController,
                    decoration: InputDecoration(
                      hintText: 'Enter National ID Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  Text("Attachments", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  
                  _buildUploadPlaceholder("NID Front Photo", _localNidFrontUrl != null, 'nid_front', user?.uid),
                  const SizedBox(height: 12),
                  _buildUploadPlaceholder("Passport Size Photo", _localPhotoUrl != null, 'passport_photo', user?.uid),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _save(user?.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A11CB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text('Save Documents', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: color),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder(String label, bool uploaded, String docType, String? uid) {
    return InkWell(
      onTap: () => _pickAndUpload(uid!, docType),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: uploaded ? Colors.green : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(uploaded ? Icons.check_circle : Icons.cloud_upload_outlined, 
                 color: uploaded ? Colors.green : Colors.grey),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.inter(color: Colors.black87)),
            const Spacer(),
            if (_isLoading)
               const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else if (!uploaded)
               Text("Tap to upload", style: GoogleFonts.inter(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500))
            else 
               Text("Uploaded", style: GoogleFonts.inter(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(String uid, String docType) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Upload to Storage
      // Pass XFile directly to repository to handle web/mobile differences
      final url = await ref.read(documentRepositoryProvider).uploadDocument(uid, docType, image);

      if (docType == 'nid_front') {
        _localNidFrontUrl = url;
      } else {
        _localPhotoUrl = url;
      }
      
      await FirebaseFirestore.instance.collection('tenant_profiles').doc(uid).set(
        {
          if (docType == 'nid_front') 'nidFrontUrl': url else 'photoUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // 3. Refresh Provider to update UI "Uploaded" status
      ref.invalidate(residentDocumentsProvider(uid));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload Successful!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save(String? uid) async {
    if (uid == null) return;
    if (!_formKey.currentState!.validate()) return;

    if (_localNidFrontUrl == null || _localPhotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload both photos first.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doc = ResidentDocumentModel(
        nidNumber: _nidController.text.trim(),
        nidFrontUrl: _localNidFrontUrl,
        photoUrl: _localPhotoUrl,
        status: 'pending',
      );

      await ref.read(documentRepositoryProvider).saveDocuments(uid, doc);
      ref.invalidate(residentDocumentsProvider(uid));
      
      // Notify Owner (Optional but recommended)
      // Logic: Fetch flat -> property -> ownerId -> create notification.
      // Skipping for strict MVP simplicity unless requested, focusing on saving data correctly.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documents Submitted for Verification!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

