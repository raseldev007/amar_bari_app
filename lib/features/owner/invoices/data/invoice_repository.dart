import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/invoice_model.dart';
import '../../../../models/flat_model.dart';
import '../../../../models/lease_model.dart';

abstract class InvoiceRepository {
  Future<void> generateMonthlyInvoices(String ownerId); // The heavy lifter
  Stream<List<InvoiceModel>> getOwnerInvoices(String ownerId, {String? monthKey});
  Stream<List<InvoiceModel>> getResidentInvoices(String residentId);
  Future<void> markAsPaid(String invoiceId, double amount);
  Future<void> sendReminder(String invoiceId, String tenantId, String monthKey);
}

class FirestoreInvoiceRepository implements InvoiceRepository {
  final FirebaseFirestore _firestore;

  FirestoreInvoiceRepository(this._firestore);

  @override
  Future<void> generateMonthlyInvoices(String ownerId) async {
    // 1. Get all occupied flats for this owner
    final flatsSnapshot = await _firestore
        .collection('flats')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'occupied')
        .get();

    final currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());
    final batch = _firestore.batch();
    int batchCount = 0;

    for (var doc in flatsSnapshot.docs) {
      final flat = FlatModel.fromJson(doc.data());
      if (flat.currentLeaseId == null) continue;

      // Check if invoice already exists for this month & flat
      final existingInvoice = await _firestore
          .collection('invoices')
          .where('flatId', isEqualTo: flat.id)
          .where('monthKey', isEqualTo: currentMonthKey)
          .limit(1)
          .get();

      if (existingInvoice.docs.isNotEmpty) continue; // Already generated

      // Get the lease to find residentId
      final leaseDoc = await _firestore.collection('leases').doc(flat.currentLeaseId).get();
      if (!leaseDoc.exists) continue;
      final lease = LeaseModel.fromJson(leaseDoc.data()!);

      // Calculate totals
      double total = flat.rentBase;
      final items = <InvoiceItem>[
        InvoiceItem(key: 'Rent', amount: flat.rentBase),
      ];
      flat.utilities.forEach((key, value) {
        total += value;
        items.add(InvoiceItem(key: key, amount: value));
      });

      // Calculate Due Date (e.g. 5th of this month)
      final now = DateTime.now();
      final dueDate = DateTime(now.year, now.month, flat.dueDay);

      final newInvoice = InvoiceModel(
        id: const Uuid().v4(),
        ownerId: ownerId,
        residentId: lease.residentId,
        propertyId: flat.propertyId,
        flatId: flat.id,
        leaseId: lease.id,
        monthKey: currentMonthKey,
        items: items,
        totalAmount: total,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        status: 'due',
      );

      batch.set(_firestore.collection('invoices').doc(newInvoice.id), newInvoice.toJson());
      batchCount++;
    }

    if (batchCount > 0) {
      await batch.commit();
    }
  }

  @override
  Stream<List<InvoiceModel>> getOwnerInvoices(String ownerId, {String? monthKey}) {
    Query query = _firestore
        .collection('invoices')
        .where('ownerId', isEqualTo: ownerId);
        // .orderBy('createdAt', descending: true); // Removing orderBy to avoid index issues with complex filters for now
    
    if (monthKey != null) {
      query = query.where('monthKey', isEqualTo: monthKey);
    }

    // Client-side sort is safer for MVP until indexes are deployed
    return query.snapshots().map((s) {
       final list = s.docs.map((d) => InvoiceModel.fromJson(d.data() as Map<String, dynamic>)).toList();
       list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
       return list;
    });
  }

  @override
  Stream<List<InvoiceModel>> getResidentInvoices(String residentId) {
    return _firestore
        .collection('invoices')
        .where('residentId', isEqualTo: residentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => InvoiceModel.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<InvoiceModel>> getFlatInvoices(String flatId) {
    return _firestore
        .collection('invoices')
        .where('flatId', isEqualTo: flatId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => InvoiceModel.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  @override
  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    await _firestore.collection('invoices').doc(invoiceId).update({'status': status});
  }

  @override
  Future<void> markAsPaid(String invoiceId, double amount) async {
     // Also could add transaction logic to record filtered payment, but simple update for MVP
     await _firestore.collection('invoices').doc(invoiceId).update({
       'status': 'paid',
       'paidAt': FieldValue.serverTimestamp(),
     });
  }

  @override
  Future<void> sendReminder(String invoiceId, String tenantId, String monthKey) async {
    final batch = _firestore.batch();
    
    // Update invoice
    batch.update(_firestore.collection('invoices').doc(invoiceId), {
      'lastReminderAt': FieldValue.serverTimestamp(),
    });

    // Create notification
    final notificationRef = _firestore.collection('notifications').doc();
    batch.set(notificationRef, {
      'id': notificationRef.id,
      'userId': tenantId,
      'title': 'Rent Due Reminder',
      'message': 'Your rent for $monthKey is pending. Please pay at your earliest convenience.',
      'type': 'reminder',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return FirestoreInvoiceRepository(FirebaseFirestore.instance);
});

final ownerInvoicesProvider = StreamProvider.family<List<InvoiceModel>, String>((ref, ownerId) {
  return ref.watch(invoiceRepositoryProvider).getOwnerInvoices(ownerId);
});

final residentInvoicesProvider = StreamProvider.family<List<InvoiceModel>, String>((ref, residentId) {
  return ref.watch(invoiceRepositoryProvider).getResidentInvoices(residentId);
});

final flatInvoicesProvider = StreamProvider.family<List<InvoiceModel>, String>((ref, flatId) {
  return (ref.watch(invoiceRepositoryProvider) as FirestoreInvoiceRepository).getFlatInvoices(flatId);
});
