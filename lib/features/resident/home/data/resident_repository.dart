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
  Stream<List<InvoiceModel>> getInvoicesStream(String uid);
  Future<InvoiceModel?> getInvoice(String invoiceId);
  
  // New Stream Methods
  Stream<UserModel?> getUserStream(String uid);
  Stream<FlatModel?> getFlatStream(String flatId);
  Stream<PropertyModel?> getPropertyStream(String propId);
}



class FirestoreResidentRepository implements ResidentRepository {
  final FirebaseFirestore _firestore;

  FirestoreResidentRepository(this._firestore);
  
  @override
  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    final doc = await _firestore.collection('invoices').doc(invoiceId).get();
    if (doc.exists) {
      return InvoiceModel.fromJson(doc.data()!);
    }
    return null;
  }

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

      final invoices = allInvoicesQuery.docs.map((doc) => InvoiceModel.fromJson(doc.data())).toList();
      // Sort by createdAt descending
      invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (var inv in invoices) {
        
        // Check for current month invoice (Pick latest)
        if (inv.monthKey == currentMonthKey && currentMonthInvoice == null) {
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

  @override
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) return UserModel.fromJson(doc.data()!);
      return null;
    });
  }

  @override
  Stream<FlatModel?> getFlatStream(String flatId) {
    return _firestore.collection('flats').doc(flatId).snapshots().map((doc) {
      if (doc.exists) return FlatModel.fromJson(doc.data()!);
      return null;
    });
  }

  @override
  Stream<PropertyModel?> getPropertyStream(String propId) {
    return _firestore.collection('properties').doc(propId).snapshots().map((doc) {
      if (doc.exists) return PropertyModel.fromJson(doc.data()!);
      return null;
    });
  }

  @override
  Stream<List<InvoiceModel>> getInvoicesStream(String uid) {
    return _firestore
        .collection('invoices')
        .where('tenantId', isEqualTo: uid)
        .snapshots() 
        .map((snapshot) {
      return snapshot.docs.map((doc) => InvoiceModel.fromJson(doc.data())).toList();
    });
  }
}

final residentRepositoryProvider = Provider<ResidentRepository>((ref) {
  return FirestoreResidentRepository(FirebaseFirestore.instance);
});

// Granular Stream Providers
final residentUserStreamProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return ref.watch(residentRepositoryProvider).getUserStream(uid);
});

final residentFlatStreamProvider = StreamProvider.family<FlatModel?, String>((ref, flatId) {
  return ref.watch(residentRepositoryProvider).getFlatStream(flatId);
});

final residentPropertyStreamProvider = StreamProvider.family<PropertyModel?, String>((ref, propId) {
  return ref.watch(residentRepositoryProvider).getPropertyStream(propId);
});

// Composite Provider for Dashboard Data (Refactored to be Reactive)
final residentDashboardDataProvider = Provider.family<AsyncValue<ResidentDashboardData>, String>((ref, uid) {
  final userAsync = ref.watch(residentUserStreamProvider(uid));

  return userAsync.when(
    data: (user) {
      if (user == null) {
        return AsyncData(ResidentDashboardData(state: ResidentHomeState.notAssigned));
      }

      if (user.assignedFlatId == null || user.assignedFlatId!.isEmpty) {
        return AsyncData(ResidentDashboardData(state: ResidentHomeState.notAssigned, user: user));
      }

      final flatAsync = ref.watch(residentFlatStreamProvider(user.assignedFlatId!));
      return flatAsync.when(
        data: (flat) {
          if (flat == null) {
             return AsyncData(ResidentDashboardData(state: ResidentHomeState.notAssigned, user: user));
          }

          final propAsync = ref.watch(residentPropertyStreamProvider(flat.propertyId));
          return propAsync.when(
            data: (property) {
              // Invoices are handled by a separate stream in the UI, so we just return the structure.
              // We return 'assignedNoInvoice' as default state, UI will upgrade it if invoices found.
              return AsyncData(ResidentDashboardData(
                state: ResidentHomeState.assignedNoInvoice, 
                user: user,
                flat: flat,
                property: property,
              ));
            },
            loading: () => const AsyncLoading(),
            error: (e, s) => AsyncError(e, s),
          );
        },
         loading: () => const AsyncLoading(),
         error: (e, s) => AsyncError(e, s),
      );
    },
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
  );
});

final residentInvoicesStreamProvider = StreamProvider.family<List<InvoiceModel>, String>((ref, uid) {
  return ref.watch(residentRepositoryProvider).getInvoicesStream(uid);
});

