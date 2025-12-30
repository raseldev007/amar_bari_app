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
import '../../features/owner/invoices/presentation/owner_invoice_list_screen.dart';
import '../../features/owner/invoices/presentation/add_invoice_screen.dart';
import '../../features/owner/overview/presentation/owner_overview_screen.dart';
import '../../features/resident/payments/presentation/submit_payment_screen.dart';
import '../../features/resident/payments/presentation/bkash_payment_screen.dart';
import 'package:amar_bari/features/owner/flats/data/flat_repository.dart';
import 'package:amar_bari/features/owner/tenants/data/lease_repository.dart';
import 'package:amar_bari/features/owner/invoices/data/invoice_repository.dart';
import '../../models/flat_model.dart';
import '../../models/property_model.dart';
import '../../models/invoice_model.dart';
import '../../features/resident/home/resident_home_screen.dart';
import '../common_widgets/splash_screen.dart';
import '../../features/resident/documents/presentation/documents_screen.dart';
import '../../features/resident/payments/presentation/payment_history_screen.dart';
import '../../features/resident/support/presentation/support_screen.dart';
import '../../features/resident/profile/presentation/resident_profile_screen.dart';
import '../../features/support/presentation/contact_developer_screen.dart';
import '../../features/owner/dashboard/presentation/resident_details_screen.dart';
import '../../features/owner/dashboard/presentation/owner_payment_history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

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
             routes: [
               GoRoute(
                 path: 'filtered',
                 builder: (context, state) {
                    final extras = state.extra as Map<String, dynamic>;
                    return OwnerInvoiceListScreen(
                      title: extras['title'] as String,
                      invoices: extras['invoices'] as List<InvoiceModel>,
                    );
                 },
               ),
             ],
           ),
           GoRoute(
             path: 'add_property',
             builder: (context, state) => AddEditPropertyScreen(property: state.extra as PropertyModel?),
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
                    flat: state.extra as FlatModel?,
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
                     path: 'invoice/new',
                     builder: (context, state) {
                       final extra = state.extra as Map<String, dynamic>?;
                       return AddInvoiceScreen(
                         propertyId: state.pathParameters['propertyId']!,
                         flatId: state.pathParameters['flatId']!,
                         requestId: extra?['requestId'] as String?,
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
           GoRoute(
             path: 'residents/:residentId',
             builder: (context, state) {
               final flat = state.extra as FlatModel?;
               return ResidentDetailsScreen(
                 residentId: state.pathParameters['residentId']!,
                 flatExtra: flat,
               );
             },
             routes: [
               GoRoute(
                 path: 'history',
                 builder: (context, state) {
                   final extras = state.extra as Map<String, dynamic>;
                   return OwnerPaymentHistoryScreen(
                     residentId: state.pathParameters['residentId']!,
                     residentName: extras['name'] as String,
                   );
                 },
               ),
             ],
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
               InvoiceModel? invoice;
               String? ownerId;
               
               if (state.extra is InvoiceModel) {
                 invoice = state.extra as InvoiceModel;
               } else if (state.extra is Map<String, dynamic>) {
                 final extra = state.extra as Map<String, dynamic>;
                 invoice = extra['invoice'] as InvoiceModel?;
                 ownerId = extra['ownerId'] as String?;
               }
               
               return SubmitPaymentScreen(invoice: invoice, ownerId: ownerId);
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
            GoRoute(
              path: 'bkash_payment',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return BkashPaymentScreen(
                  invoiceId: extra['invoiceId'] as String,
                  amount: extra['amount'] as double,
                );
              },
            ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
