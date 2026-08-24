import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationsProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  return ref
      .read(notificationRepositoryProvider)
      .notifications();
});