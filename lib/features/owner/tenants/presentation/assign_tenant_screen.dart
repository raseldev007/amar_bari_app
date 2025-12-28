import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/flat_model.dart';
import '../../../../models/lease_model.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/data/user_repository.dart';
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
      
      if (input.contains('@')) {
        // Assume email
        final user = await userRepo.getUserByEmail(input);
        if (user == null) {
          throw 'User with email $input not found.';
        }
        residentId = user.uid;
      } else {
        // Assume UID
        final user = await userRepo.getUser(input);
        if (user == null) {
          throw 'User with ID $input not found.';
        }
        residentId = user.uid;
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
