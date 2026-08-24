import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/wikipedia_service.dart';
import '../data/repositories/wikipedia_repository.dart';
import '../data/services/opentripmap_service.dart';
import '../data/repositories/opentripmap_repository.dart';
import '../../../core/providers/app_providers.dart';
import '../data/models/unsplash_image_model.dart';
import '../data/repositories/home_repository.dart';
import '../data/services/weather_service.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/geoapify_service.dart';
import '../data/repositories/geoapify_repository.dart';
import '../data/models/weather_model.dart';
import '../data/models/hotel_model.dart';
import '../data/services/hotel_service.dart';
import '../data/repositories/hotel_repository.dart';
import '../data/repositories/image_repository.dart';
import '../data/repositories/category_repository.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/database/isar_service.dart';
import '../data/datasources/local/destination_local_datasource.dart';
import '../../../core/providers/cache_provider.dart';
import '../data/models/nearby_result_model.dart';
import '../data/repositories/popular_repository.dart';
import '../data/datasources/local/voyara_local_datasource.dart';
import '../data/repositories/voyara_local_repository.dart';

// ============================================================
// OPEN TRIP MAP
// ============================================================

final openTripMapServiceProvider = Provider<OpenTripMapService>(
  (ref) => OpenTripMapService(ref.read(apiServiceProvider)),
);

final openTripMapRepositoryProvider = Provider<OpenTripMapRepository>(
  (ref) => OpenTripMapRepository(ref.read(openTripMapServiceProvider)),
);

// ============================================================
// NEARBY PLACES
// ============================================================

final nearbyPlacesProvider =
    FutureProvider.family<NearbyResultModel, ({double lat, double lon})>((
      ref,
      location,
    ) {
      return ref
          .read(homeRepositoryProvider)
          .getNearbyPlaces(latitude: location.lat, longitude: location.lon);
    });

// ============================================================
// WIKIPEDIA
// ============================================================

final wikipediaServiceProvider = Provider<WikipediaService>(
  (ref) => WikipediaService(ref.read(apiServiceProvider)),
);

final wikipediaRepositoryProvider = Provider<WikipediaRepository>(
  (ref) => WikipediaRepository(ref.read(wikipediaServiceProvider)),
);

final destinationDescriptionProvider = FutureProvider.family<String, String>((
  ref,
  place,
) {
  return ref.read(wikipediaRepositoryProvider).getDescription(place);
});

// ============================================================
// WEATHER
// ============================================================

final weatherServiceProvider = Provider<WeatherService>(
  (ref) => WeatherService(ref.read(apiServiceProvider)),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepository(ref.read(weatherServiceProvider)),
);

final weatherProvider =
    FutureProvider.family<WeatherModel, ({double lat, double lon})>((
      ref,
      location,
    ) {
      return ref
          .read(weatherRepositoryProvider)
          .getWeather(latitude: location.lat, longitude: location.lon);
    });

// ============================================================
// GEOAPIFY
// ============================================================

final geoapifyServiceProvider = Provider<GeoapifyService>(
  (ref) => GeoapifyService(ref.read(apiServiceProvider)),
);

final geoapifyRepositoryProvider = Provider<GeoapifyRepository>(
  (ref) => GeoapifyRepository(ref.read(geoapifyServiceProvider)),
);

// ============================================================
// HOME REPOSITORY
// ============================================================

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) =>
      HomeRepository(localDataSource: ref.read(voyaraLocalDataSourceProvider)),
);

// ============================================================
// HOTELS
// ============================================================

final hotelServiceProvider = Provider<HotelService>(
  (ref) => HotelService(ref.read(apiServiceProvider)),
);

final hotelRepositoryProvider = Provider<HotelRepository>(
  (ref) => HotelRepository(ref.read(hotelServiceProvider)),
);

final nearbyHotelsProvider =
    FutureProvider.family<List<HotelModel>, ({double lat, double lon})>((
      ref,
      location,
    ) {
      return ref
          .read(hotelRepositoryProvider)
          .getHotels(latitude: location.lat, longitude: location.lon);
    });

// ============================================================
// IMAGE REPOSITORY
// ============================================================

final imageRepositoryProvider = Provider<ImageRepository>(
  (ref) => ImageRepository(ref.read(apiServiceProvider)),
);

// ============================================================
// DESTINATION IMAGES
//
// ImageRepository handles:
// 1. Unsplash
// 2. Wikipedia fallback
// 3. Empty result if nothing reliable is found
//
// autoDispose prevents unused destination image requests from
// remaining alive unnecessarily.
// ============================================================

final destinationImagesProvider = FutureProvider.autoDispose
    .family<List<UnsplashImageModel>, String>((ref, place) {
      return ref.read(imageRepositoryProvider).searchImages(place);
    });

// ============================================================
// CATEGORY
// ============================================================

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => const CategoryRepository(),
);

// ============================================================
// CURRENT LOCATION
// ============================================================

final currentLatLngProvider = FutureProvider<({double lat, double lon})>((
  ref,
) async {
  final position = await ref.watch(currentLocationProvider.future);

  return (lat: position.latitude, lon: position.longitude);
});

// ============================================================
// OLD LOCAL DATASOURCE
// ============================================================

final destinationLocalDataSourceProvider = Provider<DestinationLocalDataSource>(
  (ref) {
    return DestinationLocalDataSource(
      isar: IsarService.instance.isar,
      cacheManager: ref.read(cacheManagerProvider),
    );
  },
);

// ============================================================
// POPULAR
// ============================================================

final popularRepositoryProvider = Provider<PopularRepository>(
  (ref) => PopularRepository(ref.read(geoapifyRepositoryProvider)),
);

// ============================================================
// VOYARA LOCAL DATA
// ============================================================

final voyaraLocalDataSourceProvider = Provider<VoyaraLocalDataSource>(
  (ref) => const VoyaraLocalDataSource(),
);

final voyaraLocalRepositoryProvider = Provider<VoyaraLocalRepository>(
  (ref) => VoyaraLocalRepository(ref.read(voyaraLocalDataSourceProvider)),
);
