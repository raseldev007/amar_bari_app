import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/flat_model.dart';
import '../../../auth/data/auth_repository.dart';
import '../../properties/data/property_repository.dart'; // For owner ID check if needed, mostly redundant if we use auth
import '../data/flat_repository.dart';

class AddEditFlatScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final FlatModel? flat;

  const AddEditFlatScreen({super.key, required this.propertyId, this.flat});

  @override
  ConsumerState<AddEditFlatScreen> createState() => _AddEditFlatScreenState();
}

class _AddEditFlatScreenState extends ConsumerState<AddEditFlatScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _rentController;
  late TextEditingController _dueDayController;
  
  // Utilities
  late TextEditingController _gasController;
  late TextEditingController _waterController;
  late TextEditingController _electricityController;
  late TextEditingController _serviceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final f = widget.flat;
    _labelController = TextEditingController(text: f?.label ?? '');
    _rentController = TextEditingController(text: f?.rentBase.toString() ?? '0');
    _dueDayController = TextEditingController(text: f?.dueDay.toString() ?? '5');
    
    _gasController = TextEditingController(text: f?.utilities['gas']?.toString() ?? '0');
    _waterController = TextEditingController(text: f?.utilities['water']?.toString() ?? '0');
    _electricityController = TextEditingController(text: f?.utilities['electricity']?.toString() ?? '0');
    _serviceController = TextEditingController(text: f?.utilities['service']?.toString() ?? '0');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _rentController.dispose();
    _dueDayController.dispose();
    _gasController.dispose();
    _waterController.dispose();
    _electricityController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  Future<void> _saveFlat() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      final repo = ref.read(flatRepositoryProvider);
      final utilities = {
        'gas': double.parse(_gasController.text),
        'water': double.parse(_waterController.text),
        'electricity': double.parse(_electricityController.text),
        'service': double.parse(_serviceController.text),
      };

      if (widget.flat == null) {
        // Add
        final newFlat = FlatModel(
          id: const Uuid().v4(),
          propertyId: widget.propertyId,
          ownerId: user.uid,
          label: _labelController.text.trim(),
          rentBase: double.parse(_rentController.text),
          dueDay: int.parse(_dueDayController.text),
          utilities: utilities,
          createdAt: DateTime.now(),
          status: 'vacant',
        );
        await repo.addFlat(newFlat);
      } else {
        // Edit
        final updatedFlat = widget.flat!.copyWith(
          label: _labelController.text.trim(),
          rentBase: double.parse(_rentController.text),
          dueDay: int.parse(_dueDayController.text),
          utilities: utilities,
        );
        await repo.updateFlat(updatedFlat);
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
    final isEditing = widget.flat != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Flat' : 'Add Flat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Flat Label (e.g. 4A)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rent Base', border: OutlineInputBorder(), prefixText: '৳'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dueDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Due Day (1-28)', border: OutlineInputBorder()),
                      validator: (v) {
                         if (v!.isEmpty) return 'Required';
                         final n = int.tryParse(v);
                         if (n == null || n < 1 || n > 28) return '1-28';
                         return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Fixed Utilities (Add to Rent)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildUtilityField('Gas', _gasController),
              _buildUtilityField('Water', _waterController),
              _buildUtilityField('Electricity (Avg/Fixed)', _electricityController),
              _buildUtilityField('Service Charge', _serviceController),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                   onPressed: _isLoading ? null : _saveFlat,
                   child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEditing ? 'Update Flat' : 'Save Flat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label, 
          border: const OutlineInputBorder(),
          prefixText: '৳',
        ),
        validator: (v) => v!.isEmpty ? 'Required (0 if none)' : null,
      ),
    );
  }
}
