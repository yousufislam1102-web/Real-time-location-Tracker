import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Timer? _timer;


  Future<bool> checkAndRequestPermission() async {
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


  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }


  void startPeriodicTracking({required Function(Position position) onLocationUpdate}) {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      Position? position = await getCurrentPosition();
      if (position != null) {
        onLocationUpdate(position);
      }
    });
  }


  void stopTracking() {
    _timer?.cancel();
  }
}