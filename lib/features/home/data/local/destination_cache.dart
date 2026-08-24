import 'package:isar_community/isar.dart';

part 'destination_cache.g.dart';

@collection
class DestinationCache {
  Id id = Isar.autoIncrement;

  late String destinationId;

  late String title;

  late String location;

  late String imageUrl;

  late double latitude;

  late double longitude;

  List<String> categories = [];

  late DateTime cachedAt;
}