import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/flat_model.dart';
import '../../../../models/lease_model.dart';
import '../../../auth/data/auth_repository.dart';
import '../../tenants/data/lease_repository.dart';

class AssignTenantScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String flatId;
  final FlatModel flat;

  const AssignTenantScreen({
    super.key,
    required this.propertyId,
    required this.flatId,
    required this.flat,
  });

  @override
  ConsumerState<AssignTenantScreen> createState() => _AssignTenantScreenState();
}

class _AssignTenantScreenState extends ConsumerState<AssignTenantScreen> {
  final _emailController = TextEditingController(); // For MVP searching by email might be hard without index, stick to UID?
  // Master prompt said: "assign resident (manual uid/email for MVP)"
  // Let's use UID for solidity, maybe Email if we can hack it. UID is safest.
  final _uidController = TextEditingController();
  bool _isLoading = false;

  Future<void> _assignTenant() async {
    if (_uidController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final ownerUser = ref.read(authRepositoryProvider).currentUser;
      if (ownerUser == null) return;

      final leaseRepo = ref.read(leaseRepositoryProvider);
      
      final newLease = LeaseModel(
        id: const Uuid().v4(),
        ownerId: ownerUser.uid,
        propertyId: widget.propertyId,
        flatId: widget.flatId,
        residentId: _uidController.text.trim(),
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        status: 'active',
      );

      await leaseRepo.createLease(newLease, widget.flat);

      if (mounted) {
        // Pop back to Flat Details
        context.pop(); 
        // Force refresh of flat details? 
        // The stream provider should auto refresh.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Resident')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'For MVP, please ask the resident for their User ID (visible in their profile). '
              'Future versions will support Email/Phone search.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _uidController,
              decoration: const InputDecoration(
                labelText: 'Resident User ID (UID)',
                border: OutlineInputBorder(),
                helperText: 'Paste the resident\'s UID here',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _assignTenant,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Confirm Assignment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
