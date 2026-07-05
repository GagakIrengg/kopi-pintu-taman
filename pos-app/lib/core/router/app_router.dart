import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/pos/screens/pos_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/menu_management/screens/menu_management_screen.dart';
import '../../features/recipe/screens/recipe_screen.dart';
import '../../features/sales_report/screens/sales_report_screen.dart';
import '../../features/sales_report/screens/transaction_detail_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

// KAS
import '../../features/opening_cash/screens/cash_screen.dart';

import '../../providers/auth_provider.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/pos/screens/payment_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = ref.read(authProvider).isLoggedIn;
      final goingToLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingToLogin) return '/login';
      if (loggedIn && goingToLogin) return '/pos';
      return null;
    },
    routes: [
      // LOGIN
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),

      // PAYMENT (POS FLOW)
      GoRoute(
        path: '/payment',
        builder: (_, state) {
          final total = state.extra as int? ?? 0;
          return PaymentScreen(total: total);
        },
      ),

      // MAIN APP SHELL (SIDEBAR)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // 1. POS
          GoRoute(
            path: '/pos',
            builder: (_, __) => const PosScreen(),
          ),

          // 2. MANAJEMEN MENU
          GoRoute(
            path: '/menu-management',
            builder: (_, __) => const MenuManagementScreen(),
          ),

          // 3. RESEP (Bahan Olahan + Resep Menu)
          GoRoute(
            path: '/recipe',
            builder: (_, __) => const RecipeScreen(),
          ),

          // 4. SALES REPORT
          GoRoute(
            path: '/reports',
            builder: (_, __) => const SalesReportScreen(),
          ),
          GoRoute(
            path: '/reports/:id',
            builder: (_, state) => TransactionDetailScreen(
              transactionId: state.pathParameters['id']!,
            ),
          ),

          // 5. INVENTORY
          GoRoute(
            path: '/inventory',
            builder: (_, __) => const InventoryScreen(),
          ),

          // 6. KAS
          GoRoute(
            path: '/cash',
            builder: (_, __) => const CashScreen(),
          ),

          // 7. LAPORAN / DASHBOARD
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),

          // 8. SETTINGS
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});