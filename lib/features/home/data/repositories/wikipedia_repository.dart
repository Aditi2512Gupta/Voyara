import '../services/wikipedia_service.dart';

class WikipediaRepository {
  WikipediaRepository(this._service);

  final WikipediaService _service;

  final Map<String, String> _descriptionCache = {};

  Future<String> getDescription(String place) async {
    if (_descriptionCache.containsKey(place)) {
      return _descriptionCache[place]!;
    }

    try {
      final data = await _service.getSummary(place);

      final description = (data['extract'] ?? '').toString().trim();

      if (description.isNotEmpty) {
        _descriptionCache[place] = description;
        return description;
      }
    } catch (_) {}

    const fallback =
        "No description is available for this destination at the moment.";

    _descriptionCache[place] = fallback;

    return fallback;
  }
}
