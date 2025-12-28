import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:amar_bari/models/invoice_model.dart';
import 'package:amar_bari/features/owner/invoices/data/invoice_repository.dart';
import 'package:amar_bari/features/auth/data/auth_repository.dart';
import 'package:amar_bari/features/owner/properties/presentation/properties_list_widget.dart';
import 'package:amar_bari/features/owner/properties/data/property_repository.dart';
import 'package:amar_bari/features/owner/flats/data/flat_repository.dart';
import 'package:amar_bari/features/owner/tenants/data/lease_repository.dart';
import 'package:amar_bari/features/resident/requests/data/request_repository.dart';
import 'package:amar_bari/models/request_model.dart';
import 'package:amar_bari/models/lease_model.dart';
import 'package:amar_bari/models/flat_model.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_gradients.dart';

import 'package:amar_bari/core/common_widgets/app_footer.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final invoicesAsync = ref.watch(ownerInvoicesProvider(user?.uid ?? ''));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, user?.displayName),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKPICards(invoicesAsync),
                  const SizedBox(height: 30),
                  const RecentRequestsWidget(),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Properties',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.receipt_long, color: Colors.blue),
                          tooltip: "Generate Invoices",
                          onPressed: () async {
                            if (user != null) {
                              await ref.read(invoiceRepositoryProvider).generateMonthlyInvoices(user.uid);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoices Generated')));
                              }
                            }
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400, // Fixed height for list in scroll view
                    child: const OwnerPropertiesList(), 
                  ),
                  const SizedBox(height: 30),
                  _buildSupportSection(context),
                  const SizedBox(height: 20),
                  const AppFooter(),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/add_property'),
        label: Text('Add Property', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF6A11CB),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
           image: AssetImage('assets/images/owner_dashboard_bg_1766883899431.png'), // Placeholder for asset if integrated
           fit: BoxFit.cover,
           opacity: 0.2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            userName ?? 'Owner',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: InkWell(
              onTap: () => context.push('/owner/overview'),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.greenAccent),
                  const SizedBox(width: 10),
                  Text(
                    'Overview',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKPICards(AsyncValue<List<InvoiceModel>> invoicesAsync) {
    return invoicesAsync.when(
      data: (invoices) {
        double due = 0;
        double paid = 0;
        // int overdue = 0;
        for (var inv in invoices) {
          if (inv.status == 'paid') paid += inv.totalAmount;
          if (inv.status == 'due' || inv.status == 'late') due += inv.totalAmount;
        }

        return Row(
          children: [
            _kpiCard('Total Due', '৳${due.toStringAsFixed(0)}', AppGradients.due, Icons.pending_actions),
            const SizedBox(width: 16),
            _kpiCard('Collected', '৳${paid.toStringAsFixed(0)}', AppGradients.paid, Icons.check_circle_outline),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(), 
      error: (_,__) => const SizedBox(),
    );
  }

  Widget _kpiCard(String title, String value, LinearGradient gradient, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
           boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 5, blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(title, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
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

class RecentRequestsWidget extends ConsumerWidget {
  const RecentRequestsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final requestsAsync = ref.watch(ownerRequestsProvider(user?.uid ?? ''));

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();
        
        final openRequests = requests.where((r) => r.status == 'open').toList();
        if (openRequests.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Resident Requests',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ...openRequests.take(3).map((request) => _buildRequestCard(context, ref, request)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildRequestCard(BuildContext context, WidgetRef ref, RequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: request.type == 'service' ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.type.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: request.type == 'service' ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              Text(
                DateFormat('MMM d').format(request.createdAt),
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(request.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            request.message,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => _showRequestDetails(context, request),
                child: const Text('View Details'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showLeaseDialog(context, ref, request),
                icon: const Icon(Icons.vpn_key, size: 16),
                label: const Text('Lease to Flat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showRequestDetails(BuildContext context, RequestModel request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer(
        builder: (context, ref, child) => DraggableScrollableSheet(
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
                          onPressed: () => _showReplyDialog(context, ref, request),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReplyDialog(BuildContext context, WidgetRef ref, RequestModel request) {
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

  void _showLeaseDialog(BuildContext context, WidgetRef ref, RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => LeaseFlatDialog(residentId: request.tenantId),
    );
  }
}

class LeaseFlatDialog extends ConsumerStatefulWidget {
  final String residentId;
  const LeaseFlatDialog({super.key, required this.residentId});

  @override
  ConsumerState<LeaseFlatDialog> createState() => _LeaseFlatDialogState();
}

class _LeaseFlatDialogState extends ConsumerState<LeaseFlatDialog> {
  String? _selectedPropertyId;
  String? _selectedFlatId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final propertiesAsync = ref.watch(ownerPropertiesProvider);

    return AlertDialog(
      title: Text('Assign to Flat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            propertiesAsync.when(
              data: (properties) => DropdownButtonFormField<String>(
                value: _selectedPropertyId,
                decoration: const InputDecoration(labelText: 'Select Property'),
                items: properties.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (val) => setState(() {
                  _selectedPropertyId = val;
                  _selectedFlatId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
            if (_selectedPropertyId != null) ...[
              const SizedBox(height: 16),
              ref.watch(propertyFlatsProvider(_selectedPropertyId!)).when(
                data: (flats) {
                  final vacantFlats = flats.where((f) => f.status == 'vacant').toList();
                  if (vacantFlats.isEmpty) return const Text('No vacant flats available in this property.');
                  return DropdownButtonFormField<String>(
                    value: _selectedFlatId,
                    decoration: const InputDecoration(labelText: 'Select Flat'),
                    items: vacantFlats.map((f) => DropdownMenuItem(value: f.id, child: Text(f.label))).toList(),
                    onChanged: (val) => setState(() => _selectedFlatId = val),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: (_selectedFlatId == null || _isLoading) ? null : _submitLease,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white),
          child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm Lease'),
        ),
      ],
    );
  }

  Future<void> _submitLease() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      final flat = await ref.read(flatRepositoryProvider).getFlat(_selectedFlatId!);
      
      if (flat == null || user == null) throw 'Error: Invalid selection';

      final lease = LeaseModel(
        id: const Uuid().v4(),
        ownerId: user.uid,
        propertyId: _selectedPropertyId!,
        flatId: _selectedFlatId!,
        residentId: widget.residentId,
        startDate: DateTime.now(),
        status: 'active',
        createdAt: DateTime.now(),
      );

      await ref.read(leaseRepositoryProvider).createLease(lease, flat);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resident assigned successfully!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
