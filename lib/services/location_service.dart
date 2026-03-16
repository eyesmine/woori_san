import 'package:geolocator/geolocator.dart';
import '../core/constants.dart';
import '../models/mountain.dart';

class LocationService {
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  bool isNearSummit(Position position, Mountain mountain, {double? threshold}) {
    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      mountain.latitude,
      mountain.longitude,
    );
    return distance <= (threshold ?? AppConstants.summitThresholdMeters);
  }
}
