import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/mountain.dart';
import '../models/hiking_record.dart';
import '../services/location_service.dart';

class TrackingProvider extends ChangeNotifier {
  final LocationService _locationService;

  List<Position> _routePoints = [];
  Duration _elapsed = Duration.zero;
  double _totalDistanceMeters = 0;
  bool _isActive = false;
  bool _isPaused = false;
  bool _summitReached = false;
  bool _summitDialogShown = false;
  Mountain? _currentMountain;
  Position? _lastPosition;
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;
  String? _error;

  TrackingProvider(this._locationService);

  List<Position> get routePoints => _routePoints;
  Duration get elapsed => _elapsed;
  double get totalDistanceMeters => _totalDistanceMeters;
  double get totalDistanceKm => _totalDistanceMeters / 1000;
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  bool get summitReached => _summitReached;
  bool get summitDialogShown => _summitDialogShown;
  Mountain? get currentMountain => _currentMountain;
  String? get error => _error;

  String get elapsedFormatted {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60);
    final s = _elapsed.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }

  String get speedKmh {
    if (_elapsed.inSeconds == 0) return '0.0';
    final kmPerHour = totalDistanceKm / (_elapsed.inSeconds / 3600);
    return kmPerHour.toStringAsFixed(1);
  }

  Future<void> start(Mountain? mountain) async {
    if (_isActive) return;

    _error = null;
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      _error = '위치 권한이 필요합니다';
      notifyListeners();
      return;
    }

    _currentMountain = mountain;
    _routePoints = [];
    _elapsed = Duration.zero;
    _totalDistanceMeters = 0;
    _isActive = true;
    _isPaused = false;
    _summitReached = false;
    _summitDialogShown = false;
    _lastPosition = null;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        _elapsed += const Duration(seconds: 1);
        notifyListeners();
      }
    });

    _positionStream = _locationService.getPositionStream().listen((position) {
      if (_isPaused) return;

      if (_lastPosition != null) {
        final distance = _locationService.calculateDistance(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistanceMeters += distance;
      }

      _routePoints.add(position);
      _lastPosition = position;

      // Summit check
      if (!_summitReached && _currentMountain != null) {
        if (_locationService.isNearSummit(position, _currentMountain!)) {
          _summitReached = true;
        }
      }

      notifyListeners();
    });
  }

  void markSummitDialogShown() {
    _summitDialogShown = true;
  }

  void pause() {
    _isPaused = true;
    notifyListeners();
  }

  void resume() {
    _isPaused = false;
    notifyListeners();
  }

  HikingRecord stop() {
    _timer?.cancel();
    _timer = null;
    _positionStream?.cancel();
    _positionStream = null;
    _isActive = false;

    final now = DateTime.now();
    final record = HikingRecord(
      mountain: _currentMountain?.name ?? '자유 등산',
      mountainId: _currentMountain?.id,
      date: DateFormat('M월 d일', 'ko_KR').format(now),
      duration: elapsedFormatted,
      distanceKm: double.parse(totalDistanceKm.toStringAsFixed(1)),
      emoji: _currentMountain?.emoji ?? '🏔️',
      routePoints: _routePoints
          .map((p) => {'lat': p.latitude, 'lng': p.longitude, 'alt': p.altitude})
          .toList(),
      startTime: now.subtract(_elapsed),
      endTime: now,
    );

    notifyListeners();
    return record;
  }

  void reset() {
    _timer?.cancel();
    _positionStream?.cancel();
    _routePoints = [];
    _elapsed = Duration.zero;
    _totalDistanceMeters = 0;
    _isActive = false;
    _isPaused = false;
    _summitReached = false;
    _summitDialogShown = false;
    _currentMountain = null;
    _lastPosition = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
