import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeoService {
  /// Get detailed location (address) from GPS coordinates
  Future<Map<String, String>> getLocationDetails() async {
    try {
      // Fetch current GPS coordinates
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Perform reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return {
          'country': place.country ?? 'N/A',
          'province': place.administrativeArea ?? 'N/A',
          'city': place.locality ?? 'N/A',
          'street': place.street ?? 'N/A',
        };
      } else {
        return {'error': 'No address found'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}