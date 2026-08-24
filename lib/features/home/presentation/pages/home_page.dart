import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/search_controller_provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/popular_destinations_section.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/category_list.dart';
import '../widgets/nearby_places_home_section.dart';
import '../widgets/nearby_destinations_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const HomeAppBar(),

              const SizedBox(height: 24),

              SearchBarWidget(controller: ref.watch(searchControllerProvider)),

              const SizedBox(height: 24),

              const CategoryList(),

              const SizedBox(height: 30),

              const NearbyDestinationsSection(),

              const SizedBox(height: 30),

              const RecentlyViewedSection(),

              const SizedBox(height: 30),

              const PopularDestinationsSection(),

              const SizedBox(height: 24),

              const NearbyPlacesHomeSection(),
            ],
          ),
        ),
      ),
    );
  }
}
