import 'package:latlong2/latlong.dart';

class RouteModel {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  const RouteModel({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }
    final km = distanceMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) {
      return '$minutes min${minutes == 1 ? '' : 's'}';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr${hours == 1 ? '' : 's'}';
    }
    return '$hours hr $remainingMinutes min';
  }

  factory RouteModel.fromGeoapify(Map<String, dynamic> json) {
    final features = json['features'] as List?;
    if (features == null || features.isEmpty) {
      return const RouteModel(
        points: [],
        distanceMeters: 0,
        durationSeconds: 0,
      );
    }

    final first = features.first as Map<String, dynamic>;
    final geometry = first['geometry'] as Map<String, dynamic>? ?? {};
    final properties = first['properties'] as Map<String, dynamic>? ?? {};

    final coordsRaw = geometry['coordinates'];
    final geometryType = geometry['type']?.toString().toLowerCase();

    final points = <LatLng>[];

    if (coordsRaw is List) {
      if (geometryType == 'multilinestring') {
        for (final line in coordsRaw) {
          if (line is List) {
            for (final coord in line) {
              if (coord is List && coord.length >= 2) {
                final lon = (coord[0] as num).toDouble();
                final lat = (coord[1] as num).toDouble();
                points.add(LatLng(lat, lon));
              }
            }
          }
        }
      } else {
        // LineString
        for (final coord in coordsRaw) {
          if (coord is List && coord.length >= 2) {
            final lon = (coord[0] as num).toDouble();
            final lat = (coord[1] as num).toDouble();
            points.add(LatLng(lat, lon));
          }
        }
      }
    }

    final distance = (properties['distance'] as num?)?.toDouble() ?? 0.0;
    final time = (properties['time'] as num?)?.toDouble() ?? 0.0;

    return RouteModel(
      points: points,
      distanceMeters: distance,
      durationSeconds: time,
    );
  }
}
