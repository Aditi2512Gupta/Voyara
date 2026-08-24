class UnsplashImageModel {
  final String imageUrl;
  final String? description;
  final String? altDescription;

  const UnsplashImageModel({
    required this.imageUrl,
    this.description,
    this.altDescription,
  });

  factory UnsplashImageModel.fromJson(Map<String, dynamic> json) {
    final urls = json['urls'];

    return UnsplashImageModel(
      imageUrl: urls is Map ? urls['regular']?.toString() ?? '' : '',
      description: json['description']?.toString(),
      altDescription: json['alt_description']?.toString(),
    );
  }
}
