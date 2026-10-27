import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import 'category_icon.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase().trim();
    if (lower == 'all') return Icons.travel_explore_rounded;
    if (lower.contains('mall') || lower.contains('commercial complex')) {
      return Icons.local_mall_rounded;
    }
    if (lower.contains('market') || lower.contains('bazaar') || lower.contains('shop')) {
      return Icons.storefront_rounded;
    }
    if (lower.contains('mausoleum') || lower.contains('tomb')) {
      return Icons.account_balance_rounded;
    }
    if (lower.contains('national park')) {
      return Icons.forest_rounded;
    }
    if (lower.contains('theme park') ||
        lower.contains('amusement') ||
        lower.contains('entertainment') ||
        lower.contains('film studio') ||
        lower.contains('race track')) {
      return Icons.attractions_rounded;
    }
    if (lower.contains('war memorial') ||
        lower.contains('memorial') ||
        lower.contains('monument') ||
        lower.contains('landmark')) {
      return Icons.military_tech_rounded;
    }
    if (lower.contains('stepwell') ||
        lower.contains('baori') ||
        lower.contains('bawdi')) {
      return Icons.stairs_rounded;
    }
    if (lower.contains('village') ||
        lower.contains('township') ||
        lower.contains('town')) {
      return Icons.holiday_village_rounded;
    }
    if (lower.contains('religious') ||
        lower.contains('church') ||
        lower.contains('mosque') ||
        lower.contains('gurudwara') ||
        lower.contains('monastery') ||
        lower.contains('shrine') ||
        lower.contains('spiritual')) {
      return Icons.temple_hindu_rounded;
    }
    if (lower.contains('museum') ||
        lower.contains('science') ||
        lower.contains('observatory') ||
        lower.contains('government building')) {
      return Icons.museum_rounded;
    }
    if (lower == 'park' ||
        lower.contains('botanical') ||
        lower.contains('garden') ||
        lower.contains('orchard') ||
        lower.contains('vineyard')) {
      return Icons.park_rounded;
    }
    if (lower.contains('attract') || lower.contains('camera')) {
      return Icons.camera_alt_rounded;
    }
    if (lower.contains('bird')) {
      return Icons.flutter_dash;
    }
    if (lower.contains('cultur') ||
        lower.contains('temple') ||
        lower.contains('architect') ||
        lower.contains('heritage') ||
        lower.contains('historic') ||
        lower.contains('rock carving') ||
        lower.contains('prehistoric')) {
      return Icons.temple_hindu_rounded;
    }
    if (lower.contains('fort') || lower.contains('castle') || lower.contains('palace')) {
      return Icons.fort_rounded;
    }
    if (lower.contains('ghat') || lower.contains('sunrise') || lower.contains('confluence')) {
      return Icons.wb_twilight_rounded;
    }
    if (lower.contains('lake') || lower.contains('water') || lower.contains('dam') || lower.contains('aquarium')) {
      return Icons.water_rounded;
    }
    if (lower.contains('beach') || lower.contains('palm') || lower.contains('coast') || lower.contains('island')) {
      return Icons.beach_access_rounded;
    }
    if (lower.contains('hill') || lower.contains('mountain') || lower.contains('valley') || lower.contains('ski')) {
      return Icons.terrain_rounded;
    }
    if (lower.contains('wildlife') || lower.contains('deer') || lower.contains('zoo') || lower.contains('safari')) {
      return Icons.pets_rounded;
    }
    if (lower.contains('adventure') || lower.contains('hike') || lower.contains('trek') || lower.contains('sport')) {
      return Icons.hiking_rounded;
    }
    if (lower.contains('cit')) return Icons.location_city_rounded;
    if (lower.contains('bridge')) return Icons.polyline_rounded;
    return Icons.explore_rounded;
  }

  Color _getCategoryColor(String name) {
    final lower = name.toLowerCase().trim();
    if (lower == 'all') return AppColors.secondary;
    if (lower.contains('mall') || lower.contains('commercial complex')) return AppColors.secondary;
    if (lower.contains('market') || lower.contains('bazaar') || lower.contains('shop')) return AppColors.tertiary;
    if (lower.contains('mausoleum') || lower.contains('tomb')) return const Color(0xFFE5A93C);
    if (lower.contains('national park')) return const Color(0xFF0E8E89);
    if (lower.contains('theme park') || lower.contains('amusement') || lower.contains('entertainment')) return AppColors.tertiary;
    if (lower.contains('war memorial') || lower.contains('memorial') || lower.contains('monument')) return AppColors.mint;
    if (lower.contains('stepwell') || lower.contains('baori')) return const Color(0xFFE5A93C);
    if (lower.contains('village') || lower.contains('town')) return const Color(0xFFD97706);
    if (lower.contains('religious') || lower.contains('church') || lower.contains('mosque')) return AppColors.categoryTemple;
    if (lower.contains('museum') || lower.contains('science')) return const Color(0xFF8B5CF6);
    if (lower == 'park' || lower.contains('botanical') || lower.contains('garden')) return AppColors.mint;
    if (lower.contains('attract') || lower.contains('camera')) return AppColors.secondary;
    if (lower.contains('bird')) return AppColors.mint;
    if (lower.contains('cultur') || lower.contains('temple')) return AppColors.tertiary;
    if (lower.contains('fort') || lower.contains('castle')) return const Color(0xFFE5A93C);
    if (lower.contains('ghat') || lower.contains('sunrise')) return AppColors.tertiary;
    if (lower.contains('lake') || lower.contains('water')) return AppColors.secondary;
    if (lower.contains('beach') || lower.contains('palm')) return AppColors.categoryBeach;
    if (lower.contains('hill') || lower.contains('mountain')) return AppColors.categoryMountain;
    if (lower.contains('wildlife') || lower.contains('deer')) return AppColors.tertiary;
    if (lower.contains('adventure') || lower.contains('hike')) return AppColors.mint;
    if (lower.contains('cit')) return AppColors.categoryCity;
    return AppColors.secondary;
  }

  Color _getCategoryBg(String name) {
    final lower = name.toLowerCase().trim();
    if (lower == 'all') return AppColors.secondaryLight;
    if (lower.contains('mall') || lower.contains('commercial complex')) return AppColors.secondaryLight;
    if (lower.contains('market') || lower.contains('bazaar') || lower.contains('shop')) return AppColors.tertiaryLight;
    if (lower.contains('mausoleum') || lower.contains('tomb')) return const Color(0xFFFEF3C7);
    if (lower.contains('national park')) return const Color(0xFFE6F6F5);
    if (lower.contains('theme park') || lower.contains('amusement') || lower.contains('entertainment')) return AppColors.tertiaryLight;
    if (lower.contains('war memorial') || lower.contains('memorial') || lower.contains('monument')) return AppColors.mintLight;
    if (lower.contains('stepwell') || lower.contains('baori')) return const Color(0xFFFEF3C7);
    if (lower.contains('village') || lower.contains('town')) return const Color(0xFFFEF3C7);
    if (lower.contains('religious') || lower.contains('church') || lower.contains('mosque')) return AppColors.categoryTempleBg;
    if (lower.contains('museum') || lower.contains('science')) return const Color(0xFFF3E8FF);
    if (lower == 'park' || lower.contains('botanical') || lower.contains('garden')) return AppColors.mintLight;
    if (lower.contains('attract') || lower.contains('camera')) return AppColors.secondaryLight;
    if (lower.contains('bird')) return AppColors.mintLight;
    if (lower.contains('cultur') || lower.contains('temple')) return AppColors.tertiaryLight;
    if (lower.contains('fort') || lower.contains('castle')) return const Color(0xFFFEF3C7);
    if (lower.contains('ghat') || lower.contains('sunrise')) return AppColors.tertiaryLight;
    if (lower.contains('lake') || lower.contains('water')) return AppColors.secondaryLight;
    if (lower.contains('beach') || lower.contains('palm')) return AppColors.categoryBeachBg;
    if (lower.contains('hill') || lower.contains('mountain')) return AppColors.categoryMountainBg;
    if (lower.contains('wildlife') || lower.contains('deer')) return AppColors.tertiaryLight;
    if (lower.contains('adventure') || lower.contains('hike')) return AppColors.categoryAdventureBg;
    if (lower.contains('cit')) return AppColors.categoryCityBg;
    return AppColors.secondaryLight;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getCategoryColor(label);
    final bg = _getCategoryBg(label);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.primary
                    : (isDark ? AppColors.surfaceDark : bg),
                border: Border.all(
                  color: selected
                      ? (isDark ? AppColors.secondary : AppColors.primary)
                      : (isDark ? AppColors.borderDark : color.withValues(alpha: 0.2)),
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: CategoryIcon(
                category: label,
                isSelected: selected,
                isDark: isDark,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
