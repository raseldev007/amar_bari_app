import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amar_bari/models/property_model.dart';
import '../../properties/data/property_repository.dart';
import '../../flats/data/flat_repository.dart';
import '../../../auth/data/auth_repository.dart';

// We need to fetch property details individually if we are just navigating by ID
final singlePropertyProvider = FutureProvider.family<PropertyModel?, String>((ref, id) {
  // We can reuse getOwnerProperties but that fetches all. Better to have a getProperty(id) in repo.
  // For now let's assume we can iterate the list or add getProperty to repo.
  // Let's rely on the list for now or just fetch it.
  // Actually, let's implement getProperty in repo to be safe.
  // But wait, the previous Repo didn't have getProperty(id).
  // I'll add it to the repo interface quickly or just filter from list if cached.
  // For robustness, I'll assume we might need to fetch it.
  // But for MVP speed, filtering the list is fine if we suspect it's there.
  // However, deep linking needs direct fetch.
  // I'll use a Firestore direct fetch here for simplicity.
  return ref.read(propertyRepositoryProvider).getOwnerProperties(
    ref.read(authRepositoryProvider).currentUser?.uid ?? ''
  ).first.then((list) => list.firstWhere((p) => p.id == id)); 
  // This is a bit risky if list is empty. 
  // Let's just do a direct firestore get in the widget or a new provider.
});


class PropertyDetailsScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flatsAsync = ref.watch(propertyFlatsProvider(propertyId));
    // Ideally we also fetch property Name... 
    // For now we just show "Property Details" or pass name via extra?
    // Let's try to find property from the list provider if available.
    final properties = ref.watch(ownerPropertiesProvider).asData?.value;
    final property = properties?.firstWhere((p) => p.id == propertyId, orElse: () => PropertyModel(id: '', ownerId: '', name: 'Loading...', address: '', city: '', createdAt: DateTime.now()));

    return Scaffold(
      appBar: AppBar(
        title: Text(property?.name ?? 'Property Details'),
        actions: [
          if (property != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/owner/add_property', extra: property);
              },
            ),
          if (property != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                 showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Property?'),
                      content: const Text('This will delete the property and all its flats. This action cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () async {
                             Navigator.pop(context);
                             try {
                               await ref.read(propertyRepositoryProvider).deleteProperty(property!.id);
                               // Ideally we should also delete all sub-collections (flats) but that is best done via Cloud Function
                               // or batch writes. For now, we assume simple delete.
                               if (context.mounted) {
                                  context.pop(); // Go back to dashboard
                               }
                             } catch (e) {
                               if (context.mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                               }
                             }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          child: const Text('Delete'),
                        )
                      ],
                    )
                 );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (property != null)
            Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text('${property.address}, ${property.city}', style: Theme.of(context).textTheme.bodyLarge),
            ),
          Expanded(
            child: flatsAsync.when(
              data: (flats) {
                if (flats.isEmpty) {
                  return const Center(child: Text('No flats added yet.'));
                }
                return ListView.builder(
                  itemCount: flats.length,
                  itemBuilder: (context, index) {
                    final flat = flats[index];
                    return ListTile(
                      title: Text(flat.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Status: ${flat.status.toUpperCase()} - Rent: ৳${flat.rentBase}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                         context.push('/owner/property/$propertyId/flat/${flat.id}', extra: flat);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/owner/property/$propertyId/add_flat');
        },
        label: const Text('Add Flat'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
