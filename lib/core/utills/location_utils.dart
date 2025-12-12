import 'package:geolocator/geolocator.dart';

class LocationUtils {
  static Future<double> getDistance(double lat, double lng) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      lat,
      lng,
    );
  }
}
