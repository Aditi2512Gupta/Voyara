import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/favorite_model.dart';
import '../../../home/data/models/destination_model.dart';
import '../../../home/providers/home_provider.dart';

class FavoriteDestinationCard extends ConsumerWidget {
  const FavoriteDestinationCard({super.key, required this.destination});

  final FavoriteModel destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagesAsync = ref.watch(
      destinationImagesProvider(
        '${destination.title}, ${destination.location}',
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push(
              '/destination',
              extra: DestinationModel(
                id: destination.id,
                title: destination.title,
                location: destination.location,
                imageUrl: destination.imageUrl,
                rating: 4.8,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with floating favorite heart badge
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(17),
                        ),
                        child: imagesAsync.when(
                          loading: () => Container(
                            color: isDark
                                ? AppColors.inputDark
                                : AppColors.inputLight,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (_, __) => _buildFallbackImage(isDark),
                          data: (images) {
                            final validUrl = (images.isNotEmpty &&
                                    images.first.imageUrl.trim().isNotEmpty)
                                ? images.first.imageUrl
                                : destination.imageUrl;

                            if (validUrl.trim().isEmpty) {
                              return _buildFallbackImage(isDark);
                            }

                            return CachedNetworkImage(
                              imageUrl: validUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: isDark
                                    ? AppColors.inputDark
                                    : AppColors.inputLight,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) =>
                                  _buildFallbackImage(isDark),
                            );
                          },
                        ),
                      ),
                    ),

                    // Floating circular white heart button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await ref
                                .read(authRepositoryProvider)
                                .removeFavorite(destination.id);
                          },
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: AppColors.favoriteRed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card details: Title, Location, Rating
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.starYellow,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "4.8",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage(bool isDark) {
    if (destination.imageUrl.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: destination.imageUrl,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _defaultPlaceholder(isDark),
      );
    }
    return _defaultPlaceholder(isDark);
  }

  Widget _defaultPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.inputDark : AppColors.inputLight,
      child: Center(
        child: Icon(
          Icons.travel_explore,
          color: isDark ? AppColors.secondary : AppColors.primary,
          size: 32,
        ),
      ),
    );
  }
}
