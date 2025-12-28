import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../data/user_repository.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select your role')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome! Please select your account type:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _submitRole('owner'),
                      child: const Text('I am an Owner'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _submitRole('resident'),
                      child: const Text('I am a Resident'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitRole(String role) async {
    setState(() => _isLoading = true);
    
    // Get UID directly from Auth Repository (source of truth for "who is logged in")
    final uid = ref.read(authRepositoryProvider).currentUser?.uid;
    
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not found. Please log in again.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      // 1. Update role in Firestore
      await ref.read(userRepositoryProvider).updateUserRole(uid, role);
      
      print("Role updated to $role for $uid");

      // 2. Explicitly navigate as a fallback/fast-path
      // The router stream usually handles this, but explicit go ensures immediate feedback
      if (mounted) {
         if (role == 'owner') {
           context.go('/owner');
         } else {
           context.go('/resident');
         }
      }
    } catch (e) {
      print("Error setting role: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set role: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
