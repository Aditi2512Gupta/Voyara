import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  IsarService._();

  static final IsarService instance = IsarService._();

  late final Isar isar;

  Future<void> init({
    required List<CollectionSchema<dynamic>> schemas,
  }) async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      schemas,
      directory: dir.path,
    );
  }
}