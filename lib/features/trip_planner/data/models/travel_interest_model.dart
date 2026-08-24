class TravelInterestModel {
  const TravelInterestModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory TravelInterestModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return TravelInterestModel(
      id: id,
      name: map['name'] ?? '',
    );
  }
}