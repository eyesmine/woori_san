import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/plan_screen.dart';
import '../screens/stamp_screen.dart';
import '../screens/map_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/mountain_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/record_create_screen.dart';
import '../screens/tracking_screen.dart';
import '../screens/search_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/partner_screen.dart';
import '../screens/record_detail_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/sos_settings_screen.dart';
import '../screens/offline_map_settings_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/badge_screen.dart';
import '../theme/app_theme.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plan',
                builder: (context, state) => const PlanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stamp',
                builder: (context, state) => const StampScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/mountain/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)?.invalidAccess ?? 'Invalid access.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => GoRouter.of(context).go('/home'),
                      child: const Text('홈으로'),
                    ),
                  ],
                ),
              ),
            );
          }
          return MountainDetailScreen(mountainId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/record/new',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RecordCreateScreen(),
      ),
      GoRoute(
        path: '/tracking',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => TrackingScreen(
          mountainId: state.uri.queryParameters['mountainId'],
        ),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/favorites',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/partner',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PartnerScreen(),
      ),
      GoRoute(
        path: '/mountain/:id/reviews',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReviewsScreen(mountainId: id);
        },
      ),
      GoRoute(
        path: '/sos-settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SosSettingsScreen(),
      ),
      GoRoute(
        path: '/offline-maps',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OfflineMapSettingsScreen(),
      ),
      GoRoute(
        path: '/badges',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BadgeScreen(),
      ),
      GoRoute(
        path: '/statistics',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/record/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RecordDetailScreen(recordId: id);
        },
      ),
    ],
  );
}

class ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.surfaceDark
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.landscape_outlined,
                  activeIcon: Icons.landscape,
                  label: l.tabHome,
                  index: 0,
                  currentIndex: navigationShell.currentIndex,
                  onTap: (i) => navigationShell.goBranch(i),
                ),
                _NavItem(
                  icon: Icons.event_outlined,
                  activeIcon: Icons.event,
                  label: l.tabPlan,
                  index: 1,
                  currentIndex: navigationShell.currentIndex,
                  onTap: (i) => navigationShell.goBranch(i),
                ),
                _NavItem(
                  icon: Icons.military_tech_outlined,
                  activeIcon: Icons.military_tech,
                  label: l.tabStamp,
                  index: 2,
                  currentIndex: navigationShell.currentIndex,
                  onTap: (i) => navigationShell.goBranch(i),
                ),
                _NavItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: l.tabMap,
                  index: 3,
                  currentIndex: navigationShell.currentIndex,
                  onTap: (i) => navigationShell.goBranch(i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color = isActive ? AppTheme.primary : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
