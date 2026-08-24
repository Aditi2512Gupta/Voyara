import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import 'home_provider.dart';

final destinationImagesAsyncProvider =
    FutureProvider.family.autoDispose(
  (ref, DestinationModel destination) {
    return ref.read(
      destinationImagesProvider(
        "${destination.title}, ${destination.location}",
      ).future,
    );
  },
);

final destinationDescriptionAsyncProvider =
    FutureProvider.family.autoDispose(
  (ref, DestinationModel destination) {
    return ref.read(
      destinationDescriptionProvider(destination.title).future,
    );
  },
);

final destinationWeatherAsyncProvider =
    FutureProvider.family.autoDispose(
  (ref, DestinationModel destination) {
    return ref.read(
      weatherProvider((
        lat: destination.latitude,
        lon: destination.longitude,
      )).future,
    );
  },
);