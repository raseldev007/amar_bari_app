import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/invoice_model.dart';
import '../../../resident/payments/data/payment_repository.dart';
import '../../dashboard/data/owner_dashboard_providers.dart';
import '../data/invoice_repository.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final InvoiceModel invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(invoicePaymentsProvider(invoice.id));
    final residentAsync = ref.watch(residentProfileProvider(invoice.residentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(invoice),
            const SizedBox(height: 16),
            
            // Notify & Message Actions
            residentAsync.when(
              data: (resident) {
                if (resident == null) return const SizedBox.shrink();
                return _buildOwnerActions(context, ref, resident);
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            
            const SizedBox(height: 16),
            const Text('Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...invoice.items.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(e.key), Text('৳${e.amount}')],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('৳${invoice.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            paymentsAsync.when(
              data: (payments) {
                if (payments.isEmpty) return const Text('No payments recorded.');
                return Column(
                  children: payments.map((payment) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          payment.status == 'confirmed' ? Icons.check_circle : Icons.pending,
                          color: payment.status == 'confirmed' ? Colors.green : Colors.orange,
                        ),
                        title: Text('৳${payment.amount} via ${payment.method.toUpperCase()}'),
                        subtitle: Text('Ref: ${payment.providerRef}\n${DateFormat.yMMMd().format(payment.createdAt)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (payment.attachmentUrl != null)
                              IconButton(
                                icon: const Icon(Icons.attachment),
                                onPressed: () {
                                  // In a real app, open URL or show dialog
                                  // For MVP, just show snackbar or basic dialog
                                  showDialog(context: context, builder: (c) => Dialog(child: Image.network(payment.attachmentUrl!)));
                                },
                              ),
                            payment.status == 'submitted' 
                              ? FilledButton.tonal(
                                  onPressed: () async {
                                    await ref.read(paymentRepositoryProvider).confirmPayment(payment.id, invoice.id);
                                  },
                                  child: const Text('Confirm'),
                                )
                              : const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(InvoiceModel inv) {
    Color color = Colors.grey;
    if (inv.status == 'paid') color = Colors.green;
    if (inv.status == 'due') color = Colors.orange;
    if (inv.status == 'late') color = Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('Status: ${inv.status.toUpperCase()}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text('Due Date: ${DateFormat.yMMMd().format(inv.dueDate)}'),
        ],
      ),
    );
  }
  Widget _buildOwnerActions(BuildContext context, WidgetRef ref, dynamic resident) {
     final canNotify = invoice.status == 'due' || invoice.status == 'late';
     
     return Card(
       color: Colors.blue.shade50,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Column(
           children: [
             Row(
               children: [
                 const Icon(Icons.admin_panel_settings, color: Colors.blue),
                 const SizedBox(width: 8),
                 const Text('Owner Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               ],
             ),
             const SizedBox(height: 12),
             Row(
               children: [
                 Expanded(
                   child: ElevatedButton.icon(
                     onPressed: canNotify ? () async {
                       try {
                         await ref.read(invoiceRepositoryProvider).sendReminder(invoice.id, invoice.residentId, invoice.monthKey);
                         if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder sent successfully!')));
                         }
                       } catch (e) {
                         if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                         }
                       }
                     } : null,
                     icon: const Icon(Icons.notifications_active, size: 18),
                     label: const Text('Notify User'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.orange,
                       foregroundColor: Colors.white,
                     ),
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: ElevatedButton.icon(
                     onPressed: () async {
                       final phone = resident.phoneNumber;
                       if (phone != null && phone.isNotEmpty) {
                         final uri = Uri.parse('sms:$phone');
                         if (await canLaunchUrl(uri)) {
                           await launchUrl(uri);
                         } else {
                           if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch SMS')));
                         }
                       } else {
                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No phone number available')));
                       }
                     },
                     icon: const Icon(Icons.message, size: 18),
                     label: const Text('Message'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue,
                       foregroundColor: Colors.white,
                     ),
                   ),
                 ),
               ],
             ),
             if (invoice.lastReminderAt != null)
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: Text(
                   'Last reminder: ${DateFormat.yMd().add_jm().format(invoice.lastReminderAt!)}',
                   style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                 ),
               ),
           ],
         ),
       ),
     );
  }
}
