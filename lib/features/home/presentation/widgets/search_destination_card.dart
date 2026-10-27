import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/destination_model.dart';
import 'favorite_button.dart';

class SearchDestinationCard extends StatelessWidget {
  const SearchDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  final DestinationModel destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = destination.imageUrl.trim().isNotEmpty;
    final isFree = destination.price == null || destination.price == 0;
    final priceText = isFree
        ? "Free"
        : "₹${destination.price!.toStringAsFixed(0)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // 1. Destination Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 95,
                    height: 95,
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: destination.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: isDark ? AppColors.inputDark : AppColors.inputLight,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: isDark ? AppColors.inputDark : AppColors.inputLight,
                              child: Icon(
                                Icons.landscape_outlined,
                                color: AppColors.textTertiaryLight,
                              ),
                            ),
                          )
                        : Container(
                            color: isDark ? AppColors.inputDark : AppColors.inputLight,
                            child: Icon(
                              Icons.travel_explore,
                              size: 32,
                              color: isDark ? AppColors.secondary : AppColors.primary,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 14),

                // 2. Destination Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        destination.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: isDark ? AppColors.secondary : AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              destination.location.isEmpty
                                  ? "Popular Attraction"
                                  : destination.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Bottom Row: Rating & Price tag
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.star,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            destination.rating > 0
                                ? destination.rating.toStringAsFixed(1)
                                : "4.6",
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            " (${destination.reviewCount > 0 ? destination.reviewCount : '1.2k'})",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiaryLight,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isFree
                                  ? AppColors.mintLight
                                  : AppColors.orangeLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              priceText,
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

                const SizedBox(width: 8),

                // 3. Heart Favorite Button
                FavoriteButton(destination: destination, size: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
