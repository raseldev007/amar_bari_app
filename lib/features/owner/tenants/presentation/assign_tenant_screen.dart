import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/flat_model.dart';
import '../../../../models/lease_model.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/data/user_repository.dart';
import 'package:amar_bari/models/user_model.dart';
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
    final input = _uidController.text.trim();
    if (input.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final ownerUser = ref.read(authRepositoryProvider).currentUser;
      if (ownerUser == null) return;

      // 1. Resolve Resident (Search by Email or ID)
      String residentId = input;
      final userRepo = ref.read(userRepositoryProvider);
      

      
      // Check if user is already assigned
      // We need to fetch the full user object to check assignedFlatId if we only had the ID
      // If we looked up by email, we have the user object.
      // If we looked up by ID, we have the user object.
      UserModel? targetUser;
       if (input.contains('@')) {
        targetUser = await userRepo.getUserByEmail(input);
      } else {
        targetUser = await userRepo.getUser(input);
      }
      
      if (targetUser == null) throw 'User not found';
      residentId = targetUser.uid;

      if (targetUser.assignedFlatId != null && targetUser.assignedFlatId!.isNotEmpty) {
         throw 'This user is already assigned to another flat. A resident can only have one active lease.';
      }

      final leaseRepo = ref.read(leaseRepositoryProvider);
      
      final newLease = LeaseModel(
        id: const Uuid().v4(),
        ownerId: ownerUser.uid,
        propertyId: widget.propertyId,
        flatId: widget.flatId,
        residentId: residentId,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        status: 'active',
      );

      await leaseRepo.createLease(newLease, widget.flat);

      if (mounted) {
        // Pop back to Flat Details
        context.pop(); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resident assigned successfully!')));
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
                labelText: 'Resident Email or User ID (UID)',
                border: OutlineInputBorder(),
                helperText: 'Enter the resident\'s Email or UID to assign them.',
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
