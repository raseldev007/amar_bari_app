import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/invoice_model.dart';
import '../../../owner/dashboard/data/owner_dashboard_providers.dart';
import '../../invoices/data/invoice_repository.dart';
import '../../flats/data/flat_repository.dart';
import '../../tenants/data/lease_repository.dart';

class OwnerInvoiceListScreen extends StatelessWidget {
  final String title;
  final List<InvoiceModel> invoices;

  const OwnerInvoiceListScreen({
    super.key, 
    required this.title, 
    required this.invoices
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: invoices.isEmpty 
          ? Center(child: Text("No filtered invoices found.", style: GoogleFonts.inter(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                return _InvoiceListItem(invoice: invoices[index]);
              },
            ),
    );
  }
}

class _InvoiceListItem extends ConsumerWidget {
  final InvoiceModel invoice;

  const _InvoiceListItem({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flatAsync = ref.watch(flatDetailsProvider(invoice.flatId));
    final residentAsync = ref.watch(residentProfileProvider(invoice.residentId));
    final propertyAsync = ref.watch(propertyByIdProvider(invoice.propertyId));

    final isPaid = invoice.status == 'paid';
    final isLate = invoice.status == 'late' || (invoice.status == 'due' && invoice.dueDate.isBefore(DateTime.now()));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isLate && !isPaid ? Border.all(color: Colors.red.withOpacity(0.3)) : null,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isPaid 
              ? Colors.green.withOpacity(0.1) 
              : (isLate ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
          child: Icon(
            isPaid ? Icons.check : (isLate ? Icons.warning : Icons.schedule),
            color: isPaid ? Colors.green : (isLate ? Colors.red : Colors.orange),
            size: 20,
          ),
        ),
        title: propertyAsync.when(
          data: (prop) => Text(prop?.name ?? 'Unknown Property', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          loading: () => const SizedBox(height: 10, width: 50, child: LinearProgressIndicator()),
          error: (_,__) => const Text('Error'),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               children: [
                 if (flatAsync is AsyncData && flatAsync.value != null)
                   Text("Flat ${flatAsync.value!.label}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                 if (flatAsync is AsyncData && flatAsync.value != null)
                   const SizedBox(width: 8),
                 if (residentAsync is AsyncData && residentAsync.value != null)
                   Expanded(child: Text("• ${residentAsync.value!.name}", style: GoogleFonts.inter(fontSize: 13), overflow: TextOverflow.ellipsis)),
               ],
             ),
             const SizedBox(height: 4),
             Text(
               "${isPaid ? 'Paid' : 'Due'}: ${DateFormat('MMM d').format(invoice.dueDate)} • ৳${invoice.totalAmount.toStringAsFixed(0)}", 
               style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])
             ),
          ],
        ),
        trailing: isPaid 
            ? null 
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'details') {
                    context.push('/owner/property/${invoice.propertyId}/flat/${invoice.flatId}/invoice/${invoice.id}', extra: invoice);
                  } else if (value == 'unassign') {
                    _showUnassignDialog(context, ref, invoice);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'details', child: Text('View Details')),
                  const PopupMenuItem(
                    value: 'unassign', 
                    child: Text('Unassign / End Lease', style: TextStyle(color: Colors.red)),
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
        onTap: () {
           // Navigate to detail
           context.push('/owner/property/${invoice.propertyId}/flat/${invoice.flatId}/invoice/${invoice.id}', extra: invoice);
        },
      ),
    );
  }

  void _showUnassignDialog(BuildContext context, WidgetRef ref, InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Lease (Unassign)?'),
        content: const Text('This will remove the resident from the flat and mark it as Vacant. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                // We use the leaseId from the invoice
                await ref.read(leaseRepositoryProvider).endLease(invoice.leaseId, invoice.flatId, invoice.residentId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resident Unassigned & Lease Ended.')));
                  // Ideally we should refresh the list. 
                  // Since the list depends entirely on 'invoices' passed from previous screen, 
                  // we can't easily remove it from 'this' list without converting to Stateful.
                  // But the global providers will update.
                  // Letting the user navigate back is usually fine, or we can pop.
                  Navigator.pop(context); // Go back to dashboard to refresh
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Confirm End Lease'),
          ),
        ],
      ),
    );
  }
}
