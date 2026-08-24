import 'package:shared_preferences/shared_preferences.dart';

class RecentlyViewedRepository {
  static const _key = 'recent_destinations';

  Future<List<String>> getIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final ids = prefs.getStringList(_key) ?? [];

    ids.remove(id);

    ids.insert(0, id);

    if (ids.length > 20) {
      ids.removeLast();
    }

    await prefs.setStringList(_key, ids);
  }
}