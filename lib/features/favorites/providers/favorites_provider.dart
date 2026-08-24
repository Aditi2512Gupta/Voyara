import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/favorite_model.dart';

final favoritesProvider =
    StreamProvider<List<FavoriteModel>>((ref) {
  return ref.read(authRepositoryProvider).favorites();
});