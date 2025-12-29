import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/payment_model.dart';

abstract class PaymentRepository {
  Future<void> submitPayment(PaymentModel payment);
  Future<void> confirmPayment(String paymentId, String invoiceId);
  Stream<List<PaymentModel>> getInvoicePayments(String invoiceId);
  Stream<List<PaymentModel>> getUserPayments(String residentId);
}

class FirestorePaymentRepository implements PaymentRepository {
  final FirebaseFirestore _firestore;

  FirestorePaymentRepository(this._firestore);

  @override
  Future<void> submitPayment(PaymentModel payment) async {
    await _firestore.collection('payments').doc(payment.id).set(payment.toJson());
  }

  @override
  Future<void> confirmPayment(String paymentId, String invoiceId) async {
    final batch = _firestore.batch();
    
    // 1. Update Payment Status
    batch.update(_firestore.collection('payments').doc(paymentId), {
      'status': 'confirmed',
      'confirmedAt': Timestamp.now(),
    });

    // 2. Update Invoice Status to PAID
    // In a real app, we might check if (sum(payments) >= invoiceTotal)
    // For MVP, one confirmed payment = Paid Invoice
    batch.update(_firestore.collection('invoices').doc(invoiceId), {
      'status': 'paid',
    });

    await batch.commit();
  }

  @override
  Stream<List<PaymentModel>> getInvoicePayments(String invoiceId) {
    return _firestore
        .collection('payments')
        .where('invoiceId', isEqualTo: invoiceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PaymentModel.fromJson(d.data())).toList());
  }

  @override
  Stream<List<PaymentModel>> getUserPayments(String residentId) {
    return _firestore
        .collection('payments')
        .where('residentId', isEqualTo: residentId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => PaymentModel.fromJson(d.data())).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return FirestorePaymentRepository(FirebaseFirestore.instance);
});

final invoicePaymentsProvider = StreamProvider.family<List<PaymentModel>, String>((ref, invoiceId) {
  return ref.watch(paymentRepositoryProvider).getInvoicePayments(invoiceId);
});

final userPaymentsProvider = StreamProvider.family<List<PaymentModel>, String>((ref, residentId) {
  return ref.watch(paymentRepositoryProvider).getUserPayments(residentId);
});
