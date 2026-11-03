import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../providers/search_controller_provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/popular_destinations_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/category_list.dart';
import '../widgets/home_action_cards.dart';
import '../widgets/nearby_places_home_section.dart';
import '../widgets/nearby_destinations_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveContentWrapper(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
            children: [
              // 1. App bar with compact scenic greeting banner
              const HomeAppBar(),

              const SizedBox(height: 18),

              // 2. Search bar below greeting
              SearchBarWidget(controller: ref.watch(searchControllerProvider)),

              const SizedBox(height: 20),

              // 3. Categories in horizontally scrollable row
              const CategoryList(),

              const SizedBox(height: 22),

              // 4. Two equally sized cards side by side: Plan a Trip with AI & My Trips
              const HomeActionCards(),

              const SizedBox(height: 26),

              // 5. Popular in India section
              const PopularDestinationsSection(),

              const SizedBox(height: 26),

              // 6. Recommended for You section
              const RecommendedSection(),

              const SizedBox(height: 26),

              // 7. Nearby Destinations
              const NearbyDestinationsSection(),

              const SizedBox(height: 26),

              // 8. Recently Viewed
              const RecentlyViewedSection(),

              const SizedBox(height: 26),

              // 9. Nearby Places
              const NearbyPlacesHomeSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
