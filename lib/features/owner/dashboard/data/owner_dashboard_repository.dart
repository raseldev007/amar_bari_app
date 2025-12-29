
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/property_model.dart';
import '../../../../models/flat_model.dart';
import '../../../../models/user_model.dart';
import '../../../../models/tenant_profile_model.dart';

class OwnerDashboardRepository {
  final FirebaseFirestore _firestore;

  OwnerDashboardRepository(this._firestore);

  // Get properties for owner
  Stream<List<PropertyModel>> getProperties(String ownerId) {
    return _firestore
        .collection('properties')
        .where('ownerId', isEqualTo: ownerId)
        // .orderBy('createdAt', descending: true) // Moved to client-side to avoid composite index
        .snapshots()
        .map((snapshot) {
           final list = snapshot.docs.map((doc) => PropertyModel.fromJson(doc.data())).toList();
           list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
           return list;
        });
  }

  // Get flats for a property (for calculating counts)
  Stream<List<FlatModel>> getFlatsForProperty(String propertyId) {
    return _firestore
        .collection('flats')
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlatModel.fromJson(doc.data()))
            .toList());
  }

  // Get recent assigned flats for owner (across all properties)
  Stream<List<FlatModel>> getRecentAssignedFlats(String ownerId) {
    // Requires composite index: ownerId ASC, residentId ASC, createdAt DESC
    // Also we filter where residentId != null (which in Firestore means order by residentId)
    // Actually, simply filtering by status == 'occupied' might be better if we mostly rely on that.
    // However, requirements said "residentId != null".
    // Let's use status == 'occupied' AND residentId != null if possible.
    // Query: ownerId == X, status == 'occupied', orderBy createdAt desc.

    return _firestore
        .collection('flats')
        .where('ownerId', isEqualTo: ownerId)
        // .where('status', isEqualTo: 'occupied') // Move to client-side to ensure data fetch
        .snapshots()
        .map((snapshot) {
           final flats = snapshot.docs
            .map((doc) => FlatModel.fromJson(doc.data()))
            .where((flat) => flat.status == 'occupied' && flat.residentId != null) 
            .toList();
           flats.sort((a, b) {
             final aTime = a.updatedAt ?? a.createdAt;
             final bTime = b.updatedAt ?? b.createdAt;
             return bTime.compareTo(aTime);
           });
           // Take top 20
           if (flats.length > 20) return flats.sublist(0, 20);
           return flats;
        });
  }

  // Get resident user profile
  Future<UserModel?> getResidentProfile(String residentId) async {
    final doc = await _firestore.collection('users').doc(residentId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  // Get tenant profile (verification docs)
  Future<TenantProfileModel?> getTenantProfile(String residentId) async {
    final doc = await _firestore.collection('tenant_profiles').doc(residentId).get();
    if (doc.exists && doc.data() != null) {
      return TenantProfileModel.fromJson(doc.data()!);
    }
    return null;
  }

  // Get flat assigned to a resident
  Future<FlatModel?> getFlatByResidentId(String residentId) async {
    final snapshot = await _firestore
        .collection('flats')
        .where('residentId', isEqualTo: residentId)
        .where('status', isEqualTo: 'occupied')
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      return FlatModel.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  // Get single property
  Future<PropertyModel?> getProperty(String propertyId) async {
    final doc = await _firestore.collection('properties').doc(propertyId).get();
    if (doc.exists && doc.data() != null) {
      return PropertyModel.fromJson(doc.data()!);
    }
    return null;
  }
}
