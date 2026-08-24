import 'package:flutter_riverpod/flutter_riverpod.dart';

final travelDateProvider =
    StateProvider<DateTime?>(
  (ref) => null,
);

final travelersProvider =
    StateProvider<int>(
  (ref) => 1,
);