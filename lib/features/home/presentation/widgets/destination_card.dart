import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/home_provider.dart';
import '../../data/models/destination_model.dart';
import 'favorite_button.dart';

class DestinationCard extends ConsumerWidget {
  const DestinationCard({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDatasetImage = destination.imageUrl.trim().isNotEmpty;

    // Only search Unsplash when the curated dataset has no image.
    final imageQuery = "${destination.title}, ${destination.location}";

    final imagesAsync = ref.watch(destinationImagesProvider(imageQuery));

    final errorPlaceholder = Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: Colors.grey,
            ),
            SizedBox(height: 4),
            Text(
              "Image unavailable",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    Widget buildImage(String imageUrl) {
      if (imageUrl.trim().isEmpty) {
        return errorPlaceholder;
      }

      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => errorPlaceholder,
      );
    }

    Widget imageWidget() {
      // If dataset has an image, try it first.
      if (hasDatasetImage) {
        return CachedNetworkImage(
          imageUrl: destination.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (_, __) => Container(
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) {
            // Dataset image failed → use Unsplash.
            return imagesAsync == null
                ? errorPlaceholder
                : imagesAsync.when(
                    loading: () => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => errorPlaceholder,
                    data: (images) {
                      if (images.isEmpty) {
                        return errorPlaceholder;
                      }

                      return buildImage(images.first.imageUrl);
                    },
                  );
          },
        );
      }

      // No dataset image → Unsplash.
      return imagesAsync!.when(
        loading: () => Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => errorPlaceholder,
        data: (images) {
          if (images.isEmpty) {
            return errorPlaceholder;
          }

          return buildImage(images.first.imageUrl);
        },
      );
    }

    return SizedBox(
      width: 220,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push('/destination', extra: destination);
        },
        child: Card(
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'destination-${destination.id}',
                      child: imageWidget(),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.title.isEmpty
                              ? "Unknown Destination"
                              : destination.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 16,
                            ),
                            Expanded(
                              child: Text(
                                destination.location.isNotEmpty
                                    ? destination.location
                                    : "Location unavailable",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        if (destination.categories.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: destination.categories
                                .take(2)
                                .map(
                                  (category) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            Text(
                              destination.rating > 0
                                  ? destination.rating.toStringAsFixed(1)
                                  : "N/A",
                            ),
                            const Spacer(),
                            Text(
                              destination.price != null
                                  ? "₹${destination.price!.toStringAsFixed(0)}"
                                  : "N/A",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Positioned(
                top: 12,
                right: 12,
                child: FavoriteButton(destination: destination),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
