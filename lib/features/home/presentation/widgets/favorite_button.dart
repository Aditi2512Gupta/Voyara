import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/destination_model.dart';
import '../../../favorites/providers/favorites_provider.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return favoritesAsync.when(
      loading: () => const CircleAvatar(
        backgroundColor: Colors.white,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),

      error: (_, __) => const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.favorite_border, color: Colors.red),
      ),

      data: (favorites) {
        final isFavorite = favorites.any((item) => item.id == destination.id);

        return CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () async {
              final repo = ref.read(authRepositoryProvider);

              if (isFavorite) {
                await repo.removeFavorite(destination.id);
              } else {
                await repo.addFavorite(destination);
              }
            },
          ),
        );
      },
    );
  }
}
