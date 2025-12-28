import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_bari/models/request_model.dart';

class RequestRepository {
  final FirebaseFirestore _firestore;

  RequestRepository(this._firestore);

  Future<void> createRequest(RequestModel request) async {
    await _firestore.collection('requests').doc(request.id).set(request.toJson());
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status,
    });
  }

  Future<void> addResponse(String requestId, String response) async {
    await _firestore.collection('requests').doc(requestId).update({
      'response': response,
      'respondedAt': FieldValue.serverTimestamp(),
      'status': 'closed',
    });
  }

  Future<void> createNotification(Map<String, dynamic> data) async {
    await _firestore.collection('notifications').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Stream<List<RequestModel>> getOwnerRequests(String ownerId) {
    return _firestore
        .collection('requests')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map((doc) => RequestModel.fromJson(doc.data())).toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  Stream<List<RequestModel>> getResidentRequests(String tenantId) {
    return _firestore
        .collection('requests')
        .where('tenantId', isEqualTo: tenantId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map((doc) => RequestModel.fromJson(doc.data())).toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }
}

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepository(FirebaseFirestore.instance);
});

final ownerRequestsProvider = StreamProvider.family<List<RequestModel>, String>((ref, ownerId) {
  return ref.watch(requestRepositoryProvider).getOwnerRequests(ownerId);
});

final residentRequestsProvider = StreamProvider.family<List<RequestModel>, String>((ref, tenantId) {
  return ref.watch(requestRepositoryProvider).getResidentRequests(tenantId);
});
