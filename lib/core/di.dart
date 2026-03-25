import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'api_client.dart';
import '../datasources/local/mountain_local.dart';
import '../datasources/local/stamp_local.dart';
import '../datasources/local/plan_local.dart';
import '../datasources/local/weather_local.dart';
import '../datasources/local/favorite_local.dart';
import '../datasources/local/review_local.dart';
import '../datasources/local/badge_local.dart';
import '../datasources/remote/auth_remote.dart';
import '../datasources/remote/mountain_remote.dart';
import '../datasources/remote/plan_remote.dart';
import '../datasources/remote/stamp_remote.dart';
import '../datasources/remote/weather_remote.dart';
import '../datasources/remote/review_remote.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mountain_repository.dart';
import '../repositories/stamp_repository.dart';
import '../repositories/plan_repository.dart';
import '../repositories/weather_repository.dart';
import '../repositories/review_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/mountain_provider.dart';
import '../providers/plan_provider.dart';
import '../providers/stamp_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/location_provider.dart';
import '../providers/tracking_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/review_provider.dart';
import '../providers/badge_provider.dart';
import '../services/location_service.dart';

class DI {
  DI._();

  static late final AuthProvider authProvider;

  static void initialize() {
    final apiClient = ApiClient();

    // Remote DataSources
    final authRemote = AuthRemoteDataSource(apiClient);
    final mountainRemote = MountainRemoteDataSource(apiClient);
    final planRemote = PlanRemoteDataSource(apiClient);
    final stampRemote = StampRemoteDataSource(apiClient);
    final weatherRemote = WeatherRemoteDataSource();
    final reviewRemote = ReviewRemoteDataSource(apiClient);

    // Local DataSources
    final mountainLocal = MountainLocalDataSource();
    final stampLocal = StampLocalDataSource();
    final planLocal = PlanLocalDataSource();
    final weatherLocal = WeatherLocalDataSource();
    final favoriteLocal = FavoriteLocalDataSource();
    final reviewLocal = ReviewLocalDataSource();
    BadgeLocalDataSource(); // 초기화만 수행

    // Repositories
    _authRepo = AuthRepository(authRemote, apiClient);
    _mountainRepo = MountainRepository(mountainLocal, mountainRemote);
    _stampRepo = StampRepository(stampLocal, stampRemote);
    _planRepo = PlanRepository(planLocal, planRemote);
    _weatherRepo = WeatherRepository(weatherLocal, weatherRemote);
    _reviewRepo = ReviewRepository(reviewLocal, reviewRemote);

    // Services
    _locationService = LocationService();
    _favoriteLocal = favoriteLocal;

    // Auth Provider (라우터에서도 사용)
    authProvider = AuthProvider(_authRepo)..checkSession();

    _apiClient = apiClient;
  }

  static late final ApiClient _apiClient;
  static late final AuthRepository _authRepo;
  static late final MountainRepository _mountainRepo;
  static late final StampRepository _stampRepo;
  static late final PlanRepository _planRepo;
  static late final WeatherRepository _weatherRepo;
  static late final ReviewRepository _reviewRepo;
  static late final LocationService _locationService;
  static late final FavoriteLocalDataSource _favoriteLocal;

  static ApiClient get apiClient => _apiClient;

  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider.value(value: authProvider),
    ChangeNotifierProvider(create: (_) => MountainProvider(_mountainRepo, _planRepo)),
    ChangeNotifierProvider(create: (_) => PlanProvider(_planRepo)),
    ChangeNotifierProvider(create: (_) => StampProvider(_stampRepo)),
    ChangeNotifierProvider(create: (_) => WeatherProvider(_weatherRepo)),
    ChangeNotifierProvider(create: (_) => LocationProvider(_locationService)),
    ChangeNotifierProvider(create: (_) => TrackingProvider(_locationService)),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => FavoriteProvider(_favoriteLocal)),
    ProxyProvider<MountainProvider, StatisticsProvider>(
      update: (_, mountain, __) => StatisticsProvider(records: mountain.records),
    ),
    ChangeNotifierProvider(create: (_) => ReviewProvider(_reviewRepo)),
    ProxyProvider3<MountainProvider, StampProvider, AuthProvider, BadgeProvider>(
      update: (_, mountain, stamp, auth, __) => BadgeProvider(
        records: mountain.records,
        stamps: stamp.stamps,
        joinDate: auth.user?.createdAt,
      ),
    ),
  ];
}
