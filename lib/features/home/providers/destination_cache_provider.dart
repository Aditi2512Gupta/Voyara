import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_details_model.dart';

final destinationCacheProvider =
    StateProvider<Map<String, DestinationDetailsModel>>(
  (ref) => {},
);