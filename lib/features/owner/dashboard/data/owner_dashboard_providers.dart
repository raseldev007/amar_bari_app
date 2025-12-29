
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/property_model.dart';
import '../../../../models/flat_model.dart';
import '../../../../models/user_model.dart';
import '../../../../models/tenant_profile_model.dart';
import 'owner_dashboard_repository.dart';

// Repository Provider
final ownerDashboardRepositoryProvider = Provider<OwnerDashboardRepository>((ref) {
  return OwnerDashboardRepository(FirebaseFirestore.instance);
});

// Stream of Properties for current owner
final ownerPropertiesProvider = StreamProvider<List<PropertyModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  
  final repo = ref.watch(ownerDashboardRepositoryProvider);
  return repo.getProperties(user.uid);
});

// Stats for a property (Calculated locally from flats stream for Option A)
class PropertyStats {
  final int totalFlats;
  final int occupiedFlats;
  final int residentsCount;

  PropertyStats({
    required this.totalFlats,
    required this.occupiedFlats,
    required this.residentsCount,
  });
}

final propertyStatsProvider = StreamProvider.family<PropertyStats, String>((ref, propertyId) {
  final repo = ref.watch(ownerDashboardRepositoryProvider);
  return repo.getFlatsForProperty(propertyId).map((flats) {
    final total = flats.length;
    final occupied = flats.where((f) => f.status == 'occupied').length;
    final residents = flats.where((f) => f.status == 'occupied' && f.residentId != null).length;
    return PropertyStats(
      totalFlats: total,
      occupiedFlats: occupied,
      residentsCount: residents,
    );
  });
});

// Recent assigned residents (Flats)
final ownerRecentAssignedFlatsProvider = StreamProvider<List<FlatModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  final repo = ref.watch(ownerDashboardRepositoryProvider);
  return repo.getRecentAssignedFlats(user.uid);
});

// Resident Profile (Future)
final residentProfileProvider = FutureProvider.family<UserModel?, String>((ref, residentId) {
  final repo = ref.watch(ownerDashboardRepositoryProvider);
  return repo.getResidentProfile(residentId);
});

// Tenant Profile (Future)
final tenantProfileProvider = FutureProvider.family<TenantProfileModel?, String>((ref, residentId) {
  final repo = ref.watch(ownerDashboardRepositoryProvider);
  return repo.getTenantProfile(residentId);
});

// Flat by resident ID (Future)
final flatByResidentProvider = FutureProvider.family<FlatModel?, String>((ref, residentId) {
    final repo = ref.watch(ownerDashboardRepositoryProvider);
    return repo.getFlatByResidentId(residentId);
});

// Property by ID (Future) - reused from repository if exists, or fetch specific
final propertyByIdProvider = FutureProvider.family<PropertyModel?, String>((ref, propertyId) async {
  // We can just fetch it from firestore directly via repo if we add a method, 
  // or use the existing list if already loaded (but that's complex to coordinate).
  // Let's add a getProperty method to repo or just fetch here for simplicity if repo doesn't have it.
  // Actually, let's add it to the repo to be clean.
  final repo = ref.watch(ownerDashboardRepositoryProvider);
  return repo.getProperty(propertyId);
});
