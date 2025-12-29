
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../data/owner_dashboard_providers.dart';
import '../../../../models/flat_model.dart';
import '../../../../core/common_widgets/app_footer.dart';

class ResidentDetailsScreen extends ConsumerWidget {
  final String residentId;
  final FlatModel? flatExtra; 

  const ResidentDetailsScreen({super.key, required this.residentId, this.flatExtra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If flat passed as extra, use it, otherwise fetch
    final flatAsync = flatExtra != null 
        ? AsyncValue.data(flatExtra) 
        : ref.watch(flatByResidentProvider(residentId));

    final residentAsync = ref.watch(residentProfileProvider(residentId));
    final tenantAsync = ref.watch(tenantProfileProvider(residentId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Resident Details', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
             // 1. Profile Section
             residentAsync.when(
               data: (user) => _buildProfileHeader(user?.name, user?.photoUrl, user?.phoneNumber, user?.email),
               loading: () => const CircularProgressIndicator(),
               error: (e,_) => Text('Error loading profile: $e'),
             ),
             const SizedBox(height: 24),

             // 2. Flat Info
             if (flatAsync is AsyncData<FlatModel?>)
               if (flatAsync.value != null)
                 Consumer(
                   builder: (context, ref, child) {
                      final flat = flatAsync.value!;
                      final propertyAsync = ref.watch(propertyByIdProvider(flat.propertyId));
                      final propertyName = propertyAsync.value?.name ?? 'Loading Property...';
                      final date = flat.updatedAt ?? flat.createdAt;
                      final formattedDate = DateFormat('MMM d, yyyy').format(date);

                      return _buildSectionCard(
                        title: 'Assigned Flat',
                        icon: Icons.home,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                               propertyName, 
                               style: GoogleFonts.poppins(
                                 fontSize: 16, 
                                 fontWeight: FontWeight.w600, 
                                 color: const Color(0xFF2C3E50), // Dark Blue-Grey for premium look
                                 letterSpacing: 0.5,
                               )
                             ),
                             const SizedBox(height: 4),
                             Text(flat.label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22)),
                             const SizedBox(height: 8),
                             Row(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                   decoration: BoxDecoration(
                                     color: Colors.green.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(4),
                                   ),
                                   child: Text(
                                     flat.status.toUpperCase(),
                                     style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                 const SizedBox(width: 4),
                                 Text('Joined: $formattedDate', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                               ],
                             )
                          ],
                        ),
                      );
                   },
                 ),

             const SizedBox(height: 16),

             // 3. Actions
             // 3. Actions
             residentAsync.when(
               data: (user) => user != null ? _buildActionButtons(context, user.phoneNumber) : const SizedBox(),
               loading: () => const SizedBox(),
               error: (_, __) => const SizedBox(),
             ),

             const SizedBox(height: 24),

             // 4. Documents
             tenantAsync.when(
               data: (tenant) => _buildDocumentsSection(context, tenant),
               loading: () => const LinearProgressIndicator(),
               error: (_,__) => const SizedBox(),
             ),
             
             const SizedBox(height: 40),
             const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String? name, String? photoUrl, String? phone, String? email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          backgroundColor: Colors.blue[100],
          child: photoUrl == null 
              ? Text(name?.substring(0, 1).toUpperCase() ?? '?', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[800])) 
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          name ?? 'Unknown Name',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        if (phone != null) ...[
          const SizedBox(height: 4),
          Text(phone, style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700])),
        ],
        if (email != null) ...[
          const SizedBox(height: 2),
          Text(email, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, String? phone) {
    return Row(
      children: [
        if (phone != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse('tel:$phone')),
              icon: const Icon(Icons.call, size: 18),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
               // Navigate to payments/invoices filtered by resident
               // Assuming invoice list can filter? Or just View Payment History generically
               // For MVP, maybe show snackbar if not implemented, or navigate to full list
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment history filter coming soon')));
            },
            icon: const Icon(Icons.history, size: 18),
            label: const Text('History'),
             style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[800], size: 20),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context, dynamic tenant) {
    // tenant is TenantProfileModel?
    if (tenant == null) {
      return _buildSectionCard(
        title: 'Documents', 
        icon: Icons.folder_shared, 
        child: const Text('No verification documents uploaded.'),
      );
    }
    
    // Explicitly cast or access fields dynamically if type not inferred, but here it is dynamic inside function
    // Better to use typed argument if imported. I imported TenantProfileModel.
    // Let's refactor signature above.
    return _buildDocumentsContent(context, tenant);
  }

  Widget _buildDocumentsContent(BuildContext context, dynamic tenant) {
     return _buildSectionCard(
       title: 'Documents & Verification',
       icon: Icons.verified_user,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               Text('Status: ', style: GoogleFonts.inter(color: Colors.grey[700])),
               Text(
                 tenant.verified ? 'VERIFIED' : 'PENDING',
                 style: GoogleFonts.inter(
                   fontWeight: FontWeight.bold,
                   color: tenant.verified ? Colors.green : Colors.orange,
                 ),
               ),
               if (tenant.verified) const Icon(Icons.check_circle, color: Colors.green, size: 16),
             ],
           ),
           const SizedBox(height: 16),
           if (tenant.nidFrontUrl != null) 
             _buildDocPreview(context, 'NID Front', tenant.nidFrontUrl!),
           if (tenant.birthCertUrl != null)
             _buildDocPreview(context, 'Birth Certificate', tenant.birthCertUrl!),
           if (tenant.photoUrl != null)
              _buildDocPreview(context, 'Passport Photo', tenant.photoUrl!),
              
           if (tenant.nidFrontUrl == null && tenant.birthCertUrl == null)
              const Text('No document images available.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
         ],
       ),
     );
  }

  Widget _buildDocPreview(BuildContext context, String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
           Container(
             height: 40, width: 40,
             decoration: BoxDecoration(
               color: Colors.grey[200],
               borderRadius: BorderRadius.circular(8),
               image: DecorationImage(image: _getAdaptiveImageProvider(url), fit: BoxFit.cover),
             ),
           ),
           const SizedBox(width: 12),
           Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
           const Spacer(),
           TextButton(
             onPressed: () {
               showDialog(
                 context: context, 
                 builder: (_) => Dialog(
                   child: InteractiveViewer(child: _buildAdaptiveImage(url)),
                 )
               );
             },
             child: const Text('View'),
           ),
        ],
      ),
    );
  }

  ImageProvider _getAdaptiveImageProvider(String url) {
    if (url.startsWith('data:image')) {
      return MemoryImage(Uri.parse(url).data!.contentAsBytes());
    }
    return NetworkImage(url);
  }

  Widget _buildAdaptiveImage(String url) {
    if (url.startsWith('data:image')) {
      return Image.memory(Uri.parse(url).data!.contentAsBytes());
    }
    return Image.network(url);
  }
}
