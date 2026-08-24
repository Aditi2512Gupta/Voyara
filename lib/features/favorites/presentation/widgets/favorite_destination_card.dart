import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/favorite_model.dart';
import '../../../home/data/models/destination_model.dart';
import '../../../home/providers/home_provider.dart';

class FavoriteDestinationCard extends ConsumerWidget {
  const FavoriteDestinationCard({super.key, required this.destination});

  final FavoriteModel destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(
      destinationImagesProvider(
        '${destination.title}, ${destination.location}',
      ),
    );
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () {
          context.push(
            '/destination',
            extra: DestinationModel(
              id: destination.id,
              title: destination.title,
              location: destination.location,
              imageUrl: destination.imageUrl,
              rating: 0,
              price: 0,
              description: '',
              categories: const ['Destination'],
              includes: const [],
              reviews: const [],
              latitude: destination.latitude,
              longitude: destination.longitude,
            ),
          );
        },
        child: SizedBox(
          height: 140,
          child: Row(
            children: [
              Hero(
                tag: 'destination-${destination.id}',
                child: imagesAsync.when(
                  loading: () => const SizedBox(
                    width: 130,
                    height: double.infinity,
                    child: Center(child: CircularProgressIndicator()),
                  ),

                  error: (_, __) {
                    if (destination.imageUrl.trim().isEmpty) {
                      return const SizedBox(
                        width: 130,
                        child: Icon(Icons.image_not_supported),
                      );
                    }

                    return Image.network(
                      destination.imageUrl,
                      width: 130,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const SizedBox(
                          width: 130,
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    );
                  },

                  data: (images) {
                    // Prefer newly fetched valid image
                    if (images.isNotEmpty &&
                        images.first.imageUrl.trim().isNotEmpty) {
                      return Image.network(
                        images.first.imageUrl,
                        width: 130,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(Icons.image_not_supported);
                        },
                      );
                    }

                    // Fallback to stored image
                    if (destination.imageUrl.trim().isNotEmpty) {
                      return Image.network(
                        destination.imageUrl,
                        width: 130,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const SizedBox(
                            width: 130,
                            child: Icon(Icons.image_not_supported),
                          );
                        },
                      );
                    }

                    return const SizedBox(
                      width: 130,
                      child: Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: Text(destination.location)),
                        ],
                      ),

                      const Spacer(),

                      const Text(
                        "Saved Destination",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await ref
                        .read(authRepositoryProvider)
                        .removeFavorite(destination.id);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
