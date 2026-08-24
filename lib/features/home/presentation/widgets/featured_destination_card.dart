import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/home_provider.dart';
import '../../data/models/destination_model.dart';

class FeaturedDestinationCard extends ConsumerWidget {
  const FeaturedDestinationCard({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageQuery = "${destination.title}, ${destination.location}";
    final imagesAsync = ref.watch(destinationImagesProvider(imageQuery));

    final errorPlaceholder = Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 6),
          Text(
            "Image unavailable",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        context.push('/destination', extra: destination);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Hero(
              tag: 'destination-${destination.id}',
              child: imagesAsync.when(
                loading: () => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),

                error: (_, __) {
                  if (destination.imageUrl.isEmpty) {
                    return errorPlaceholder;
                  }

                  return CachedNetworkImage(
                    imageUrl: destination.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => errorPlaceholder,
                  );
                },

                data: (images) {
                  final imageUrl = images.isNotEmpty
                      ? images.first.imageUrl
                      : destination.imageUrl;

                  if (imageUrl.isEmpty) {
                    return errorPlaceholder;
                  }

                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => errorPlaceholder,
                  );
                },
              ),
            ),

            Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    destination.location,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  if (destination.categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 6,
                        children: destination.categories
                            .take(3)
                            .map(
                              (category) => Chip(
                                label: Text(category),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
