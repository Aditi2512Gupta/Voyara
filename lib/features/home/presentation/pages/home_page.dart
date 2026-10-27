import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../providers/search_controller_provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/popular_destinations_section.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/category_list.dart';
import '../widgets/nearby_places_home_section.dart';
import '../widgets/nearby_destinations_section.dart';
import '../widgets/plan_with_ai_floating_button.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const HomeAppBar(),

            const SizedBox(height: 20),

            SearchBarWidget(controller: ref.watch(searchControllerProvider)),

            const SizedBox(height: 22),

            const CategoryList(),

            const SizedBox(height: 26),

            const PopularDestinationsSection(),

            const SizedBox(height: 26),

            const NearbyDestinationsSection(),

            const SizedBox(height: 26),

            const RecentlyViewedSection(),

            const SizedBox(height: 26),

            const NearbyPlacesHomeSection(),

            const SizedBox(height: 84),
          ],
        ),
      ),
      floatingActionButton: const PlanWithAiFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
