import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/destination_model.dart';
import '../../../favorites/providers/favorites_provider.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.destination, this.size = 38});

  final DestinationModel destination;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return favoritesAsync.when(
      loading: () => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: size * 0.45,
          height: size * 0.45,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),

      error: (_, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: size * 0.55,
          icon: const Icon(Icons.favorite_border, color: Color(0xFFEF4444)),
          onPressed: null,
        ),
      ),

      data: (favorites) {
        final isFavorite = favorites.any((item) => item.id == destination.id);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: size * 0.55,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF6B7A78),
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
