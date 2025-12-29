
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/flat_model.dart';
import '../data/owner_dashboard_providers.dart';

class ResidentListItem extends ConsumerWidget {
  final FlatModel flat;

  const ResidentListItem({super.key, required this.flat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (flat.residentId == null) return const SizedBox.shrink();

    final residentAsync = ref.watch(residentProfileProvider(flat.residentId!));
    // We also want verification status, so we could watch tenantProfileProvider too
    // But for list, maybe just show User details first.
    final tenantAsync = ref.watch(tenantProfileProvider(flat.residentId!));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: () {
           context.push('/owner/residents/${flat.residentId}', extra: flat);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              residentAsync.when(
                data: (user) => CircleAvatar(
                  radius: 20,
                  backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                  backgroundColor: Colors.blue[100],
                  child: user?.photoUrl == null 
                      ? Text(user?.name?.substring(0, 1).toUpperCase() ?? '?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blue[800])) 
                      : null,
                ),
                loading: () => const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                error: (_,__) => const CircleAvatar(radius: 20, backgroundColor: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    residentAsync.when(
                      data: (user) => Row(
                        children: [
                          Flexible(
                            child: Text(
                              user?.name ?? 'Unknown',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          tenantAsync.when(
                            data: (tenant) => tenant?.verified == true 
                                ? const Icon(Icons.verified, color: Colors.blue, size: 14) 
                                : const Icon(Icons.verified_outlined, color: Colors.grey, size: 14),
                            loading: () => const SizedBox(),
                            error: (_,__) => const SizedBox(),
                          ),
                        ],
                      ),
                      loading: () => Container(width: 100, height: 14, color: Colors.grey[300]),
                      error: (_,__) => const Text('Error'),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                         Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            flat.label,
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green[800]),
                          ),
                         ),
                        // Note: Property Name is not directly available in FlatModel, only propertyId.
                        // We could fetch property, or just assume the context (Dashboard List) is enough.
                        // But listing across properties, we need Property Name if possible.
                        // For MVP, avoid N+1 property query for each item if possible, or accept it.
                        // Or just show Flat label. User context might be enough or "Property: ..."
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
