import 'package:flutter/material.dart';

import '../../data/models/destination_model.dart';

class NearbyPlacesSection extends StatelessWidget {
  const NearbyPlacesSection({super.key, required this.places});

  final List<DestinationModel> places;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nearby Attractions",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),

        ...places
            .where((e) => e.title.isNotEmpty)
            .take(10)
            .map(
              (place) => Card(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place),
                  title: Text(
                    place.title.isEmpty ? "Unknown Place" : place.title,
                  ),
                  subtitle: Text(
                    place.categories.isEmpty
                        ? "Tourist Attraction"
                        : place.categories.first,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            ),
      ],
    );
  }
}
