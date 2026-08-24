import 'package:isar_community/isar.dart';

import '../../local/destination_cache.dart';
import '../../../../../core/cache/cache_manager.dart';

class DestinationLocalDataSource {
  const DestinationLocalDataSource({
    required Isar isar,
    required CacheManager cacheManager,
  }) : _isar = isar,
       _cacheManager = cacheManager;

  final Isar _isar;
  final CacheManager _cacheManager;

  Future<void> saveDestinations(
    List<DestinationCache> destinations,
  ) async {
    await _cacheManager.save(() async {
      await _isar.destinationCaches.clear();
      await _isar.destinationCaches.putAll(destinations);
    });
  }

  Future<List<DestinationCache>> getDestinations() async {
    return await _cacheManager.get(
          () => _isar.destinationCaches.where().findAll(),
        ) ??
        [];
  }

  Future<void> clear() async {
    await _cacheManager.delete(() async {
      await _isar.destinationCaches.clear();
    });
  }
}