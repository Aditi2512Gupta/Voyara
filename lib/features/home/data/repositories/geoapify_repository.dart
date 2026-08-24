import 'package:flutter/foundation.dart';
import '../models/geoapify_place_model.dart';
import '../models/location_model.dart';
import '../services/geoapify_service.dart';

class GeoapifyRepository {
  GeoapifyRepository(this.service);

  final GeoapifyService service;

  final Map<String, List<GeoapifyPlaceModel>> _nearbyCache = {};

  Future<List<GeoapifyPlaceModel>> searchPlaces(String query) async {
    try {
      final data = await service.searchPlaces(query);

      final features = data['features'] as List;

      return features
          .map((feature) => GeoapifyPlaceModel.fromJson(feature['properties']))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<LocationModel> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    try {
      final data = await service.reverseGeocode(lat: lat, lon: lon);

      final features = data['features'] as List;

      if (features.isEmpty) {
        return const LocationModel(city: "", state: "", country: "", countryCode: "");
      }

      final p = features.first['properties'];

      return LocationModel(
        city: (p['city'] ?? p['county'] ?? "").toString(),
        state: (p['state'] ?? "").toString(),
        country: (p['country'] ?? "").toString(),
        countryCode: (p['country_code'] ?? "").toString(),
      );
    } catch (_) {
      return const LocationModel(city: "", state: "", country: "", countryCode: "");
    }
  }

  Future<List<GeoapifyPlaceModel>> nearbyTouristPlaces({
    required double lat,
    required double lon,
    required int radius,
    int limit = 30,
  }) async {
    final cacheKey =
        "${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}_${radius}_$limit";

    if (_nearbyCache.containsKey(cacheKey)) {
      return _nearbyCache[cacheKey]!;
    }

    try {
      final data = await service.touristPlaces(
        filter: "circle:$lon,$lat,$radius",
        limit: limit,
      );

      final features = data['features'] as List;

      List<GeoapifyPlaceModel> places = features
          .map((e) => GeoapifyPlaceModel.fromJson(e['properties']))
          .toList();

      // 1. Keep only genuine tourist attractions
      places = places.where(isGenuineAttraction).toList();

      // 2. Remove duplicate coordinates and IDs
      final coordinateSet = <String>{};
      final uniqueIds = <String>{};
      places = places.where((place) {
        final key =
            "${place.latitude.toStringAsFixed(4)}_${place.longitude.toStringAsFixed(4)}";
        final isUnique = coordinateSet.add(key) && uniqueIds.add(place.id);
        if (!isUnique) {
          debugPrint("Place [${place.name}] rejected: Duplicate coordinates or ID");
        }
        return isUnique;
      }).toList();

      // 3. Sort by priority score (descending)
      places.sort((a, b) => calculateAttractionScore(b, lat, lon)
          .compareTo(calculateAttractionScore(a, lat, lon)));

      // Never cache empty, failed, or invalid API responses
      if (places.isNotEmpty) {
        _nearbyCache[cacheKey] = places;
      }
      return places;
    } catch (_) {
      return [];
    }
  }

  Future<List<GeoapifyPlaceModel>> countryTouristPlaces({
    required String countryName,
    int limit = 40,
  }) async {
    try {
      if (countryName.trim().isEmpty) return [];

      final searchResults = await searchPlaces(countryName);
      if (searchResults.isEmpty) {
        debugPrint("countryTouristPlaces: Geocoding failed to find place ID for [$countryName]");
        return [];
      }

      final countryPlaceId = searchResults.first.id;
      final data = await service.touristPlaces(
        filter: "place:$countryPlaceId",
        limit: limit,
      );

      final features = data['features'] as List;

      return features
          .map((e) => GeoapifyPlaceModel.fromJson(e['properties']))
          .toList();
    } catch (e) {
      debugPrint("countryTouristPlaces error: $e");
      return [];
    }
  }

  bool isGenuineAttraction(GeoapifyPlaceModel place) {
    final categoryLower = place.category.toLowerCase().trim();
    final nameLower = place.name.toLowerCase().trim();
    final rawCats = place.rawCategories;

    // 1. Primary Category validation based on Geoapify categories
    final isAllowedCategory = rawCats.any((cat) {
      final c = cat.toLowerCase();
      return c.startsWith('tourism.attraction') ||
             c.startsWith('tourism.sights') ||
             c.startsWith('heritage') ||
             c.startsWith('natural') ||
             c.startsWith('national_park') ||
             c.startsWith('leisure.park') ||
             c.startsWith('entertainment.zoo') ||
             c.startsWith('entertainment.theme_park') ||
             c.startsWith('entertainment.aquarium') ||
             c.startsWith('culture.museum');
    });

    if (!isAllowedCategory) {
      debugPrint("Place [${place.name}] rejected: Invalid category. Raw categories: $rawCats");
      return false;
    }

    // 2. Secondary Keyword checks (blocklist safeguards)
    const blockedNames = [
      'road', 'sector', 'chowk', 'street', 'block', 'parking', 'residential', 
      'commercial', 'administrative', 'highway', 'lane', 'avenue', 'path', 
      'housing', 'colony', 'society', 'nagar', 'gali', 'flyover', 'bridge', 
      'junction', 'crossing', 'cross', 'toll', 'station', 'stop', 'terminal', 
      'airport', 'taxi', 'stand', 'gate', 'office', 'hospital', 'clinic', 
      'school', 'college', 'university', 'bank', 'atm', 'shop', 'store', 
      'mall', 'market', 'supermarket', 'grocery', 'restaurant', 'cafe', 
      'hotel', 'motel', 'hostel', 'resort', 'stay', 'apartment', 'villa', 
      'plaza', 'building', 'industrial', 'factory', 'warehouse', 'village',
      'colony', 'housing complex', 'residential area', 'residential complex',
      'bus stand', 'railway station', 'metro station', 'police station',
      'marg', 'path', 'gully', 'bypass', 'expressway'
    ];
    for (final term in blockedNames) {
      if (nameLower.contains(term)) {
        debugPrint("Place [${place.name}] rejected: Name contains blocked keyword ($term)");
        return false;
      }
    }

    // 3. Name, location completeness and coordinates
    if (place.name.trim().length < 4 || place.name.trim().toLowerCase() == 'unknown place') {
      debugPrint("Place [${place.name}] rejected: Invalid or too short name");
      return false;
    }
    if (place.latitude == 0.0 || place.longitude == 0.0) {
      debugPrint("Place [${place.name}] rejected: Invalid coordinates");
      return false;
    }
    if (place.city.isEmpty && place.state.isEmpty && place.country.isEmpty) {
      debugPrint("Place [${place.name}] rejected: Missing address details");
      return false;
    }

    return true;
  }

  double calculateAttractionScore(GeoapifyPlaceModel place, [double? lat, double? lon]) {
    double score = 0.0;
    final nameLower = place.name.toLowerCase();
    final rawCats = place.rawCategories;

    // 1. Category / Attraction Type Importance (Major weight)
    final priorityWeights = {
      'unesco': 10000.0,
      'castle': 8000.0,
      'fort': 8000.0,
      'palace': 7000.0,
      'monument': 6000.0,
      'museum': 5000.0,
      'temple': 4000.0,
      'church': 4000.0,
      'mosque': 4000.0,
      'cathedral': 4000.0,
      'shrine': 4000.0,
      'heritage': 3000.0,
      'viewpoint': 2000.0,
      'waterfall': 2000.0,
      'beach': 2000.0,
      'lake': 2000.0,
      'national park': 1500.0,
      'nature': 1000.0,
    };

    for (final entry in priorityWeights.entries) {
      final matchesName = nameLower.contains(entry.key);
      final matchesCategory = rawCats.any((c) => c.toLowerCase().contains(entry.key));
      if (matchesName || matchesCategory) {
        score += entry.value;
      }
    }

    // 2. Wikipedia Presence (High confidence indicator)
    if (place.wikipedia.isNotEmpty) {
      score += 3000.0;
    }

    // 3. Image Availability / Quality
    if (place.imageUrl != null && place.imageUrl!.isNotEmpty) {
      score += 2000.0;
    }

    // 4. Proximity as a bonus only (max 500 points)
    if (place.distance != null) {
      final distKm = place.distance! / 1000.0;
      final distanceBonus = (500.0 - distKm).clamp(0.0, 500.0);
      score += distanceBonus;
    }

    return score;
  }

  Future<List<GeoapifyPlaceModel>> searchTourismInCountry(
    String country,
  ) async {
    try {
      final places = await searchPlaces("Top tourist attractions in $country");
      return places;
    } catch (_) {
      return [];
    }
  }
}
