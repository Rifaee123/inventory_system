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
import '../widgets/app_shell.dart';
import '../../domain/entities/tshirt.dart';
import '../../domain/entities/order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  // redirect: (context, state) {
  //   final session = Supabase.instance.client.auth.currentSession;
  //   final isLoggingIn = state.uri.toString() == '/login';
  //   final isRegistering = state.uri.toString() == '/register';

  //   if (session == null) {
  //     return (isLoggingIn || isRegistering) ? null : '/login';
  //   }

  //   if (isLoggingIn || isRegistering) {
  //     return '/dashboard';
  //   }

  //   return null;
  // },
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
