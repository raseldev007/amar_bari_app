import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../models/invoice_model.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../invoices/data/invoice_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../resident/requests/data/request_repository.dart';
import '../../../../models/request_model.dart';

class OwnerOverviewScreen extends ConsumerStatefulWidget {
  const OwnerOverviewScreen({super.key});

  @override
  ConsumerState<OwnerOverviewScreen> createState() => _OwnerOverviewScreenState();
}

class _OwnerOverviewScreenState extends ConsumerState<OwnerOverviewScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final String currentMonthKey = DateFormat('yyyy-MM').format(_selectedDate);
    final invoicesAsync = ref.watch(ownerInvoicesProvider(user?.uid ?? ''));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Overview', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black54),
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: invoicesAsync.when(
        data: (allInvoices) {
          // Client-side filtering for MVP
          final invoices = allInvoices.where((i) => i.monthKey == currentMonthKey).toList();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelector(),
                const SizedBox(height: 20),
                _buildKPIs(invoices),
                const SizedBox(height: 20),
                _buildActionBar(context, user?.uid, currentMonthKey, invoices),
                const SizedBox(height: 30),
                Text("Today's Work", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildWorkList(allInvoices), // Pass ALL invoices to see overdue from past months too
                const SizedBox(height: 30),
                Text("Resident Messages", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildMessagesList(user?.uid),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1)),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_selectedDate),
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1)),
        ),
      ],
    );
  }

  Widget _buildKPIs(List<InvoiceModel> invoices) {
    double due = 0;
    double collected = 0;
    int overdueCount = 0;

    for (var inv in invoices) {
      if (inv.status == 'paid') collected += inv.totalAmount;
      if (inv.status == 'due' || inv.status == 'late') due += inv.totalAmount;
      if (inv.status == 'late') overdueCount++;
    }

    return Row(
      children: [
        _kpiCard("Total Due", "৳${due.toStringAsFixed(0)}", AppGradients.due, Icons.pending_actions),
        const SizedBox(width: 12),
        _kpiCard("Collected", "৳${collected.toStringAsFixed(0)}", AppGradients.paid, Icons.check_circle_outline),
        // const SizedBox(width: 12),
        // _kpiCard("Overdue", "$overdueCount", AppGradients.primary, Icons.warning_amber_rounded),
      ],
    );
  }

  Widget _kpiCard(String title, String value, LinearGradient gradient, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, String? ownerId, String monthKey, List<InvoiceModel> currentInvoices) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              if (ownerId == null) return;
              // Check if already generated to avoid spam
              if (currentInvoices.isNotEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoices for this month likely already exist.')));
                 // return; // Allow re-run if needed, but warn
              }
              await ref.read(invoiceRepositoryProvider).generateMonthlyInvoices(ownerId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoices Generated')));
              }
            },
            icon: const Icon(Icons.receipt_long, size: 18),
            label: const Text("Generate Invoices"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
               if (ownerId == null || currentInvoices.isEmpty) return;
               
               final pendingInvoices = currentInvoices.where((i) => i.status != 'paid').toList();
               if (pendingInvoices.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No pending invoices to remind.')));
                 return;
               }

               setState(() => _selectedDate = _selectedDate); // Trigger rebuild if needed, though repo call is async
               
               int count = 0;
               for (var inv in pendingInvoices) {
                 await ref.read(invoiceRepositoryProvider).sendReminder(inv.id, inv.residentId, inv.monthKey);
                 count++;
               }

               if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent $count reminders successfully!')));
               }
            },
            icon: const Icon(Icons.notifications_active_outlined, size: 18),
            label: const Text("Send Reminders"),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6A11CB),
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF6A11CB)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkList(List<InvoiceModel> allInvoices) {
    // Logic: Filter status=late OR status=due. Sort by late first.
    final workItems = allInvoices.where((i) => i.status == 'due' || i.status == 'late').toList();
    
    // Sort: Late comes first, then by dueDate ascending (urgent first)
    workItems.sort((a, b) {
      if (a.status == 'late' && b.status != 'late') return -1;
      if (b.status == 'late' && a.status != 'late') return 1;
      return a.dueDate.compareTo(b.dueDate);
    });

    if (workItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("All caught up! No pending payments.", style: GoogleFonts.inter(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workItems.length,
      itemBuilder: (context, index) {
        final item = workItems[index];
        final isLate = item.status == 'late'; // Simplify logic, in real query we'd check date vs now if status not updated
        // For MVP, if dueDate < now and status is due, treat as late visually?
        final actuallyLate = item.dueDate.isBefore(DateTime.now()) && item.status == 'due'; 
        
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
              item.propertyId, // Ideally Property Name via lookup/join
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Flat: ${item.flatId} • ${DateFormat('MMM d').format(item.dueDate)}", style: GoogleFonts.inter(fontSize: 12)),
                Text("৳${item.totalAmount.toStringAsFixed(0)}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
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
                  await ref.read(invoiceRepositoryProvider).markAsPaid(item.id, item.totalAmount);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice marked as Paid')));
                  }
                } else if (value == 'remind') {
                  await ref.read(invoiceRepositoryProvider).sendReminder(item.id, item.residentId, item.monthKey);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder Sent')));
                  }
                } else if (value == 'details') {
                  context.push('/owner/property/${item.propertyId}/flat/${item.flatId}/invoice/${item.id}', extra: item);
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
      },
    );
  }

  Widget _buildMessagesList(String? ownerId) {
    if (ownerId == null) return const SizedBox();

    final requestsAsync = ref.watch(ownerRequestsProvider(ownerId));

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("No messages from residents yet.", style: GoogleFonts.inter(color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final isService = request.type == 'service';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isService ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  child: Icon(
                    isService ? Icons.build : Icons.chat_bubble_outline,
                    color: isService ? Colors.green : Colors.blue,
                    size: 20,
                  ),
                ),
                title: Text(
                  request.title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, h:mm a').format(request.createdAt),
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                onTap: () => _showRequestDetails(context, request),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showRequestDetails(BuildContext context, RequestModel request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: request.type == 'service' ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.type.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: request.type == 'service' ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy h:mm a').format(request.createdAt),
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(request.title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                request.message,
                style: GoogleFonts.inter(fontSize: 16, height: 1.5, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              if (request.status != 'closed')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: request.status == 'in_progress' ? null : () async {
                          await ref.read(requestRepositoryProvider).updateRequestStatus(request.id, 'in_progress');
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(request.status == 'in_progress' ? 'In Progress' : 'Mark In Progress'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showReplyDialog(context, request),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A11CB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Reply & Close'),
                      ),
                    ),
                  ],
                ),
              if (request.status == 'closed' && request.response != null) ...[
                const SizedBox(height: 20),
                Text('Owner Response:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(request.response!, style: GoogleFonts.inter(color: Colors.black87)),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  void _showReplyDialog(BuildContext context, RequestModel request) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Response'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your response here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ref.read(requestRepositoryProvider).addResponse(request.id, controller.text.trim());
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Response sent and request closed.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
