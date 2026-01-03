import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../modules/dashboard/view/dashboard_page.dart';
import '../../modules/inventory/view/inventory_page.dart';
import '../../modules/inventory/view/inventory_form.dart';
import '../../modules/orders/view/orders_page.dart';
import '../../modules/orders/view/order_form_page.dart';
import '../../modules/orders/view/order_detail_page.dart';
import '../../modules/analytics/view/analytics_page.dart';
import '../../modules/auth/view/login_page.dart';
import '../../modules/auth/view/register_page.dart';
import '../../modules/auth/interactor/auth_bloc.dart';
import '../../modules/auth/interactor/auth_state.dart';
import '../../modules/auth/domain/entities/user_profile.dart';
import '../widgets/app_shell.dart';
import '../../modules/inventory/domain/entities/tshirt.dart';
import '../../modules/orders/domain/entities/order.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class AuthStream extends ChangeNotifier {
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> _subscription;

  AuthStream(this.authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: AuthStream(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      if (!isLoggedIn) {
        return (isLoggingIn || isRegistering) ? null : '/login';
      }

      final user = authState.user;
      final isAdmin = user?.role == UserRole.admin;
      final location = state.uri.toString();

      // Access Control
      if ((location.startsWith('/dashboard') ||
              location.startsWith('/analytics')) &&
          !isAdmin) {
        return '/inventory'; // Redirect Users to Shop
      }

      // Initial Landing Redirect
      if (isLoggingIn || isRegistering) {
        return isAdmin ? '/dashboard' : '/inventory';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryPage(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersPage(),
          ),
        ],
      ),
      // Full-screen routes outside the ShellRoute
      GoRoute(
        path: '/inventory/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const InventoryFormPage(),
      ),
      GoRoute(
        path: '/inventory/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final tshirt = state.extra as TShirt?;
          return InventoryFormPage(tshirt: tshirt);
        },
      ),
      GoRoute(
        path: '/orders/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OrderFormPage(),
      ),
      GoRoute(
        path: '/orders/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final order = state.extra as Order?;
          return OrderFormPage(order: order);
        },
      ),
      GoRoute(
        path: '/orders/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailPage(orderId: orderId);
        },
      ),
    ],
  );
}
