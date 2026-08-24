import '../models/home_data_model.dart';
import '../models/destination_model.dart';
import '../models/nearby_result_model.dart';
import '../datasources/local/voyara_local_datasource.dart';

class HomeRepository {
  const HomeRepository({required VoyaraLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final VoyaraLocalDataSource _localDataSource;

  // ------------------------------------------------------------
  // Load destinations from Voyara's curated local dataset
  // ------------------------------------------------------------

  Future<HomeDataModel> loadHomeData({
    required double latitude,
    required double longitude,
  }) async {
    final destinations = await _localDataSource.getDestinations();

    final validDestinations = destinations.where((destination) {
      return destination.title.trim().isNotEmpty &&
          destination.latitude != 0 &&
          destination.longitude != 0;
    }).toList();

    // ----------------------------------------------------------
    // Calculate REAL distance from user's current location.
    // ----------------------------------------------------------

    double distanceOf(DestinationModel destination) {
      return DestinationModel.calculateDistance(
        latitude,
        longitude,
        destination.latitude,
        destination.longitude,
      );
    }

    // Sort by actual distance.
    final distanceSorted = [...validDestinations]
      ..sort((a, b) {
        return distanceOf(a).compareTo(distanceOf(b));
      });

    // ----------------------------------------------------------
    // POPULAR
    // ----------------------------------------------------------

    final popular = [...validDestinations]
      ..sort((a, b) => b.rating.compareTo(a.rating));

    // ----------------------------------------------------------
    // NEARBY
    // ----------------------------------------------------------

    const radiusSteps = [
      100,
      200,
      300,
      500,
      750,
      1000,
      1500,
      2500,
      5000,
      10000,
      20000,
    ];

    int nearbyRadius = 100;
    List<DestinationModel> nearby = [];

    for (final radius in radiusSteps) {
      nearbyRadius = radius;

      nearby = distanceSorted
          .where((destination) {
            final distanceKm = distanceOf(destination) / 1000;
            return distanceKm <= radius;
          })
          .take(8)
          .toList();

      if (nearby.length >= 8) {
        break;
      }

      if (nearby.length == distanceSorted.length) {
        break;
      }
    }

    // ----------------------------------------------------------
    // WEEKEND GETAWAYS
    // ----------------------------------------------------------

    final weekendStart = nearbyRadius > 100 ? nearbyRadius : 100;
    final weekendEnd = weekendStart + 200;

    final nearbyIds = nearby.map((destination) {
      return destination.id;
    }).toSet();

    final weekend = distanceSorted
        .where((destination) {
          final distanceKm = distanceOf(destination) / 1000;

          return distanceKm > weekendStart &&
              distanceKm <= weekendEnd &&
              !nearbyIds.contains(destination.id);
        })
        .take(8)
        .toList();

    // ----------------------------------------------------------
    // EXPLORE BEYOND
    //
    // IMPORTANT:
    // Do NOT simply take the next 8 nearest destinations.
    //
    // We distribute results across broad geographic regions so
    // Explore Beyond doesn't become another Nearby section.
    // ----------------------------------------------------------

    final usedIds = <String>{
      ...nearby.map((destination) => destination.id),
      ...weekend.map((destination) => destination.id),
    };

    final exploreCandidates = validDestinations
        .where((destination) => !usedIds.contains(destination.id))
        .toList();

    // Keep selection deterministic.
    exploreCandidates.sort((a, b) {
      return distanceOf(a).compareTo(distanceOf(b));
    });

    // ----------------------------------------------------------
    // Determine broad geographic region.
    // ----------------------------------------------------------

    String geographicRegion(DestinationModel destination) {
      final lat = destination.latitude;
      final lon = destination.longitude;

      if (lat >= 28 && lon < 78) {
        return 'northwest';
      }

      if (lat >= 28 && lon >= 78) {
        return 'northeast';
      }

      if (lat >= 20 && lon < 78) {
        return 'west';
      }

      if (lat >= 20 && lon >= 78) {
        return 'east';
      }

      if (lat < 20 && lon < 78) {
        return 'southwest';
      }

      return 'southeast';
    }

    // ----------------------------------------------------------
    // Select maximum 2 destinations from each broad region.
    // ----------------------------------------------------------

    final regionCounts = <String, int>{};
    final explore = <DestinationModel>[];

    for (final destination in exploreCandidates) {
      if (explore.length >= 8) {
        break;
      }

      final region = geographicRegion(destination);
      final count = regionCounts[region] ?? 0;

      if (count >= 2) {
        continue;
      }

      explore.add(destination);
      regionCounts[region] = count + 1;
    }

    // ----------------------------------------------------------
    // Fill remaining slots if necessary.
    // ----------------------------------------------------------

    if (explore.length < 8) {
      for (final destination in exploreCandidates) {
        if (explore.length >= 8) {
          break;
        }

        final alreadyAdded = explore.any((item) => item.id == destination.id);

        if (!alreadyAdded) {
          explore.add(destination);
        }
      }
    }

    // ----------------------------------------------------------
    // RETURN HOME DATA
    // ----------------------------------------------------------

    return HomeDataModel(
      nearby: nearby,
      weekendGetaways: weekend,
      exploreBeyond: explore,
      popular: popular.take(8).toList(),
      nearbyRadius: nearbyRadius,
    );
  }

  // ------------------------------------------------------------
  // Nearby places used by existing functionality
  // ------------------------------------------------------------

  Future<NearbyResultModel> getNearbyPlaces({
    required double latitude,
    required double longitude,
  }) async {
    final destinations = await _localDataSource.getDestinations();

    final valid = destinations.where((destination) {
      return destination.title.trim().isNotEmpty &&
          destination.latitude != 0 &&
          destination.longitude != 0;
    }).toList();

    double distanceOf(DestinationModel destination) {
      return DestinationModel.calculateDistance(
        latitude,
        longitude,
        destination.latitude,
        destination.longitude,
      );
    }

    // Sort by REAL distance.
    valid.sort((a, b) {
      return distanceOf(a).compareTo(distanceOf(b));
    });

    // Adaptive radius.
    const radiusSteps = [
      100,
      200,
      300,
      500,
      750,
      1000,
      1500,
      2500,
      5000,
      10000,
      20000,
    ];

    int usedRadius = 100;
    List<DestinationModel> nearby = [];

    for (final radius in radiusSteps) {
      usedRadius = radius;

      nearby = valid
          .where((destination) {
            return distanceOf(destination) <= radius * 1000;
          })
          .take(8)
          .toList();

      if (nearby.length >= 8) {
        break;
      }

      if (nearby.length == valid.length) {
        break;
      }
    }

    return NearbyResultModel(
      destinations: nearby,
      usedRadius: usedRadius * 1000,
    );
  }
}
