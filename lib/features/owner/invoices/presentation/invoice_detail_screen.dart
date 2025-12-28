import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/invoice_model.dart';
import '../../../resident/payments/data/payment_repository.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final InvoiceModel invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(invoicePaymentsProvider(invoice.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(invoice),
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
}
