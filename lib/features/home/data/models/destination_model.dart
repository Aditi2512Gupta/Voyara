import 'dart:math';

import 'review_model.dart';
import 'geoapify_place_model.dart';
import 'attraction_model.dart';

class DestinationModel {
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0;

    final phi1 = lat1 * pi / 180.0;
    final phi2 = lat2 * pi / 180.0;
    final deltaPhi = (lat2 - lat1) * pi / 180.0;
    final deltaLambda = (lon2 - lon1) * pi / 180.0;

    final a =
        sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return r * c;
  }

  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final double rating;
  final double? price;
  final String description;
  final List categories;
  final List includes;
  final List reviews;
  final double latitude;
  final double longitude;
  final double? distance;
  final String wikipedia;

  const DestinationModel({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.description,
    required this.categories,
    required this.includes,
    required this.reviews,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.wikipedia = '',
  });

  // ------------------------------------------------------------
  // Firestore / Map
  // ------------------------------------------------------------

  factory DestinationModel.fromMap(Map<String, dynamic> map, String id) {
    return DestinationModel(
      id: map['destinationId'] ?? id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      price: (map['price'] as num?)?.toDouble(),
      description: map['description'] ?? '',
      categories: List.from(map['categories'] ?? []),
      includes: List.from(map['includes'] ?? []),
      reviews: const [],
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      distance: (map['distance'] as num?)?.toDouble(),
      wikipedia: map['wikipedia'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
      'price': price,
      'description': description,
      'categories': categories,
      'includes': includes,
      'reviews': [],
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'wikipedia': wikipedia,
    };
  }

  // ------------------------------------------------------------
  // Category helper
  // ------------------------------------------------------------

  static String _getMeaningfulCategory(List rawCats, String name) {
    final nameLower = name.toLowerCase();
    final catsLower = rawCats.map((c) => c.toString().toLowerCase()).toList();

    if (catsLower.any((c) => c.contains('fort')) ||
        nameLower.contains('fort') ||
        nameLower.contains('castle') ||
        nameLower.contains('fortress')) {
      return 'Fort';
    }

    if (catsLower.any((c) => c.contains('palace')) ||
        nameLower.contains('palace') ||
        nameLower.contains('mahal')) {
      return 'Palace';
    }

    if (catsLower.any((c) => c.contains('temple')) ||
        nameLower.contains('temple') ||
        nameLower.contains('mandir')) {
      return 'Temple';
    }

    if (catsLower.any((c) => c.contains('church')) ||
        catsLower.any((c) => c.contains('cathedral')) ||
        nameLower.contains('church') ||
        nameLower.contains('cathedral')) {
      return 'Church';
    }

    if (catsLower.any((c) => c.contains('mosque')) ||
        nameLower.contains('mosque') ||
        nameLower.contains('masjid')) {
      return 'Mosque';
    }

    if (catsLower.any((c) => c.contains('museum')) ||
        catsLower.any((c) => c.contains('art_gallery')) ||
        nameLower.contains('museum') ||
        nameLower.contains('gallery')) {
      return 'Museum';
    }

    if (catsLower.any((c) => c.contains('waterfall')) ||
        nameLower.contains('waterfall') ||
        nameLower.contains('falls')) {
      return 'Waterfall';
    }

    if (catsLower.any((c) => c.contains('cave')) ||
        nameLower.contains('cave') ||
        nameLower.contains('caves')) {
      return 'Cave';
    }

    if (catsLower.any((c) => c.contains('beach')) ||
        nameLower.contains('beach')) {
      return 'Beach';
    }

    if (catsLower.any((c) => c.contains('lake')) ||
        nameLower.contains('lake') ||
        nameLower.contains('tal')) {
      return 'Lake';
    }

    if (catsLower.any((c) => c.contains('monument')) ||
        nameLower.contains('monument') ||
        nameLower.contains('statue') ||
        nameLower.contains('memorial')) {
      return 'Monument';
    }

    if (catsLower.any((c) => c.contains('national_park')) ||
        catsLower.any((c) => c.contains('nature_reserve')) ||
        nameLower.contains('national park') ||
        nameLower.contains('sanctuary')) {
      return 'National Park';
    }

    if (catsLower.any((c) => c.contains('heritage')) ||
        nameLower.contains('heritage')) {
      return 'Heritage Site';
    }

    if (catsLower.any((c) => c.contains('natural')) ||
        nameLower.contains('valley') ||
        nameLower.contains('canyon')) {
      return 'Nature Sight';
    }

    if (catsLower.any((c) => c.contains('park')) ||
        nameLower.contains('park') ||
        nameLower.contains('garden')) {
      return 'Park';
    }

    for (final cat in rawCats) {
      final category = cat.toString();

      if (category.startsWith('tourism.')) {
        final leaf = category.split('.').last.replaceAll('_', ' ');

        if (leaf != 'attraction' && leaf != 'sights') {
          return leaf
              .split(' ')
              .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
              .join(' ');
        }
      }
    }

    return 'Attraction';
  }

  // ------------------------------------------------------------
  // Geoapify
  // ------------------------------------------------------------

  factory DestinationModel.fromGeoapify(
    GeoapifyPlaceModel place, [
    double? userLat,
    double? userLon,
  ]) {
    double? dist;

    if (userLat != null && userLon != null) {
      dist = calculateDistance(
        userLat,
        userLon,
        place.latitude,
        place.longitude,
      );
    } else {
      dist = place.distance;
    }

    return DestinationModel(
      id: place.id,
      title: place.name,
      location: [
        place.city,
        place.state,
        place.country,
      ].where((e) => e.isNotEmpty).join(", "),
      imageUrl: place.imageUrl ?? '',
      rating: 0,
      price: null,
      description: '',
      categories: [_getMeaningfulCategory(place.rawCategories, place.name)],
      includes: const [],
      reviews: const [],
      latitude: place.latitude,
      longitude: place.longitude,
      distance: dist,
      wikipedia: place.wikipedia,
    );
  }

  // ------------------------------------------------------------
  // OpenTripMap attraction
  // ------------------------------------------------------------

  factory DestinationModel.fromAttraction(AttractionModel attraction) {
    return DestinationModel(
      id: attraction.xid,
      title: attraction.name,
      location: "",
      imageUrl: "",
      rating: 0,
      price: null,
      description: "",
      categories: attraction.categories,
      includes: const [],
      reviews: const [],
      latitude: attraction.lat,
      longitude: attraction.lon,
      wikipedia: "",
    );
  }

  // ------------------------------------------------------------
  // Voyara local dataset
  // ------------------------------------------------------------

  factory DestinationModel.fromVoyara(Map<String, dynamic> json) {
    final rawImageUrl = json["image_url"]?.toString().trim() ?? "";

    // Ignore Voyara's placeholder image.
    // Keep real image URLs.
    final imageUrl =
        rawImageUrl.isNotEmpty && !rawImageUrl.contains('placehold.co')
        ? rawImageUrl
        : '';

    final city = json["city"]?.toString().trim() ?? '';
    final state = json["state"]?.toString().trim() ?? '';

    final location = [city, state].where((e) => e.isNotEmpty).join(', ');

    return DestinationModel(
      id: json["id"]?.toString() ?? "",
      title: json["name"]?.toString() ?? "",
      location: location,
      imageUrl: imageUrl,
      rating: (json["rating"] as num?)?.toDouble() ?? 0,
      price: double.tryParse(json["entry_fee"]?.toString() ?? ''),
      description: json["activities"]?.toString() ?? "",
      categories: [json["category"]?.toString() ?? "Attraction"],
      includes: const [],
      reviews: const [],
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0,
      wikipedia: "",
    );
  }
}
