import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../providers/favorites_provider.dart';
import '../widgets/favorite_destination_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("My Favorites")),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(child: Text(error.toString())),

        data: (favorites) {
          if (favorites.isEmpty) {
            return const EmptyStateWidget(
              message: "You haven't added any favorites yet.",
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) {
              return FavoriteDestinationCard(destination: favorites[index]);
            },
          );
        },
      ),
    );
  }
}
