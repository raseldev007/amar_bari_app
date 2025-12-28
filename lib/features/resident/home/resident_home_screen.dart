import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../auth/data/auth_repository.dart';
import 'data/resident_repository.dart';
import '../../../../models/invoice_model.dart';
import 'package:amar_bari/features/resident/requests/data/request_repository.dart';
import '../../owner/invoices/data/invoice_repository.dart';

import 'package:amar_bari/core/common_widgets/app_footer.dart';
import 'package:amar_bari/models/request_model.dart';

class ResidentHomeScreen extends ConsumerWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final dashboardDataAsync = ref.watch(residentDashboardDataProvider(user?.uid ?? ''));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft grey background
      body: dashboardDataAsync.when(
        data: (data) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, data),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // State-based Content
                      if (data.state == ResidentHomeState.invoiceExists)
                        _buildBillCard(context, data.currentInvoice)
                      else if (data.state == ResidentHomeState.assignedNoInvoice)
                        _buildNoInvoiceCard(context, ref, data)
                      else
                        _buildNotAssignedCard(context),

                      const SizedBox(height: 25),
                      _buildQuickActions(context),
                      const SizedBox(height: 25),
                      _buildNotificationsInfo(),
                      const SizedBox(height: 25),
                      const ResidentRequestsWidget(),
                      const SizedBox(height: 25),
                      _buildSupportSection(context),
                      const SizedBox(height: 10),
                      const AppFooter(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ResidentDashboardData data) {
    final propertyName = data.property?.name ?? 'Amar Bari';
    final flatLabel = data.flat?.label ?? '...';
    
    String statusText = 'PENDING';
    Color statusColor = Colors.orange; // Not strictly used for styling container currently but kept for logic

    if (data.state == ResidentHomeState.notAssigned) {
      statusText = 'NOT ASSIGNED';
    } else {
      statusText = 'ACTIVE';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
           image: AssetImage('assets/images/resident_home_header_bg_1766883763638.png'),
           fit: BoxFit.cover,
           opacity: 0.2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT COLUMN: Property Name + Flat Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  propertyName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                if (data.state != ResidentHomeState.notAssigned)
                  Row(
                    children: [
                      Icon(Icons.apartment, color: Colors.white.withOpacity(0.9), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Flat $flatLabel',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                   Text(
                     'Welcome Resident', 
                     style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                   ),
              ],
            ),
          ),
          
          // RIGHT COLUMN: Profile Icon + Status Chip
          const SizedBox(width: 16), // Spacing between columns
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Icon
              InkWell(
                onTap: () => context.push('/resident/profile'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 12),
              // Status Chip
              InkWell(
                onTap: () => _showStatusDetails(context, data),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotAssignedCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 40, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              "You are not assigned to a flat yet.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Please contact the property owner to get assigned.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleNotAssignedTap(context),
              child: const Text("Contact Owner"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoInvoiceCard(BuildContext context, WidgetRef ref, ResidentDashboardData data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, size: 40, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              "No invoice generated for this month.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleInvoiceRequest(context, ref, data),
              child: const Text("Request Invoice"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(BuildContext context, InvoiceModel? invoice) {
    if (invoice == null) return const SizedBox.shrink();

    final isPaid = invoice.status == 'paid';
    final gradient = isPaid ? AppGradients.paid : AppGradients.due;
    final statusText = isPaid ? 'PAID' : 'DUE';
    final statusIcon = isPaid ? Icons.check_circle : Icons.warning_rounded;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 5, blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // Card Header with Gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bill Summary',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: isPaid ? const Color(0xFF11998e) : const Color(0xFFEB3349), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.inter(
                          color: isPaid ? const Color(0xFF11998e) : const Color(0xFFEB3349),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildRow('Rent', invoice.items.firstWhere((i) => i.key == 'Rent', orElse: () => const InvoiceItem(key: 'Rent', amount: 0)).amount),
                const SizedBox(height: 12),
                // Simplified Utility Sum
                _buildRow('Utilities & Charges', invoice.totalAmount - invoice.items.firstWhere((i) => i.key == 'Rent', orElse: () => const InvoiceItem(key: 'Rent', amount: 0)).amount),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Payable', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600])),
                    Text(
                      '৳${invoice.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                if (!isPaid)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => context.push('/resident/payment', extra: invoice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2575FC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: const Color(0xFF2575FC).withOpacity(0.4),
                      ),
                      child: Text(
                        'Pay Now',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[700])),
        Text('৳${amount.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.description_outlined, 'label': 'Documents', 'color': Colors.orange, 'route': '/resident/documents'},
      {'icon': Icons.history, 'label': 'History', 'color': Colors.blue, 'route': '/resident/history'},
      {'icon': Icons.contact_support_outlined, 'label': 'Support', 'color': Colors.purple, 'route': '/resident/support'},
      {'icon': Icons.build_circle_outlined, 'label': 'Service', 'color': Colors.green, 'route': '/resident/service'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((a) => _buildActionButton(context, a)).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {
         if (action['route'] != null) {
           context.push(action['route']);
         }
      },
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: (action['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(action['label'] as String, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildNotificationsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_active_outlined, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reminder", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                Text("Rent is due on 5th January", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  void _handleNotAssignedTap(BuildContext context) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Contact Owner'),
        content: const Text('You are not assigned to a flat yet. You can send a message to your property owner here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel')
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/resident/support');
            }, 
            child: const Text('Send Message')
          ),
        ],
      )
    );
  }

  void _handleInvoiceRequest(BuildContext context, WidgetRef ref, ResidentDashboardData data) {
    if (data.property == null || data.user == null) return;
    
    // Create notification logic
    final notificationData = {
      'toUserId': data.property!.ownerId,
      'fromUserId': data.user!.uid,
      'type': 'invoice_request',
      'title': 'Invoice Request',
      'message': '${data.user!.name ?? "Resident"} requested invoice for ${DateFormat('MMMM').format(DateTime.now())}',
      'flatId': data.flat?.id,
      'month': DateFormat('yyyy-MM').format(DateTime.now()),
    };

    ref.read(requestRepositoryProvider).createNotification(notificationData);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice Request Sent!')));
  }

  void _showStatusDetails(BuildContext context, ResidentDashboardData data) {
    showModalBottomSheet(
      context: context, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Account Status: ${data.state == ResidentHomeState.notAssigned ? "Pending/Not Assigned" : "Active"}', 
               style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 12),
             if (data.state == ResidentHomeState.notAssigned) ...[
               const Text('You have not been assigned to a flat or your assignment is pending owner approval.'),
               const SizedBox(height: 20),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                     Navigator.pop(context);
                     context.push('/resident/documents');
                   },
                   child: const Text('Complete Documents'),
                 ),
               )
             ] else ...[
               const Text('You are an active resident. You can view your bills and history.'),
             ],
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support & Development',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF00695C), 
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 10,
              )
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.code, color: Color(0xFF00695C)), 
            ),
            title: Text(
              'Contact Developer',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(
              'MD. Rasel (Business Deals)',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => context.push('/contact_developer'),
          ),
        ),
      ],
    );
  }
}

class ResidentRequestsWidget extends ConsumerWidget {
  const ResidentRequestsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final requestsAsync = ref.watch(residentRequestsProvider(user?.uid ?? ''));

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Recent Requests',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length > 3 ? 3 : requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final isClosed = request.status == 'closed';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: ListTile(
                    title: Text(request.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      isClosed && request.response != null 
                        ? "Response: ${request.response}" 
                        : request.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, color: isClosed ? Colors.green[700] : Colors.grey[600]),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(request.status),
                        ),
                      ),
                    ),
                    onTap: () => _showRequestDetail(context, request),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'closed': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _showRequestDetail(BuildContext context, RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Message:", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            Text(request.message),
            if (request.response != null) ...[
              const SizedBox(height: 16),
              Text("Owner Response:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.green)),
              Text(request.response!),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
