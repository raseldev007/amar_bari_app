import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amar_bari/features/auth/data/auth_repository.dart';
import 'package:amar_bari/features/auth/data/user_repository.dart';

class ResidentProfileScreen extends ConsumerStatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  ConsumerState<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends ConsumerState<ResidentProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isEditing = false; // Initially view mode, but we can make it always editable or toggle. 
                           // "Profile" usually implies editable fields. Let's make fields editable directly but separate 'Save' button.

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Current User Data
    final authUser = ref.watch(authRepositoryProvider).currentUser;
    final userProfileAsync = ref.watch(userProfileProvider(authUser?.uid ?? ''));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
               ref.read(authRepositoryProvider).signOut();
               // Navigation handled by router redirect
            },
          )
        ],
      ),
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (userModel) {
          if (userModel == null) return const Center(child: Text('User not found'));

          // Initialize controllers if empty (first load)
          if (_nameController.text.isEmpty && !_isEditing) { // Simple check to avoid overwrite while typing if stream updates
             _nameController.text = userModel.name ?? '';
             _phoneController.text = userModel.phoneNumber ?? '';
             _isEditing = true; // Mark as initialized
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: userModel.photoUrl != null && userModel.photoUrl!.isNotEmpty
                              ? NetworkImage(userModel.photoUrl!)
                              : null,
                          child: userModel.photoUrl == null || userModel.photoUrl!.isEmpty
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => _pickAndUploadPhoto(userModel.uid),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6A11CB), // Consistent Purple
                                shape: BoxShape.circle,
                              ),
                              child: _isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Fields
                  _buildTextField("Full Name", _nameController, Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildTextField("Phone Number", _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildReadOnlyField("Email Address", userModel.email, Icons.email_outlined),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _saveProfile(userModel),
                      style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF6A11CB),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                         elevation: 2,
                      ),
                      child: Text('Save Changes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
         const SizedBox(height: 8),
         Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
           decoration: BoxDecoration(
             color: Colors.grey[100],
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.grey[300]!),
           ),
           child: Row(
             children: [
               Icon(icon, color: Colors.grey[600]),
               const SizedBox(width: 12),
               Text(value, style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[800])),
               const Spacer(),
               Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
             ],
           ),
         )
      ],
    );
  }

  Future<void> _pickAndUploadPhoto(String uid) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image == null) return;
    
    setState(() => _isLoading = true);
    try {
       // Upload using Repository
       final url = await ref.read(userRepositoryProvider).uploadProfilePhoto(uid, image);
       
       // Update User Model in Firestore
       final currentUser = ref.read(userProfileProvider(uid)).value;
       if (currentUser != null) {
         final updatedUser = currentUser.copyWith(photoUrl: url);
         await ref.read(userRepositoryProvider).updateUser(updatedUser);
       }
       
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated!')));
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
       setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile(dynamic userModel) async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final updatedUser = userModel.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      
      await ref.read(userRepositoryProvider).updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      // Optional: pop if we want, or stay. Staying is fine for a profile screen.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }
}
