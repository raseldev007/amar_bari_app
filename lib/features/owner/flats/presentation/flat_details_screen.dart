import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../models/flat_model.dart';
import '../../flats/data/flat_repository.dart';
import '../../tenants/data/lease_repository.dart';
import '../../invoices/data/invoice_repository.dart';

class FlatDetailScreen extends ConsumerWidget {
  final String propertyId;
  final String flatId;
  final FlatModel? initialFlat;

  const FlatDetailScreen({
    super.key, 
    required this.propertyId, 
    required this.flatId, 
    this.initialFlat
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flatAsync = ref.watch(flatDetailsProvider(flatId));
    final activeLeaseAsync = ref.watch(activeLeaseProvider(flatId));
    
    // Use initial data if available while loading
    // But prefer stream/future data
    
    return flatAsync.when(
      data: (flat) {
        if (flat == null) return const Scaffold(body: Center(child: Text('Flat not found')));
        return Scaffold(
          appBar: AppBar(
            title: Text('Flat ${flat.label}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                   // Navigate to Edit Flat (reusing AddEditFlatScreen)
                   // We need to define this route properly or push directly
                   // Route defined as 'property/:pid/flat/:fid' in router, let's use that but 
                   // currently router points here. I need to fix router to point here for view, 
                   // and maybe 'edit' for editing.
                   // For now, let's just push direct or use a query param 'action=edit'
                   // Or simple:
                   context.push('/owner/property/$propertyId/add_flat?edit=true', extra: flat); 
                   // Wait, I mapped /flat/:flatId to AddEdit in router previously. 
                   // I will fix router in next step to point /flat/:flatId to THIS screen.
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context, flat),
                const SizedBox(height: 16),
                const Text('Current Tenant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildLeaseSection(context, ref, flat, activeLeaseAsync),
                 const SizedBox(height: 16),
                 const Text('Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 Consumer(
                   builder: (context, ref, _) {
                     final invoicesAsync = ref.watch(flatInvoicesProvider(flatId));
                     return invoicesAsync.when(
                       data: (invoices) {
                         if (invoices.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No invoices yet')));
                         return Column(
                           children: invoices.map((inv) => Card(
                             child: ListTile(
                               title: Text(inv.monthKey),
                               subtitle: Text('Status: ${inv.status.toUpperCase()}'),
                               trailing: Text('৳${inv.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                               onTap: () {
                                 context.push('/owner/property/$propertyId/flat/$flatId/invoice/${inv.id}', extra: inv);
                               },
                             ),
                           )).toList(),
                         );
                       },
                       loading: () => const Center(child: LinearProgressIndicator()),
                       error: (e, s) => Text('Error: $e'),
                     );
                   },
                 )
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildInfoCard(BuildContext context, FlatModel flat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rent Base'),
                Text('৳${flat.rentBase}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            ...flat.utilities.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Utility: ${e.key.toUpperCase()}'),
                  Text('৳${e.value}'),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Due Day'),
                Text('${flat.dueDay}th of month'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaseSection(BuildContext context, WidgetRef ref, FlatModel flat, AsyncValue activeLeaseAsync) {
    return activeLeaseAsync.when(
      data: (lease) {
        if (lease == null || flat.status == 'vacant') {
          return Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.person_off, size: 48, color: Colors.orange),
                  const Text('Property is Vacant'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      context.push('/owner/property/$propertyId/flat/$flatId/assign_tenant', extra: flat);
                    },
                    child: const Text('Assign Tenant'),
                  ),
                ],
              ),
            ),
          );
        }
        return Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Resident Assigned'),
                  // TODO: Fetch Resident Name
                  subtitle: Text('Lease Active'),
                ),
                Text('Started: ${DateFormat.yMMMd().format(lease.startDate)}'),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    // Logic to end lease
                    Text('End Lease');
                  },
                  child: const Text('End Lease (Move Out)'),
                )
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading lease: $e'),
    );
  }
}
