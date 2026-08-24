import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/repositories/notification_repository.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final NotificationRepository _notificationRepository =
      NotificationRepository();

  bool _notificationsEnabled = true;

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;

    if (!enabled) {
      _localNotifications.cancelAll();
    }
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();

    await _messaging.requestPermission();

    final token = await _messaging.getToken();

    debugPrint("FCM Token: $token");

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (!_notificationsEnabled) return;

      await _localNotifications.show(
        0,
        message.notification?.title ?? "Voyara",
        message.notification?.body ?? "",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'voyara_channel',
            'Voyara Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  Future<void> showBookingSuccess({required String destination}) async {
    if (!_notificationsEnabled) return;
    const title = 'Trip Saved 🎉';
    final body = 'Your trip to $destination has been saved successfully!';

    await _localNotifications.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'voyara_channel',
          'Voyara Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    await _notificationRepository.addNotification(title: title, body: body);
  }

  Future<void> showTripReminder({required String destination}) async {
    if (!_notificationsEnabled) return;
    const title = "Trip Reminder ✈️";
    final body = "Your trip to $destination starts tomorrow.";

    await _localNotifications.show(
      2,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'voyara_channel',
          'Voyara Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    await _notificationRepository.addNotification(title: title, body: body);
  }

  Future scheduleTripReminder({
    required String destination,
    required DateTime travelDate,
  }) async {
    if (!_notificationsEnabled) return;

    final reminderTime = travelDate.subtract(const Duration(days: 1));

    // Don't schedule notifications in the past.
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _localNotifications.zonedSchedule(
      destination.hashCode,
      'Trip Reminder ✈️',
      'Your trip to $destination starts tomorrow.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'voyara_channel',
          'Voyara Notifications',
          channelDescription: 'Voyara travel notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
