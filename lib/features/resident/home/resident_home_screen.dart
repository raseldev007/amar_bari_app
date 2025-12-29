import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../auth/data/auth_repository.dart';
import 'data/resident_repository.dart';
import '../../../../models/invoice_model.dart';
import 'package:amar_bari/l10n/app_localizations.dart';
import 'package:amar_bari/features/resident/requests/data/request_repository.dart';
import '../../owner/invoices/data/invoice_repository.dart';

import 'package:amar_bari/core/common_widgets/app_footer.dart';
import 'package:amar_bari/models/request_model.dart';
import 'package:amar_bari/models/flat_model.dart'; // Added missing import
import 'package:uuid/uuid.dart';

class ResidentHomeScreen extends ConsumerWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final dashboardDataAsync = ref.watch(residentDashboardDataProvider(user?.uid ?? ''));
    final realTimeInvoicesAsync = ref.watch(residentInvoicesStreamProvider(user?.uid ?? '')); // Watch Real-time data

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft grey background
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myHome, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = ref.read(authRepositoryProvider).currentUser;
              if (user != null) {
                 ref.refresh(residentInvoicesStreamProvider(user.uid));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: dashboardDataAsync.when(
        data: (staticData) {
          // Merge Real-time data locally
          return realTimeInvoicesAsync.when(
            data: (invoices) {
              // Recalculate based on real-time stream
              double outstandingAmount = 0.0;
              InvoiceModel? currentInvoice;
              final currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());

              // Strategy: 
              // 1. Find the LATEST invoice that is NOT PAID (Due/Overdue).
              // 2. If all are paid, show the LATEST paid invoice.
              
              InvoiceModel? firstDue;
              
              for (var inv in invoices) {
                if (inv.status != 'paid') {
                   // Keep track of total outstanding
                   outstandingAmount += inv.totalAmount;
                   
                   // Found a due invoice? If it's the first one we see (since list is sorted by latest), keep it.
                   firstDue ??= inv;
                }
              }

              // Decision logic:
              // If we found a DUE invoice, show it (prioritize latest due).
              // Else, show the absolute latest invoice (which must be paid).
              if (firstDue != null) {
                currentInvoice = firstDue;
              } else if (invoices.isNotEmpty) {
                currentInvoice = invoices.first;
              }

              // Determine State dynamically
              ResidentHomeState state = ResidentHomeState.assignedNoInvoice;
              if (staticData.state == ResidentHomeState.notAssigned) {
                 state = ResidentHomeState.notAssigned; 
              } else if (currentInvoice != null) {
                 state = ResidentHomeState.invoiceExists;
              }

              // Create dynamic data object for UI
              final dynamicData = ResidentDashboardData(
                state: state,
                user: staticData.user,
                flat: staticData.flat,
                property: staticData.property,
                currentInvoice: currentInvoice,
                outstandingAmount: outstandingAmount,
              );
              
              return _buildDashboardBody(context, ref, dynamicData);
            },
            loading: () => const Center(child: CircularProgressIndicator()), // Or show static data while loading stream?
            error: (e,s) => _buildDashboardBody(context, ref, staticData), // Fallback to static if stream fails
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
      ),
    );
  }

  Widget _buildDashboardBody(BuildContext context, WidgetRef ref, ResidentDashboardData data) {
    return RefreshIndicator(
      onRefresh: () async {
        final user = ref.read(authRepositoryProvider).currentUser;
        ref.invalidate(residentDashboardDataProvider(user?.uid ?? ''));
        ref.invalidate(residentRequestsProvider(user?.uid ?? ''));
        // Stream updates automatically, no need to invalidate
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(context, ref, data), // Pass ref
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Detailed Flat Info Card
                  if (data.flat != null) 
                    _buildFlatDetailsCard(context, data.flat!),

                  const SizedBox(height: 10),
                  
                  // State-based Content
                  _buildOutstandingDuesCard(context, data.outstandingAmount, data),
                  const SizedBox(height: 15),
                  
                  // Payment Options (Advance & Due)
                  if (data.state != ResidentHomeState.notAssigned)
                     Padding(
                       padding: const EdgeInsets.only(bottom: 15),
                       child: _buildPaymentOptions(context, data),
                     ),

                  // Invoice Section
                  if (data.state == ResidentHomeState.invoiceExists)
                    _buildBillCard(context, data.currentInvoice)
                  else if (data.state == ResidentHomeState.assignedNoInvoice)
                    _buildNoInvoiceCard(context, ref, data)
                  else
                    _buildNotAssignedCard(context),

                  const SizedBox(height: 15),
                  // Requests Section (Moved here to be 'beside' the invoice option)
                  const ResidentRequestsWidget(),

                  const SizedBox(height: 25),
                  _buildQuickActions(context),
                  const SizedBox(height: 25),
                  _buildNotificationsInfo(context),
                  const SizedBox(height: 25),
                  // ResidentRequestsWidget moved up
                  _buildSupportSection(context),
                  const SizedBox(height: 10),
                  const AppFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ResidentDashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    final propertyName = data.property?.name ?? 'Amar Bari';
    final flatLabel = data.flat?.label ?? '...';
    
    String statusText = 'PENDING';
    Color statusColor = Colors.orange; // Not strictly used for styling container currently but kept for logic

    if (data.state == ResidentHomeState.notAssigned) {
      statusText = l10n.statusNotAssigned;
    } else {
      statusText = l10n.statusActive;
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
                        '${l10n.flat} $flatLabel',
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
                     l10n.welcomeResident, 
                     style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                   ),
              ],
            ),
          ),
          
          // RIGHT COLUMN: Refresh + Profile + Status
          const SizedBox(width: 16), // Spacing between columns
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    // Refresh Button
                    InkWell(
                      onTap: () {
                         ref.invalidate(residentDashboardDataProvider(data.user?.uid ?? ''));
                         ref.invalidate(residentRequestsProvider(data.user?.uid ?? ''));
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.refreshing), duration: const Duration(seconds: 1)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.refresh, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                 ],
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.notAssignedDetail,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.contactOwnerPrompt,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleNotAssignedTap(context),
              child: Text(l10n.contactOwner),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoInvoiceCard(BuildContext context, WidgetRef ref, ResidentDashboardData data) {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.noInvoiceDetail,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleInvoiceRequest(context, ref, data),
              child: Text(l10n.requestInvoice),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(BuildContext context, InvoiceModel? invoice) {
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.billSummary,
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
                        statusText == 'PAID' ? l10n.statusActive : l10n.statusPending,
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
                _buildRow(l10n.rent, invoice.items.firstWhere((i) => i.key == 'Rent', orElse: () => const InvoiceItem(key: 'Rent', amount: 0)).amount),
                const SizedBox(height: 12),
                // Simplified Utility Sum
                _buildRow(l10n.utilities, invoice.totalAmount - invoice.items.firstWhere((i) => i.key == 'Rent', orElse: () => const InvoiceItem(key: 'Rent', amount: 0)).amount),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.totalPayable, style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600])),
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
                        l10n.payNow,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    label: Text(l10n.downloadReceipt),
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
    final l10n = AppLocalizations.of(context)!;
    final actions = [
      {'icon': Icons.description_outlined, 'label': 'Documents', 'color': Colors.orange, 'route': '/resident/documents'},
      {'icon': Icons.history, 'label': 'History', 'color': Colors.blue, 'route': '/resident/history'},
      {'icon': Icons.contact_support_outlined, 'label': 'Support', 'color': Colors.purple, 'route': '/resident/support'},
      {'icon': Icons.build_circle_outlined, 'label': 'Service', 'color': Colors.green, 'route': '/resident/service'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickActions, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((a) => _buildActionButton(context, a)).toList(),
        ),
      ],
    );
  }

  Widget _buildFlatDetailsCard(BuildContext context, FlatModel flat) {
    final l10n = AppLocalizations.of(context)!;
    double totalExpenses = flat.rentBase;
    flat.utilities.forEach((_, amount) => totalExpenses += amount);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_work_outlined, color: Color(0xFF1976D2)),
          ),
          title: Text(
            l10n.apartmentInfo,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            'Flat ${flat.label} • Est. ৳${totalExpenses.toStringAsFixed(0)}/mo',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildExpenseRow(l10n.baseRent, flat.rentBase, isBold: true),
                  const SizedBox(height: 8),
                  ...flat.utilities.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildExpenseRow('${e.key} Bill', e.value),
                  )),
                  const Divider(),
                  _buildExpenseRow(l10n.totalLiability, totalExpenses, isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseRow(String label, double amount, {bool isBold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold || isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          '৳${amount.toStringAsFixed(0)}',
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF1976D2) : Colors.black87,
          ),
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

  Widget _buildNotificationsInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(l10n.reminder, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                Text(l10n.rentDueReminder, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  void _handleNotAssignedTap(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(l10n.contactOwner),
        content: Text(l10n.notAssignedDetail),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(l10n.cancel)
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/resident/support');
            }, 
            child: Text(l10n.sendMessage)
          ),
        ],
      )
    );
  }

  void _handleInvoiceRequest(BuildContext context, WidgetRef ref, ResidentDashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    if (data.property == null || data.user == null) return;
    
    // Create RequestModel
    final request = RequestModel(
      id: const Uuid().v4(),
      type: 'invoice_request',
      tenantId: data.user!.uid,
      flatId: data.flat?.id,
      propertyId: data.property?.id,
      ownerId: data.property?.ownerId,
      title: l10n.requestInvoice,
      message: '${data.user!.name ?? l10n.statusNotAssigned} requested invoice',
      status: 'open',
      createdAt: DateTime.now(),
    );

    ref.read(requestRepositoryProvider).createRequest(request);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invoiceRequestSent)));
  }

  void _showStatusDetails(BuildContext context, ResidentDashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('${l10n.accountStatus}: ${data.state == ResidentHomeState.notAssigned ? l10n.statusPending : l10n.statusActive}', 
               style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 12),
             if (data.state == ResidentHomeState.notAssigned) ...[
               Text(l10n.notAssignedDetail),
               const SizedBox(height: 20),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                     Navigator.pop(context);
                     context.push('/resident/documents');
                   },
                   child: Text(l10n.completeDocuments),
                 ),
               )
             ] else ...[
               Text(l10n.activeResidentMessage),
             ],
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(BuildContext context, ResidentDashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    bool canPayDue = data.currentInvoice != null && data.currentInvoice!.status != 'paid';
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canPayDue ? () => context.push('/resident/payment', extra: data.currentInvoice) : null,
            icon: const Icon(Icons.payment),
            label: Text(l10n.payDue),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
               if (data.property?.ownerId != null) {
                 context.push('/resident/payment', extra: {'ownerId': data.property!.ownerId, 'invoice': null});
               }
            },
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: Text(l10n.payAdvance),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2575FC), // Match app theme
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutstandingDuesCard(BuildContext context, double amount, ResidentDashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    if (amount <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.noDuesMessage,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade800),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.outstandingDues,
                      style: GoogleFonts.inter(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '৳${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(color: Colors.red.shade900, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to My Invoices Screen
                // context.push('/resident/invoices'); // Assuming this route exists, or push to payment for specific logic
                // For MVP, we show a list or snackbar if no dedicated screen yet.
                // Assuming we want to pay. Let's redirect to History or Documents where bills might be?
                // Or "Quick Actions -> History"
                context.push('/resident/history'); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.viewUnpaidBills),
            ),
          )
        ],
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
                  child: Column(
                    children: [
                      ListTile(
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
                        onTap: () => _showRequestDetail(context, ref, request),
                      ),
                      if (request.invoiceId != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: FutureBuilder<InvoiceModel?>(
                            future: ref.read(residentRepositoryProvider).getInvoice(request.invoiceId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const LinearProgressIndicator(minHeight: 2);
                              }
                              if (snapshot.hasData && snapshot.data != null) {
                                final invoice = snapshot.data!;
                                final isPaid = invoice.status == 'paid';
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.receipt_long, color: Colors.blue, size: 16),
                                          const SizedBox(width: 8),
                                          Text("Invoice Generated", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 13)),
                                          const Spacer(),
                                          if (isPaid)
                                            const Icon(Icons.check_circle, color: Colors.green, size: 16)
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total: ৳${invoice.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                                          if (!isPaid)
                                            SizedBox(
                                              height: 36,
                                              child: ElevatedButton(
                                                onPressed: () => context.push('/resident/payment', extra: invoice),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                child: const Text("Pay Now"),
                                              ),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.green),
                                              ),
                                              child: const Text("PAID", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                    ],
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

  void _showRequestDetail(BuildContext context, WidgetRef ref, RequestModel request) {
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
            if (request.invoiceId != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              FutureBuilder<InvoiceModel?>(
                future: ref.read(residentRepositoryProvider).getInvoice(request.invoiceId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return const Text("Error loading invoice");
                  }
                  final invoice = snapshot.data!;
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/resident/payment', extra: invoice);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("View Full Bill"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
