import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/property_model.dart';
import '../../../auth/data/auth_repository.dart';

abstract class PropertyRepository {
  Stream<List<PropertyModel>> getOwnerProperties(String ownerId);
  Future<void> addProperty(PropertyModel property);
  Future<void> updateProperty(PropertyModel property);
  Future<void> deleteProperty(String propertyId);
}

class FirestorePropertyRepository implements PropertyRepository {
  final FirebaseFirestore _firestore;

  FirestorePropertyRepository(this._firestore);

  @override
  Stream<List<PropertyModel>> getOwnerProperties(String ownerId) {
    return _firestore
        .collection('properties')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final properties = snapshot.docs.map((doc) => PropertyModel.fromJson(doc.data())).toList();
      // Sort client-side to avoid composite index requirement
      properties.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return properties;
    });
  }

  @override
  Future<void> addProperty(PropertyModel property) async {
    await _firestore.collection('properties').doc(property.id).set(property.toJson());
  }

  @override
  Future<void> updateProperty(PropertyModel property) async {
    await _firestore.collection('properties').doc(property.id).update(property.toJson());
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    await _firestore.collection('properties').doc(propertyId).delete();
  }
}

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return FirestorePropertyRepository(FirebaseFirestore.instance);
});

final ownerPropertiesProvider = StreamProvider<List<PropertyModel>>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(propertyRepositoryProvider).getOwnerProperties(user.uid);
});
