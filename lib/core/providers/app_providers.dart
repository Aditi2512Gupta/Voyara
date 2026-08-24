import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_dataset_service.dart';
import '../services/api_service.dart';

final appNameProvider = Provider((ref) => 'Voyara');

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final localDatasetProvider =
    Provider<LocalDatasetService>((ref) {
  return LocalDatasetService();
});