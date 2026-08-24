class AttractionModel {
  final String xid;
  final String name;
  final List<String> categories;
  final double lat;
  final double lon;

  const AttractionModel({
    required this.xid,
    required this.name,
    required this.categories,
    required this.lat,
    required this.lon,
  });

  factory AttractionModel.fromJson(Map<String, dynamic> json) {
    return AttractionModel(
      xid: json['xid'] ?? '',
      name: json['name'] ?? '',
      categories: (json['kinds'] ?? '')
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      lat: (json['point']['lat'] as num).toDouble(),
      lon: (json['point']['lon'] as num).toDouble(),
    );
  }

  String get category {
    if (categories.contains('beaches')) return 'Beach';
    if (categories.contains('museums')) return 'Museum';
    if (categories.contains('historic')) return 'Historical Site';
    if (categories.contains('architecture')) return 'Architecture';
    if (categories.contains('natural')) return 'Nature';
    if (categories.contains('parks')) return 'Park';
    if (categories.contains('religion')) return 'Temple';
    if (categories.contains('foods')) return 'Restaurant';

    return 'Attraction';
  }
}
