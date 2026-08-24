import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/services/opentripmap_service.dart';

final openTripMapServiceProvider =
    Provider<OpenTripMapService>(
  (ref) => OpenTripMapService(
    ref.read(apiServiceProvider),
  ),
);