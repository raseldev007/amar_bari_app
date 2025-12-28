import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../models/invoice_model.dart';
import '../../../../models/payment_model.dart';
import '../../../auth/data/auth_repository.dart';
import '../data/payment_repository.dart';

class SubmitPaymentScreen extends ConsumerStatefulWidget {
  final InvoiceModel invoice;

  const SubmitPaymentScreen({super.key, required this.invoice});

  @override
  ConsumerState<SubmitPaymentScreen> createState() => _SubmitPaymentScreenState();
}

class _SubmitPaymentScreenState extends ConsumerState<SubmitPaymentScreen> {
  final _amountController = TextEditingController();
  final _refController = TextEditingController(); // For Transaction ID
  String _selectedMethod = 'bkash';
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.invoice.totalAmount.toString();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
       final user = ref.read(authRepositoryProvider).currentUser;
       final repo = ref.read(paymentRepositoryProvider);
       final storage = ref.read(storageServiceProvider);

       String? attachmentUrl;
       if (_selectedImage != null) {
         final path = 'payments/${widget.invoice.id}/${const Uuid().v4()}.jpg';
         attachmentUrl = await storage.uploadImage(_selectedImage!, path);
       }

       final newPayment = PaymentModel(
         id: const Uuid().v4(),
         ownerId: widget.invoice.ownerId,
         residentId: user!.uid,
         invoiceId: widget.invoice.id,
         amount: double.parse(_amountController.text),
         method: _selectedMethod,
         providerRef: _refController.text.trim(),
         attachmentUrl: attachmentUrl,
         status: 'submitted',
         createdAt: DateTime.now(),
       );

       await repo.submitPayment(newPayment);
       
       // Trigger Notification
       ref.read(notificationServiceProvider).showNotification(
         id: 1, 
         title: 'Payment Submitted', 
         body: 'Your payment of ৳${newPayment.amount} has been submitted for review.'
       );

       if (mounted) {
         context.pop();
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Submitted')));
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
      appBar: AppBar(title: const Text('Submit Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Invoice Amount: ৳${widget.invoice.totalAmount}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'bkash', child: Text('bKash')),
                  DropdownMenuItem(value: 'nagad', child: Text('Nagad')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                ],
                onChanged: (v) => setState(() => _selectedMethod = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _refController,
                decoration: const InputDecoration(
                  labelText: 'Transaction ID / Reference', 
                  border: OutlineInputBorder(),
                  helperText: 'e.g. 9H7G...',
                ),
              ),
              const SizedBox(height: 16),
               TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount Paid', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: Text(_selectedImage == null ? 'No Screenshot Selected' : 'Screenshot Selected')),
                   TextButton.icon(
                     onPressed: _pickImage, 
                     icon: const Icon(Icons.attach_file), 
                     label: const Text('Attach Screenshot'),
                   )
                ],
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.file(_selectedImage!, height: 150),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Payment'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
