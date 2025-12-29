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
  final InvoiceModel? invoice;
  final String? ownerId; // Required if invoice is null

  const SubmitPaymentScreen({super.key, this.invoice, this.ownerId});

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
    if (widget.invoice != null) {
      _amountController.text = widget.invoice!.totalAmount.toString();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    setState(() => _isLoading = true);
    try {
       final user = ref.read(authRepositoryProvider).currentUser;
       final repo = ref.read(paymentRepositoryProvider);
       final storage = ref.read(storageServiceProvider);

       // Determine IDs
       final targetOwnerId = widget.invoice?.ownerId ?? widget.ownerId;
       final targetInvoiceId = widget.invoice?.id ?? 'ADVANCE';

       if (targetOwnerId == null) {
         throw 'Owner ID is missing';
       }

       String? attachmentUrl;
       if (_selectedImage != null) {
         final path = 'payments/$targetInvoiceId/${const Uuid().v4()}.jpg';
         attachmentUrl = await storage.uploadImage(_selectedImage!, path);
       }

       final newPayment = PaymentModel(
         id: const Uuid().v4(),
         ownerId: targetOwnerId,
         residentId: user!.uid,
         invoiceId: targetInvoiceId,
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
    final isAdvance = widget.invoice == null;

    return Scaffold(
      appBar: AppBar(title: Text(isAdvance ? 'Pay Advance' : 'Submit Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isAdvance) ...[
                Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bill Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        ...widget.invoice!.items.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontSize: 14)),
                              Text('৳${e.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              '৳${widget.invoice!.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                 const Text('Advance Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'bkash', child: Text('bKash')),
                  DropdownMenuItem(value: 'rocket', child: Text('Rocket')),
                  DropdownMenuItem(value: 'nagad', child: Text('Nagad')),
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
                decoration: const InputDecoration(labelText: 'Amount Paid', border: OutlineInputBorder(), prefixText: '৳ '),
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
