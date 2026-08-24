import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../models/unsplash_image_model.dart';

class ImageRepository {
  ImageRepository(this.apiService);

  final ApiService apiService;

  // Cache only successful results.
  final Map<String, List<UnsplashImageModel>> _imageCache = {};

  Future<List<UnsplashImageModel>> searchImages(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final cacheKey = _getCacheKey(normalizedQuery);

    if (_imageCache.containsKey(cacheKey)) {
      debugPrint("[IMAGE] Cache hit for [$cacheKey]");
      return _imageCache[cacheKey]!;
    }

    final title = _extractTitle(normalizedQuery);
    final location = _extractLocation(normalizedQuery);

    final searchQueries = _buildSearchQueries(title: title, location: location);

    debugPrint("[IMAGE] Searching images for [$title]");

    // ============================================================
    // UNSPLASH
    // ============================================================

    List<UnsplashImageModel> rankedFallback = [];

    for (final searchQuery in searchQueries) {
      debugPrint("[IMAGE] Unsplash search: [$searchQuery]");

      try {
        final data = await apiService.get(
          '${ApiConstants.unsplashBaseUrl}/search/photos'
          '?query=${Uri.encodeComponent(searchQuery)}'
          '&orientation=landscape'
          '&per_page=10'
          '&order_by=relevant'
          '&client_id=${ApiConstants.unsplashApiKey}',
        );

        if (data == null || data['results'] is! List) {
          continue;
        }

        final results = data['results'] as List;

        if (results.isEmpty) {
          continue;
        }

        final candidates = <UnsplashImageModel>[];

        for (final result in results) {
          try {
            final image = UnsplashImageModel.fromJson(
              Map<String, dynamic>.from(result),
            );

            if (image.imageUrl.trim().isEmpty) {
              continue;
            }

            candidates.add(image);
          } catch (e) {
            debugPrint("[IMAGE] Invalid Unsplash result: $e");
          }
        }

        if (candidates.isEmpty) {
          continue;
        }

        // Keep the first successful Unsplash result as a fallback.
        // Unsplash already ranked these results for our query.
        rankedFallback = candidates;

        final relevantImages = candidates.where((image) {
          return _isImageRelevant(
            title,
            location,
            image.description,
            image.altDescription,
          );
        }).toList();

        if (relevantImages.isNotEmpty) {
          _imageCache[cacheKey] = relevantImages;

          debugPrint(
            "[IMAGE] Unsplash SUCCESS - "
            "${relevantImages.length} relevant images",
          );

          return relevantImages;
        }
      } catch (e) {
        debugPrint("[IMAGE] Unsplash failed for [$searchQuery]: $e");
      }
    }

    // ============================================================
    // IMPORTANT FALLBACK
    //
    // If Unsplash returned images but metadata was not good enough
    // to prove relevance, use Unsplash's ranked results.
    //
    // This prevents valid destinations from showing
    // "Image unavailable".
    // ============================================================

    if (rankedFallback.isNotEmpty) {
      debugPrint("[IMAGE] Using Unsplash ranked fallback for [$title]");

      _imageCache[cacheKey] = rankedFallback;

      return rankedFallback;
    }

    // ============================================================
    // WIKIPEDIA FALLBACK
    // ============================================================

    debugPrint("[IMAGE] Unsplash returned no images. Trying Wikipedia.");

    final wikiImage = await _getWikipediaImage(title, location);

    if (wikiImage != null && wikiImage.isNotEmpty) {
      final result = [UnsplashImageModel(imageUrl: wikiImage)];

      _imageCache[cacheKey] = result;

      debugPrint("[IMAGE] Wikipedia SUCCESS for [$title]");

      return result;
    }

    // ============================================================
    // NO IMAGE
    // ============================================================

    debugPrint("[IMAGE] No image found for [$title]");

    return [];
  }

  // ============================================================
  // SEARCH QUERIES
  // ============================================================

  List<String> _buildSearchQueries({
    required String title,
    required String location,
  }) {
    final queries = <String>[];

    void addQuery(String value) {
      final cleaned = value.trim();

      if (cleaned.isEmpty) {
        return;
      }

      if (!queries.contains(cleaned)) {
        queries.add(cleaned);
      }
    }

    // 1. Destination + complete location
    if (location.isNotEmpty) {
      addQuery('$title $location');

      // 2. Destination + first location component
      final locationParts = location
          .split(RegExp(r'\s+'))
          .where((e) => e.isNotEmpty)
          .toList();

      if (locationParts.isNotEmpty) {
        addQuery('$title ${locationParts.first}');
      }
    }

    // 3. Exact destination
    addQuery(title);

    return queries;
  }

  // ============================================================
  // TITLE
  // ============================================================

  String _extractTitle(String query) {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    // Expected format:
    //
    // Agrasen Ki Baoli, New Delhi, Delhi
    //
    // => Agrasen Ki Baoli

    if (trimmed.contains(',')) {
      return trimmed.split(',').first.trim();
    }

    return trimmed;
  }

  // ============================================================
  // LOCATION
  // ============================================================

  String _extractLocation(String query) {
    final parts = query
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.length <= 1) {
      return '';
    }

