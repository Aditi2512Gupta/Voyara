import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/isar_service.dart';
import '../cache/cache_manager.dart';

final cacheManagerProvider = Provider(
  (ref) => CacheManager(
    IsarService.instance.isar,
  ),
);