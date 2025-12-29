import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/invoice_model.dart';
import '../../dashboard/data/owner_dashboard_providers.dart';
import '../../invoices/data/invoice_repository.dart';
import '../../flats/data/flat_repository.dart';

class WorkListItem extends ConsumerWidget {
  final InvoiceModel invoice;
  final String? propertyName;

  const WorkListItem({super.key, required this.invoice, this.propertyName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flatAsync = ref.watch(flatDetailsProvider(invoice.flatId));
    final residentAsync = ref.watch(residentProfileProvider(invoice.residentId));

    final isLate = invoice.status == 'late';
    final actuallyLate = invoice.dueDate.isBefore(DateTime.now()) && invoice.status == 'due';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: actuallyLate || isLate ? Border.all(color: Colors.red.withOpacity(0.3)) : null,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          propertyName ?? 'Unknown Property',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flat & Resident Row
            Row(
               children: [
                 if (flatAsync is AsyncData && flatAsync.value != null)
                   Text("Flat ${flatAsync.value!.label}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                 if (flatAsync is AsyncData && flatAsync.value != null)
                   const SizedBox(width: 8),
                 if (residentAsync is AsyncData && residentAsync.value != null)
                   Expanded(child: Text("• ${residentAsync.value!.name}", style: GoogleFonts.inter(fontSize: 13), overflow: TextOverflow.ellipsis)),
                 if (flatAsync.isLoading || residentAsync.isLoading)
                   const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
               ],
            ),
            const SizedBox(height: 4),
            Text("Due: ${DateFormat('MMM d').format(invoice.dueDate)} • ৳${invoice.totalAmount.toStringAsFixed(0)}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: actuallyLate || isLate ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          child: Icon(
            actuallyLate || isLate ? Icons.warning : Icons.schedule,
            color: actuallyLate || isLate ? Colors.red : Colors.orange,
          ),
        ),
        trailing: PopupMenuButton(
          onSelected: (value) async {
            if (value == 'paid') {
              await ref.read(invoiceRepositoryProvider).markAsPaid(invoice.id, invoice.totalAmount);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice marked as Paid')));
              }
            } else if (value == 'remind') {
              await ref.read(invoiceRepositoryProvider).sendReminder(invoice.id, invoice.residentId, invoice.monthKey);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder Sent')));
              }
            } else if (value == 'details') {
              context.push('/owner/property/${invoice.propertyId}/flat/${invoice.flatId}/invoice/${invoice.id}', extra: invoice);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'paid', child: Text('Mark Paid')),
            const PopupMenuItem(value: 'remind', child: Text('Send Reminder')),
            const PopupMenuItem(value: 'details', child: Text('View Details')),
          ],
        ),
      ),
    );
  }
}
