import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/flat_model.dart';
import '../../../auth/data/auth_repository.dart';

abstract class FlatRepository {
  Stream<List<FlatModel>> getPropertyFlats(String propertyId);
  Future<FlatModel?> getFlat(String flatId);
  Future<void> addFlat(FlatModel flat);
  Future<void> updateFlat(FlatModel flat);
  Future<void> deleteFlat(String flatId);
}

class FirestoreFlatRepository implements FlatRepository {
  final FirebaseFirestore _firestore;

  FirestoreFlatRepository(this._firestore);

  @override
  Stream<List<FlatModel>> getPropertyFlats(String propertyId) {
    return _firestore
        .collection('flats')
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('label') // e.g. 1A, 1B
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FlatModel.fromJson(doc.data())).toList();
    });
  }

  @override
  Future<FlatModel?> getFlat(String flatId) async {
    final doc = await _firestore.collection('flats').doc(flatId).get();
    if (!doc.exists) return null;
    return FlatModel.fromJson(doc.data()!);
  }

  @override
  Future<void> addFlat(FlatModel flat) async {
    await _firestore.collection('flats').doc(flat.id).set(flat.toJson());
  }

  @override
  Future<void> updateFlat(FlatModel flat) async {
    await _firestore.collection('flats').doc(flat.id).update(flat.toJson());
  }

  @override
  Future<void> deleteFlat(String flatId) async {
    await _firestore.collection('flats').doc(flatId).delete();
  }
}

final flatRepositoryProvider = Provider<FlatRepository>((ref) {
  return FirestoreFlatRepository(FirebaseFirestore.instance);
});

// Watch flats for a specific property
final propertyFlatsProvider = StreamProvider.family<List<FlatModel>, String>((ref, propertyId) {
  return ref.watch(flatRepositoryProvider).getPropertyFlats(propertyId);
});

// Fetch single flat (Future)
final flatDetailsProvider = FutureProvider.family<FlatModel?, String>((ref, flatId) {
  return ref.watch(flatRepositoryProvider).getFlat(flatId);
});
