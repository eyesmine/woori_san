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
import 'core/di.dart';
import 'core/logger.dart';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
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

  await _initializeApp();

  // DI 초기화
  DI.initialize();

  // Router
  final router = createRouter(DI.authProvider);

  runApp(
    MultiProvider(
      providers: DI.providers,
      child: WooriSanApp(router: router),
    ),
  );

  // 푸시 알림 초기화 (runApp 이후)
  NotificationService(apiClient: DI.apiClient, router: router).initialize();
}

Future<void> _initializeApp() async {
  // 환경 변수 로드
  try {
    await dotenv.load(fileName: '.env.example');
  } catch (e) {
    AppLogger.warning('.env.example 로드 실패', tag: 'Init', error: e);
  }

  // 한국어 로케일 초기화
  try {
    await initializeDateFormatting('ko_KR');
  } catch (e) {
    AppLogger.warning('로케일 초기화 실패', tag: 'Init', error: e);
  }

  // Hive 초기화
  try {
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
  } catch (e) {
    AppLogger.error('Hive 초기화 실패', tag: 'Init', error: e);
  }

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    AppLogger.warning('Firebase 초기화 실패', tag: 'Init', error: e);
  }

  // Naver Map 초기화
  try {
    final naverKey = AppConstants.naverMapClientId;
    if (naverKey.isNotEmpty && naverKey != 'YOUR_NAVER_MAP_CLIENT_ID') {
      await FlutterNaverMap().init(clientId: naverKey);
    }
  } catch (e) {
    AppLogger.warning('Naver Map 초기화 실패', tag: 'Init', error: e);
  }
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
