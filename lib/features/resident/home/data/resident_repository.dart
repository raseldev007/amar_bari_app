import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/flat_model.dart';
import '../../../../models/property_model.dart';
import '../../../../models/user_model.dart';
import '../../../../models/invoice_model.dart';

enum ResidentHomeState {
  notAssigned, // users.assignedFlatId == null
  assignedNoInvoice, // assignedFlatId != null, but no invoice for current month
  invoiceExists, // invoice found for current month
}

class ResidentDashboardData {
  final ResidentHomeState state;
  final UserModel? user;
  final FlatModel? flat;
  final PropertyModel? property;
  final InvoiceModel? currentInvoice;
  final double outstandingAmount;

  ResidentDashboardData({
    required this.state,
    this.user,
    this.flat,
    this.property,
    this.currentInvoice,
    this.outstandingAmount = 0.0,
  });
}

abstract class ResidentRepository {
  Future<ResidentDashboardData> getDashboardData(String uid);
}

class FirestoreResidentRepository implements ResidentRepository {
  final FirebaseFirestore _firestore;

  FirestoreResidentRepository(this._firestore);

  @override
  Future<ResidentDashboardData> getDashboardData(String uid) async {
    try {
      // 1. Load Current User (Resident)
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return ResidentDashboardData(state: ResidentHomeState.notAssigned);
      }
      final user = UserModel.fromJson(userDoc.data()!);

      // STATE 1: Not Assigned
      if (user.assignedFlatId == null || user.assignedFlatId!.isEmpty) {
        return ResidentDashboardData(state: ResidentHomeState.notAssigned, user: user);
      }

      // 2. Load Assigned Flat
      final flatDoc = user.assignedFlatId != null ? await _firestore.collection('flats').doc(user.assignedFlatId).get() : null;
      final flat = flatDoc != null && flatDoc.exists ? FlatModel.fromJson(flatDoc.data()!) : null;

      // 3. Load Property
      PropertyModel? property;
      String? propertyId = flat?.propertyId ?? user.assignedPropertyId;
      
      if (propertyId != null && propertyId.isNotEmpty) {
        final propertyDoc = await _firestore.collection('properties').doc(propertyId).get();
        if (propertyDoc.exists) {
          property = PropertyModel.fromJson(propertyDoc.data()!);
        }
      }

      // 4. Calculate Outstanding Dues (Fetch ALL invoices for this tenant)
      // We fetch all because we need to sum up everything unpaid.
      final allInvoicesQuery = await _firestore
          .collection('invoices')
          .where('tenantId', isEqualTo: uid)
          .get();
      
      double totalOutstanding = 0.0;
      InvoiceModel? currentMonthInvoice;
      final currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());

      for (var doc in allInvoicesQuery.docs) {
        final inv = InvoiceModel.fromJson(doc.data());
        
        // Check for current month invoice
        if (inv.monthKey == currentMonthKey) {
          currentMonthInvoice = inv;
        }

        // Add to outstanding if not paid
        if (inv.status != 'paid') {
          totalOutstanding += inv.totalAmount;
        }
      }

      // Determine State
      ResidentHomeState state = ResidentHomeState.assignedNoInvoice;
      if (currentMonthInvoice != null) {
        state = ResidentHomeState.invoiceExists;
      }

      return ResidentDashboardData(
        state: state,
        user: user,
        flat: flat,
        property: property,
        currentInvoice: currentMonthInvoice,
        outstandingAmount: totalOutstanding,
      );

    } catch (e) {
      // Handle errors gracefully, maybe return a specific error state or rethrow
      print('Error fetching resident dashboard data: $e');
      return ResidentDashboardData(state: ResidentHomeState.notAssigned); 
    }
  }
}

final residentRepositoryProvider = Provider<ResidentRepository>((ref) {
  return FirestoreResidentRepository(FirebaseFirestore.instance);
});

final residentDashboardDataProvider = FutureProvider.family<ResidentDashboardData, String>((ref, uid) {
  return ref.watch(residentRepositoryProvider).getDashboardData(uid);
});

