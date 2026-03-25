import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/logger.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;

  Position? _currentPosition;
  bool _isTracking = false;
  bool _permissionGranted = false;
  StreamSubscription<Position>? _positionStream;

  LocationProvider(this._locationService);

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get permissionGranted => _permissionGranted;

  Future<bool> requestPermission() async {
    _permissionGranted = await _locationService.requestPermission();
    notifyListeners();
    return _permissionGranted;
  }

  Future<void> getCurrentPosition() async {
    if (!_permissionGranted) {
      _permissionGranted = await _locationService.requestPermission();
      if (!_permissionGranted) return;
    }

    try {
      _currentPosition = await _locationService.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      AppLogger.error('현재 위치 조회 실패', tag: 'LocationProvider', error: e);
    }
  }

  void startTracking() {
    if (_isTracking || _positionStream != null) return;
    _isTracking = true;
    _positionStream = _locationService.getPositionStream().listen(
      (position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (e) {
        AppLogger.error('위치 스트림 오류', tag: 'LocationProvider', error: e);
      },
    );
    notifyListeners();
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
