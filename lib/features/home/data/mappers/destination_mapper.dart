import '../models/attraction_model.dart';
import '../models/destination_model.dart';

class DestinationMapper {
  const DestinationMapper._();

  static DestinationModel fromAttraction(
    AttractionModel attraction,
  ) {
    return DestinationModel(
      id: attraction.xid,
      title: attraction.name,
      location: "",
      imageUrl: "",
      rating: 0,
      price: 0,
      description: "",
      categories: attraction.categories,
      includes: const [],
      reviews: const [],
      latitude: attraction.lat,
      longitude: attraction.lon,
    );
  }
}