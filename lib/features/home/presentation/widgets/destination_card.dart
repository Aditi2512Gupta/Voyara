import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../providers/home_provider.dart';
import '../../data/models/destination_model.dart';
import 'favorite_button.dart';

class DestinationCard extends ConsumerWidget {
  const DestinationCard({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDatasetImage = destination.imageUrl.trim().isNotEmpty;

    // Search Unsplash when dataset has no image
    final imageQuery = "${destination.title}, ${destination.location}";
    final imagesAsync = ref.watch(destinationImagesProvider(imageQuery));

    final errorPlaceholder = Container(
      color: isDark ? AppColors.inputDark : AppColors.inputLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_outlined,
              size: 32,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(height: 4),
            Text(
              "Voyara",
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiaryLight,
                fontWeight: FontWeight.w600,
              ),
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
        placeholder: (_, _) => Container(
          color: isDark ? AppColors.inputDark : AppColors.inputLight,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, _, _) => errorPlaceholder,
      );
    }

    Widget imageWidget() {
      if (hasDatasetImage) {
        return CachedNetworkImage(
          imageUrl: destination.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (_, _) => Container(
            color: isDark ? AppColors.inputDark : AppColors.inputLight,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, _, _) {
            return imagesAsync.maybeWhen(
              data: (images) => images.isNotEmpty
                  ? buildImage(images.first.imageUrl)
                  : errorPlaceholder,
              orElse: () => errorPlaceholder,
            );
          },
        );
      }

      return imagesAsync.when(
        loading: () => Container(
          color: isDark ? AppColors.inputDark : AppColors.inputLight,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, _) => errorPlaceholder,
        data: (images) {
          if (images.isEmpty) return errorPlaceholder;
          return buildImage(images.first.imageUrl);
        },
      );
    }

    final isFree = destination.price == null || destination.price == 0;

    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
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
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/destination', extra: destination);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with floating favorite button & badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(19),
                    ),
                    child: SizedBox(
                      height: 145,
                      width: double.infinity,
                      child: Hero(
                        tag: 'destination-${destination.id}',
                        child: imageWidget(),
                      ),
                    ),
                  ),

                  // Heart button top right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FavoriteButton(destination: destination, size: 34),
                  ),

                  // Category badge top left if present
                  if (destination.categories.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          destination.categories.first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Details
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      destination.title.isEmpty
                          ? "Destination"
                          : destination.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: isDark
                              ? AppColors.secondary
                              : AppColors.primary,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            destination.location.isNotEmpty
                                ? destination.location
                                : "Popular Spot",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Rating & Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.star,
                              size: 18,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              destination.rating > 0
                                  ? destination.rating.toStringAsFixed(1)
                                  : "4.8",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              " (${destination.reviewCount > 0 ? destination.reviewCount : '1.2k'})",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        ),

                        // Price tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: isFree
                                ? AppColors.mintLight
                                : AppColors.orangeLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isFree
                                ? "Free"
                                : "₹${destination.price!.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isFree
                                  ? AppColors.primary
                                  : AppColors.tertiary,
                            ),
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
}
