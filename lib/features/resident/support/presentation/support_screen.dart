import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amar_bari/features/auth/data/auth_repository.dart';
import 'package:amar_bari/models/request_model.dart';
import 'package:uuid/uuid.dart';
import '../../home/data/resident_repository.dart';
import '../../requests/data/request_repository.dart';
import '../../../auth/data/user_repository.dart';

class SupportScreen extends ConsumerStatefulWidget {
  final String requestType; // 'support' or 'service'
  const SupportScreen({super.key, this.requestType = 'support'});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.requestType == 'service' ? 'Service Request' : 'Support'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.requestType == 'service' ? "Request Maintenance" : "How can we help you?",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.requestType == 'service' 
                   ? "Describe the issue clearly (e.g. leaking tap in kitchen)." 
                   : "Send a message to your property owner or admin.",
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(widget.requestType == 'service' ? Icons.build : Icons.short_text),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: const Icon(Icons.send),
                  label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Request'),
                   style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A11CB),
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    // Get dashboard data to link to owner/property
    final dashboardDataAsync = ref.read(residentDashboardDataProvider(user.uid));
    final data = dashboardDataAsync.asData?.value;

    setState(() => _isLoading = true);

    try {
      var ownerId = data?.property?.ownerId;
      var propertyId = data?.property?.id;
      final flatId = data?.flat?.id;
      
      if (ownerId == null) {
        // Fallback: If not linked to a property, try to find the "main" owner (e.g. for general inquiries/requests)
        // This assumes single-owner or admin scenario primarily, or user wants to contact ANY owner.
        // For MVP/Demo: Fetch the first user with role 'owner'.
        final userRepo = ref.read(userRepositoryProvider);
        final defaultOwner = await userRepo.getFirstOwner();
        
        if (defaultOwner != null) {
          ownerId = defaultOwner.uid;
          // Leave propertyId/flatId null
        } else {
           throw 'Cannot find property owner. Please ensure an owner exists in the system.';
        }
      }

      final request = RequestModel(
        id: const Uuid().v4(),
        type: widget.requestType,
        tenantId: user.uid,
        ownerId: ownerId,
        propertyId: propertyId,
        flatId: flatId,
        title: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
        status: 'open',
      );

      await ref.read(requestRepositoryProvider).createRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message Sent Successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
