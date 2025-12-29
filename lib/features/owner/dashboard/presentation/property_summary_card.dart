
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/property_model.dart';
import '../data/owner_dashboard_providers.dart';
import 'package:amar_bari/l10n/app_localizations.dart';

class PropertySummaryCard extends ConsumerWidget {
  final PropertyModel property;

  const PropertySummaryCard({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(propertyStatsProvider(property.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/owner/property/${property.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${property.address}, ${property.city}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              statsAsync.when(
                data: (stats) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(AppLocalizations.of(context)!.totalDue, stats.totalFlats.toString(), Colors.blue),
                    _buildStatItem(AppLocalizations.of(context)!.statusActive, stats.occupiedFlats.toString(), Colors.green),
                    _buildStatItem(AppLocalizations.of(context)!.residents, stats.residentsCount.toString(), Colors.purple),
                  ],
                ),
                loading: () => const Center(
                  child: SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  ),
                ),
                error: (e, _) => Text(AppLocalizations.of(context)!.error, style: TextStyle(color: Colors.red[300], fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
