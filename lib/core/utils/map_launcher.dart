import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  /// Builds Google Maps directions URI with explicit driving travel mode.
  static Uri buildDirectionsUri({
    required double destinationLatitude,
    required double destinationLongitude,
    double? originLatitude,
    double? originLongitude,
  }) {
    final buffer = StringBuffer('https://www.google.com/maps/dir/?api=1');
    buffer.write('&destination=$destinationLatitude,$destinationLongitude');
    if (originLatitude != null && originLongitude != null) {
      buffer.write('&origin=$originLatitude,$originLongitude');
    }
    buffer.write('&travelmode=driving');
    return Uri.parse(buffer.toString());
  }

  /// Opens Google Maps with turn-by-turn directions to [destinationLatitude], [destinationLongitude].
  /// If [originLatitude] and [originLongitude] are provided, they are specified as the starting point.
  /// Otherwise, Google Maps defaults to the device's current location.
  static Future<void> openDirections({
    required double destinationLatitude,
    required double destinationLongitude,
    double? originLatitude,
    double? originLongitude,
  }) async {
    final uri = buildDirectionsUri(
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open Google Maps directions');
    }
  }

  /// Opens Google Maps to the specified destination coordinates.
  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
    double? originLatitude,
    double? originLongitude,
  }) async {
    return openDirections(
      destinationLatitude: latitude,
      destinationLongitude: longitude,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
    );
  }
}
