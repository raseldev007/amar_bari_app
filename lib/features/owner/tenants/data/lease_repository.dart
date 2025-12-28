import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/lease_model.dart';
import '../../../../models/flat_model.dart';

abstract class LeaseRepository {
  Future<void> createLease(LeaseModel lease, FlatModel flat);
  Future<LeaseModel?> getActiveLease(String flatId);
  Future<void> endLease(String leaseId, String flatId);
}

class FirestoreLeaseRepository implements LeaseRepository {
  final FirebaseFirestore _firestore;

  FirestoreLeaseRepository(this._firestore);

  @override
  Future<void> createLease(LeaseModel lease, FlatModel flat) async {
    final batch = _firestore.batch();

    // 1. Create Lease Doc
    final leaseRef = _firestore.collection('leases').doc(lease.id);
    batch.set(leaseRef, lease.toJson());

    // 2. Update Flat Status and currentLeaseId
    final flatRef = _firestore.collection('flats').doc(flat.id);
    batch.update(flatRef, {
      'status': 'occupied',
      'currentLeaseId': lease.id,
    });

    // 3. Update Resident User Doc (Assigned IDs)
    final userRef = _firestore.collection('users').doc(lease.residentId);
    batch.update(userRef, {
      'assignedFlatId': flat.id,
      'assignedPropertyId': flat.propertyId,
    });

    await batch.commit();
  }

  @override
  Future<LeaseModel?> getActiveLease(String flatId) async {
    final query = await _firestore
        .collection('leases')
        .where('flatId', isEqualTo: flatId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return LeaseModel.fromJson(query.docs.first.data());
  }

  @override
  Future<void> endLease(String leaseId, String flatId) async {
    final batch = _firestore.batch();

    // 1. Mark Lease as ended
    final leaseRef = _firestore.collection('leases').doc(leaseId);
    batch.update(leaseRef, {
      'status': 'ended',
      'endDate': Timestamp.now(),
    });

    // 2. Update Flat to vacant
    final flatRef = _firestore.collection('flats').doc(flatId);
    batch.update(flatRef, {
      'status': 'vacant',
      'currentLeaseId': FieldValue.delete(), // Remove the field or set null
    });

    await batch.commit();
  }
}

final leaseRepositoryProvider = Provider<LeaseRepository>((ref) {
  return FirestoreLeaseRepository(FirebaseFirestore.instance);
});

final activeLeaseProvider = FutureProvider.family<LeaseModel?, String>((ref, flatId) {
  return ref.watch(leaseRepositoryProvider).getActiveLease(flatId);
});
