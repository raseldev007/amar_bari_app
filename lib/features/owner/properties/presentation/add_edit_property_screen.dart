import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/property_model.dart';
import '../../../auth/data/auth_repository.dart';
import '../data/property_repository.dart';

class AddEditPropertyScreen extends ConsumerStatefulWidget {
  final PropertyModel? property; // If null, add mode. If set, edit mode.

  const AddEditPropertyScreen({super.key, this.property});

  @override
  ConsumerState<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends ConsumerState<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property?.name ?? '');
    _addressController = TextEditingController(text: widget.property?.address ?? '');
    _cityController = TextEditingController(text: widget.property?.city ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      final repo = ref.read(propertyRepositoryProvider);
      
      if (widget.property == null) {
        // Add
        final newProperty = PropertyModel(
            id: const Uuid().v4(),
            ownerId: user.uid,
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            createdAt: DateTime.now()
        );
        await repo.addProperty(newProperty);
      } else {
        // Edit
        final updatedProperty = widget.property!.copyWith(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
        );
        await repo.updateProperty(updatedProperty);
      }

      if (mounted) context.pop();
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
    final isEditing = widget.property != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Property' : 'Add Property')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Property Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                 validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProperty,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(isEditing ? 'Update Property' : 'Create Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
