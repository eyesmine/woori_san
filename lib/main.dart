import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'core/constants.dart';
import 'core/api_client.dart';
import 'datasources/local/mountain_local.dart';
import 'datasources/local/stamp_local.dart';
import 'datasources/local/plan_local.dart';
import 'datasources/local/weather_local.dart';
import 'datasources/remote/auth_remote.dart';
import 'datasources/remote/mountain_remote.dart';
import 'datasources/remote/plan_remote.dart';
import 'datasources/remote/stamp_remote.dart';
import 'datasources/remote/weather_remote.dart';
import 'repositories/mountain_repository.dart';
import 'repositories/stamp_repository.dart';
import 'repositories/plan_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/weather_repository.dart';
import 'providers/mountain_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/stamp_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/location_provider.dart';
import 'providers/tracking_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/review_provider.dart';
import 'providers/badge_provider.dart';
import 'datasources/remote/review_remote.dart';
import 'datasources/local/review_local.dart';
import 'repositories/review_repository.dart';
import 'datasources/local/favorite_local.dart';
import 'datasources/local/badge_local.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 환경 변수 로드 (.env.example 에셋에서 로드)
  try {
    await dotenv.load(fileName: '.env.example');
  } catch (e) {
    debugPrint('.env.example 파일을 찾을 수 없습니다 — 기본값을 사용합니다: $e');
  }

  // 한국어 로케일 초기화
  await initializeDateFormatting('ko_KR');

  // Hive 초기화 (Box 열기 실패 시 앱 실행 불가 → 크래시 허용)
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox(AppConstants.cacheBox),
    Hive.openBox(AppConstants.stampBox),
    Hive.openBox(AppConstants.planBox),
    Hive.openBox(AppConstants.weatherBox),
    Hive.openBox(AppConstants.settingsBox),
    Hive.openBox(AppConstants.favoriteBox),
    Hive.openBox(AppConstants.reviewBox),
    Hive.openBox(AppConstants.badgeBox),
  ]);

  // Firebase 초기화 (google-services.json 없으면 스킵)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase 초기화 실패 — google-services.json / GoogleService-Info.plist 설정을 확인하세요: $e');
  }

  // Naver Map 초기화 (Client ID 미설정이면 스킵)
  final naverKey = AppConstants.naverMapClientId;
  if (naverKey.isNotEmpty && naverKey != 'YOUR_NAVER_MAP_CLIENT_ID') {
    try {
      await FlutterNaverMap().init(clientId: naverKey);
    } catch (e) {
      debugPrint('Naver Map 초기화 실패 — Client ID 설정을 확인하세요: $e');
    }
  }

  // ApiClient (싱글턴)
  final apiClient = ApiClient();

  // Remote DataSources
  final authRemote = AuthRemoteDataSource(apiClient);
  final mountainRemote = MountainRemoteDataSource(apiClient);
  final planRemote = PlanRemoteDataSource(apiClient);
  final stampRemote = StampRemoteDataSource(apiClient);
  final weatherRemote = WeatherRemoteDataSource();

  // Local DataSources
  final mountainLocal = MountainLocalDataSource();
  final stampLocal = StampLocalDataSource();
  final planLocal = PlanLocalDataSource();
  final weatherLocal = WeatherLocalDataSource();
  final favoriteLocal = FavoriteLocalDataSource();
  final reviewRemote = ReviewRemoteDataSource(apiClient);
  final reviewLocal = ReviewLocalDataSource();
  final reviewRepo = ReviewRepository(reviewLocal, reviewRemote);
  final badgeLocal = BadgeLocalDataSource();

  // Repositories
  final authRepo = AuthRepository(authRemote, apiClient);
  final mountainRepo = MountainRepository(mountainLocal, mountainRemote);
  final stampRepo = StampRepository(stampLocal, stampRemote);
  final planRepo = PlanRepository(planLocal, planRemote);
  final weatherRepo = WeatherRepository(weatherLocal, weatherRemote);

  // Services
  final locationService = LocationService();

  // Providers
  final authProvider = AuthProvider(authRepo)..checkSession();

  // Router
  final router = createRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MountainProvider(mountainRepo, planRepo)),
        ChangeNotifierProvider(create: (_) => PlanProvider(planRepo)),
        ChangeNotifierProvider(create: (_) => StampProvider(stampRepo)),
        ChangeNotifierProvider(create: (_) => WeatherProvider(weatherRepo)),
        ChangeNotifierProvider(create: (_) => LocationProvider(locationService)),
        ChangeNotifierProvider(create: (_) => TrackingProvider(locationService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider(favoriteLocal)),
        ChangeNotifierProvider(create: (_) => StatisticsProvider(planRepo)),
        ChangeNotifierProvider(create: (_) => ReviewProvider(reviewRepo)),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),
      ],
      child: WooriSanApp(router: router),
    ),
  );

  // 푸시 알림 초기화 (runApp 이후)
  NotificationService(apiClient: apiClient, router: router).initialize();
}

class WooriSanApp extends StatelessWidget {
  final GoRouter router;
  const WooriSanApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => MaterialApp.router(
        title: '우리산',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.themeMode,
        locale: settings.locale,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('ko'),
          Locale('en'),
        ],
      ),
    );
  }
}
