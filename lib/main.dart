import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'datasources/local/mountain_local.dart';
import 'datasources/local/stamp_local.dart';
import 'datasources/local/plan_local.dart';
import 'repositories/mountain_repository.dart';
import 'repositories/stamp_repository.dart';
import 'repositories/plan_repository.dart';
import 'providers/mountain_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/stamp_provider.dart';
import 'screens/home_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/stamp_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Hive 초기화
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.cacheBox);
  await Hive.openBox(AppConstants.stampBox);
  await Hive.openBox(AppConstants.planBox);

  // DataSources
  final mountainLocal = MountainLocalDataSource();
  final stampLocal = StampLocalDataSource();
  final planLocal = PlanLocalDataSource();

  // Repositories
  final mountainRepo = MountainRepository(mountainLocal);
  final stampRepo = StampRepository(stampLocal);
  final planRepo = PlanRepository(planLocal);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MountainProvider(mountainRepo, planRepo)),
        ChangeNotifierProvider(create: (_) => PlanProvider(planRepo)),
        ChangeNotifierProvider(create: (_) => StampProvider(stampRepo)),
      ],
      child: const WooriSanApp(),
    ),
  );
}

class WooriSanApp extends StatelessWidget {
  const WooriSanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리산',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PlanScreen(),
    StampScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                _NavItem(icon: Icons.landscape_outlined, activeIcon: Icons.landscape, label: '홈', index: 0, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.event_outlined, activeIcon: Icons.event, label: '계획', index: 1, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.military_tech_outlined, activeIcon: Icons.military_tech, label: '도장', index: 2, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
