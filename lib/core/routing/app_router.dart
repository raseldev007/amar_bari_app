import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/user_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/owner/dashboard/owner_dashboard_screen.dart';
import '../../features/owner/properties/presentation/add_edit_property_screen.dart';
import '../../features/owner/properties/presentation/property_details_screen.dart';
import '../../features/owner/flats/presentation/add_edit_flat_screen.dart';
import '../../features/owner/flats/presentation/flat_details_screen.dart';
import '../../features/owner/tenants/presentation/assign_tenant_screen.dart';
import '../../features/owner/invoices/presentation/invoice_detail_screen.dart';
import '../../features/owner/overview/presentation/owner_overview_screen.dart';
import '../../features/resident/payments/presentation/submit_payment_screen.dart';
import 'package:amar_bari/features/owner/flats/data/flat_repository.dart';
import 'package:amar_bari/features/owner/tenants/data/lease_repository.dart';
import 'package:amar_bari/features/owner/invoices/data/invoice_repository.dart';
import '../../models/flat_model.dart';
import '../../models/invoice_model.dart';
import '../../features/resident/home/resident_home_screen.dart';
import '../common_widgets/splash_screen.dart';
import '../../features/resident/documents/presentation/documents_screen.dart';
import '../../features/resident/payments/presentation/payment_history_screen.dart';
import '../../features/resident/support/presentation/support_screen.dart';
import '../../features/resident/profile/presentation/resident_profile_screen.dart';
import '../../features/support/presentation/contact_developer_screen.dart';

// Keys for navigation
final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfileAsync = ref.watch(userProfileProvider(ref.watch(authRepositoryProvider).currentUser?.uid ?? ''));

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authRepositoryProvider).currentUser != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSplash = state.uri.toString() == '/splash';

      // 1. Splash Screen Logic
      if (authState.isLoading || userProfileAsync.isLoading) {
        return '/splash';
      }

      // 2. Auth Guard
      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      // 3. Setup Logic (Role Selection)
      // Check if user has a role in Firestore
      final user = userProfileAsync.value;
      if (user == null) {
         // User logged in but no Firestore doc yet.
         // Redirect to setup/role selection which will create the doc if needed.
         return '/role_selection';
      }
      
      if (user != null && user.role.isEmpty) {
        return '/role_selection';
      }


      // 4. Role Guard
      // If we are logging in, or at splash, or at role selection, we might need redirection
      if (isLoggingIn || isSplash || state.uri.toString() == '/role_selection') {
         if (user != null && user.role.isNotEmpty) {
           if (user.role == 'owner') return '/owner';
           if (user.role == 'resident') return '/resident';
         }
      }

      // Prevent cross-role access
      if (user?.role == 'owner' && state.uri.toString().startsWith('/resident')) {
        return '/owner';
      }
      if (user?.role == 'resident' && state.uri.toString().startsWith('/owner')) {
        return '/resident';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role_selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/contact_developer',
        builder: (context, state) => const ContactDeveloperScreen(),
      ),
      GoRoute(
        path: '/owner',
        builder: (context, state) => const OwnerDashboardScreen(),
        routes: [
           GoRoute(
             path: 'overview',
             builder: (context, state) => const OwnerOverviewScreen(),
           ),
           GoRoute(
             path: 'add_property',
             builder: (context, state) => const AddEditPropertyScreen(),
           ),
           GoRoute(
             path: 'property/:propertyId',
             builder: (context, state) => PropertyDetailsScreen(
               propertyId: state.pathParameters['propertyId']!,
             ),
             routes: [
               GoRoute(
                 path: 'add_flat',
                 builder: (context, state) => AddEditFlatScreen(
                   propertyId: state.pathParameters['propertyId']!,
                 ),
               ),
               GoRoute(
                 path: 'flat/:flatId',
                 builder: (context, state) {
                    final flat = state.extra as FlatModel?;
                    return FlatDetailScreen(
                      propertyId: state.pathParameters['propertyId']!,
                      flatId: state.pathParameters['flatId']!,
                      initialFlat: flat,
                    );
                 },
                 routes: [
                   GoRoute(
                     path: 'assign_tenant',
                     builder: (context, state) {
                       final flat = state.extra as FlatModel;
                       return AssignTenantScreen(
                         propertyId: state.pathParameters['propertyId']!,
                         flatId: state.pathParameters['flatId']!,
                         flat: flat,
                       );
                     },
                   ),
                   GoRoute(
                     path: 'invoice/:invoiceId',
                     builder: (context, state) {
                       final invoice = state.extra as InvoiceModel;
                       return InvoiceDetailScreen(invoice: invoice);
                     },
                   ),
                 ]
               ),
             ]
           ),
        ],
      ),
      GoRoute(
        path: '/resident',
        builder: (context, state) => const ResidentHomeScreen(),
        routes: [
           GoRoute(
             path: 'payment',
             builder: (context, state) {
               final invoice = state.extra as InvoiceModel;
               return SubmitPaymentScreen(invoice: invoice);
             }
           ),
           GoRoute(
             path: 'documents',
             builder: (context, state) => const DocumentsScreen(),
           ),
           GoRoute(
             path: 'history',
             builder: (context, state) => const PaymentHistoryScreen(),
           ),
           GoRoute(
             path: 'support',
             builder: (context, state) => const SupportScreen(),
           ),
           GoRoute(
             path: 'service',
             builder: (context, state) => const SupportScreen(requestType: 'service'),
           ),
           GoRoute(
             path: 'profile',
             builder: (context, state) => const ResidentProfileScreen(),
           ),
        ],
      ),
    ],
  );
});