    return parts.skip(1).join(' ');
  }

  // ============================================================
  // CACHE KEY
  // ============================================================

  String _getCacheKey(String query) {
    final title = _extractTitle(query);

    return title.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // IMAGE RELEVANCE
  // ============================================================

  bool _isImageRelevant(
    String title,
    String location,
    String? description,
    String? altDescription,
  ) {
    final titleLower = title.toLowerCase().trim();

    final descLower = (description ?? '').toLowerCase().trim();

    final altLower = (altDescription ?? '').toLowerCase().trim();

    final metadata = '$descLower $altLower';

    // No metadata = don't reject it.
    //
    // Unsplash itself searched for the destination.
    if (metadata.trim().isEmpty) {
      return true;
    }

    // ============================================================
    // Reject obvious famous-landmark substitutions.
    // ============================================================

    const famousLandmarks = [
      'india gate',
      'lotus temple',
      'taj mahal',
      'qutub minar',
      'red fort',
      'gateway of india',
      'hawa mahal',
      'amer fort',
      'eiffel tower',
      'statue of liberty',
      'charminar',
      'victoria memorial',
      'mysore palace',
      'golden temple',
    ];

    for (final landmark in famousLandmarks) {
      if (metadata.contains(landmark) && !titleLower.contains(landmark)) {
        return false;
      }
    }

    // ============================================================
    // Exact destination match.
    // ============================================================

    if (metadata.contains(titleLower)) {
      return true;
    }

    // ============================================================
    // Meaningful title-word match.
    // ============================================================

    final titleWords = titleLower
        .split(RegExp(r'\s+'))
        .where((word) => word.length >= 3)
        .toList();

    int titleMatches = 0;

    for (final word in titleWords) {
      if (metadata.contains(word)) {
        titleMatches++;
      }
    }

    if (titleWords.length >= 2 && titleMatches > 0) {
      return true;
    }

    // ============================================================
    // Location match.
    // ============================================================

    final locationWords = location
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length >= 3)
        .toList();

    for (final word in locationWords) {
      if (metadata.contains(word)) {
        return true;
      }
    }

    // We don't reject here.
    //
    // Unsplash ranked the image for our destination query.
    return true;
  }

  // ============================================================
  // WIKIPEDIA FALLBACK
  // ============================================================

  Future<String?> _getWikipediaImage(String title, String location) async {
    try {
      final searchTerms = <String>[
        if (location.isNotEmpty) '$title $location',
        title,
      ];

      final uniqueSearchTerms = <String>[];

      for (final term in searchTerms) {
        final cleaned = term.trim();

        if (cleaned.isNotEmpty && !uniqueSearchTerms.contains(cleaned)) {
          uniqueSearchTerms.add(cleaned);
        }
      }

      for (final searchTerm in uniqueSearchTerms) {
        debugPrint("[IMAGE] Wikipedia search: [$searchTerm]");

        final searchData = await apiService.get(
          'https://en.wikipedia.org/w/api.php'
          '?action=opensearch'
          '&search=${Uri.encodeComponent(searchTerm)}'
          '&limit=5'
          '&namespace=0'
          '&format=json',
        );

        if (searchData is! List ||
            searchData.length < 2 ||
            searchData[1] is! List) {
          continue;
        }

        final titles = searchData[1] as List;

        for (final item in titles) {
          final wikiTitle = item.toString().trim();

          if (wikiTitle.isEmpty) {
            continue;
          }

          final formattedTitle = wikiTitle.replaceAll(' ', '_');

          final summaryData = await apiService.get(
            'https://en.wikipedia.org/api/rest_v1/page/summary/'
            '${Uri.encodeComponent(formattedTitle)}',
          );

          if (summaryData == null) {
            continue;
          }

          if (summaryData['type']?.toString() == 'disambiguation') {
            continue;
          }

          // ======================================================
          // Verify Wikipedia title
          // ======================================================

          final wikiPageTitle = wikiTitle.toLowerCase();

          final requestedTitle = title.toLowerCase();

          final titleWords = requestedTitle
              .split(RegExp(r'\s+'))
              .where((word) => word.length >= 3)
              .toList();

          int matches = 0;

          for (final word in titleWords) {
            if (wikiPageTitle.contains(word)) {
              matches++;
            }
          }

          if (titleWords.length >= 2 && matches == 0) {
            continue;
          }

          // ======================================================
          // Original image
          // ======================================================

          final originalImage = summaryData['originalimage'];

          if (originalImage is Map && originalImage['source'] != null) {
            final url = originalImage['source'].toString();

            if (url.isNotEmpty) {
              debugPrint("[IMAGE] Wikipedia image found: [$wikiTitle]");

              return url;
            }
          }

          // ======================================================
          // Thumbnail fallback
          // ======================================================

          final thumbnail = summaryData['thumbnail'];

          if (thumbnail is Map && thumbnail['source'] != null) {
            final url = thumbnail['source'].toString();

            if (url.isNotEmpty) {
              debugPrint("[IMAGE] Wikipedia thumbnail found: [$wikiTitle]");

              return url;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("[IMAGE] Wikipedia image search failed: $e");
    }

    return null;
  }
}
