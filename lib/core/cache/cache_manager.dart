import 'package:isar_community/isar.dart';

class CacheManager {
  const CacheManager(this.isar);

  final Isar isar;

  Future<T?> get<T>(Future<T?> Function() reader) async {
    return await reader();
  }

  Future<void> save(Future<void> Function() writer) async {
    await isar.writeTxn(() async {
      await writer();
    });
  }

  Future<void> delete(Future<void> Function() remover) async {
    await isar.writeTxn(() async {
      await remover();
    });
  }
}