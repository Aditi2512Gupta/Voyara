import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../providers/home_provider.dart';
import '../../data/models/destination_model.dart';
import 'favorite_button.dart';

class FeaturedDestinationCard extends ConsumerWidget {
  const FeaturedDestinationCard({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageQuery = "${destination.title}, ${destination.location}";
    final imagesAsync = ref.watch(destinationImagesProvider(imageQuery));

    final errorPlaceholder = Container(
      color: isDark ? AppColors.inputDark : AppColors.inputLight,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape_outlined,
            size: 40,
            color: AppColors.textTertiaryLight,
          ),
          const SizedBox(height: 6),
          Text(
            "Voyara",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.push('/destination', extra: destination);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'destination-${destination.id}',
                  child: imagesAsync.when(
                    loading: () => Container(
                      color: isDark ? AppColors.inputDark : AppColors.inputLight,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (_, __) {
                      if (destination.imageUrl.isEmpty) return errorPlaceholder;
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

                      if (imageUrl.isEmpty) return errorPlaceholder;

                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: isDark ? AppColors.inputDark : AppColors.inputLight,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => errorPlaceholder,
                      );
                    },
                  ),
                ),

                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 0.7],
                    ),
                  ),
                ),

                // Favorite button top right
                Positioned(
                  top: 14,
                  right: 14,
                  child: FavoriteButton(destination: destination, size: 36),
                ),

                // Content bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        destination.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              destination.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (destination.rating > 0) ...[
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.star,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              destination.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
