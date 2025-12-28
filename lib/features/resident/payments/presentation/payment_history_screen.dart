import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amar_bari/features/auth/data/auth_repository.dart';
import '../../../owner/invoices/data/invoice_repository.dart';
import 'package:amar_bari/core/theme/app_gradients.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final invoicesAsync = ref.watch(residentInvoicesProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(title: const Text("Payment History")),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text("No payment history found."));
          }

          // Sort by date desc (if not already)
          final sorted = List.of(invoices)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final inv = sorted[index];
              final isPaid = inv.status == 'paid';
              
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                leading: CircleAvatar(
                  backgroundColor: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  child: Icon(isPaid ? Icons.check : Icons.history, color: isPaid ? Colors.green : Colors.orange),
                ),
                title: Text(DateFormat('MMMM yyyy').format(DateTime.parse('${inv.monthKey}-01')), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: Text('Due: ${inv.dueDate != null ? DateFormat.yMMMd().format(inv.dueDate!) : "N/A"}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('৳${inv.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(inv.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, color: isPaid ? Colors.green : Colors.orange)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
