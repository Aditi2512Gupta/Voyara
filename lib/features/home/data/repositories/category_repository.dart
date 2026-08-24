import '../models/destination_model.dart';

class CategoryRepository {
  const CategoryRepository();

  List<String> categoriesFromDestinations(
    List<DestinationModel> destinations,
  ) {
    final categories = destinations
        .expand((destination) => destination.categories)
        .map((category) => category.toString().trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    categories.sort();

    return categories;
  }
}