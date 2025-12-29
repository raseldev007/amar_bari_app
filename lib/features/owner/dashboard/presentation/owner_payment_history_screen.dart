import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../features/resident/payments/data/payment_repository.dart';

class OwnerPaymentHistoryScreen extends ConsumerWidget {
  final String residentId;
  final String residentName;

  const OwnerPaymentHistoryScreen({
    super.key, 
    required this.residentId,
    required this.residentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(userPaymentsProvider(residentId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payment History", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
            Text(residentName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text("No payments found for this resident."));
          }

          // List is already sorted by repository
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final payment = payments[index];
              final isConfirmed = payment.status == 'confirmed';
              final isRejected = payment.status == 'rejected';
              
              Color statusColor = Colors.orange;
              IconData statusIcon = Icons.access_time;
              if (isConfirmed) {
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
              } else if (isRejected) {
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
              }

              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(statusIcon, color: statusColor),
                ),
                title: Text('Payment via ${payment.method.toUpperCase()}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('MMM d, yyyy • h:mm a').format(payment.createdAt)),
                    if (payment.providerRef != null && payment.providerRef!.isNotEmpty)
                      Text('Ref: ${payment.providerRef}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('৳${payment.amount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(payment.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
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
