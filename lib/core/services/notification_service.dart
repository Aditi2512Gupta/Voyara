import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../app/router/app_router.dart';
import '../data/repositories/notification_repository.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _notificationsEnabledKey = 'voyara_notifications_enabled';
  static const String channelId = 'voyara_channel';
  static const String channelName = 'Voyara Notifications';
  static const String channelDesc = 'Voyara travel updates and reminders';
  static const int dailyNotificationId = 999;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationRepository? _notificationRepositoryInstance;
  NotificationRepository get _notificationRepository =>
      _notificationRepositoryInstance ??= NotificationRepository();

  FirebaseMessaging? get _messaging {
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }

  bool _notificationsEnabled = true;

  bool get areNotificationsEnabled => _notificationsEnabled;

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      debugPrint("Error persisting notification preference: $e");
    }

    if (!enabled) {
      try {
        await _localNotifications.cancelAll();
      } catch (e) {
        debugPrint("Error cancelling notifications: $e");
      }
    } else {
      try {
        await scheduleDailyNotification();
      } catch (e) {
        debugPrint("Error scheduling daily notification: $e");
      }
    }
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {}

    // 1. Restore persisted ON/OFF state from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      debugPrint("Error reading notification preferences: $e");
    }

    // 2. Initialize Flutter Local Notifications
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const settings = InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationPayload(response.payload);
        },
      );

      // 3. Register explicit notification channel in Android
      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        await androidPlugin.requestNotificationsPermission();
      }

      // 4. Handle launch payload if the app was opened via notification from terminated state
      final launchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true) {
        final payload = launchDetails?.notificationResponse?.payload;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationPayload(payload);
        });
      }
    } catch (e) {
      debugPrint("Error initializing local notifications: $e");
    }

    // 5. Initialize Firebase Cloud Messaging if available
    try {
      final messaging = _messaging;
      if (messaging != null) {
        await messaging.requestPermission();

        final token = await messaging.getToken();
        debugPrint("FCM Token: $token");

        // Foreground messages listener
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          if (!_notificationsEnabled) return;

          try {
            await _localNotifications.show(
              0,
              message.notification?.title ?? "Voyara",
              message.notification?.body ?? "",
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  channelId,
                  channelName,
                  channelDescription: channelDesc,
                  importance: Importance.max,
                  priority: Priority.high,
                  icon: '@mipmap/ic_launcher',
                ),
              ),
              payload: message.data['route'] as String? ?? '/notifications',
            );
          } catch (e) {
            debugPrint("Error showing foreground push notification: $e");
          }
        });

        // Notification tap when app was in background
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          final route = message.data['route'] as String? ?? '/notifications';
          _handleNotificationPayload(route);
        });

        // Notification tap when app was launched from terminated state (FCM)
        final initialMessage = await messaging.getInitialMessage();
        if (initialMessage != null) {
          final route =
              initialMessage.data['route'] as String? ?? '/notifications';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleNotificationPayload(route);
          });
        }
      }
    } catch (e) {
      debugPrint("Firebase Messaging initialization error: $e");
    }

    // 6. Schedule daily notification if notifications are enabled
    if (_notificationsEnabled) {
      try {
        await scheduleDailyNotification();
      } catch (e) {
        debugPrint("Error scheduling daily notification on initialize: $e");
      }
    }
  }

  void _handleNotificationPayload(String? payload) {
    final route = (payload != null && payload.isNotEmpty)
        ? payload
        : '/notifications';

    try {
      appRouter.push(route);
    } catch (e) {
      debugPrint("Failed to route notification payload $route: $e");
    }
  }

  Future<void> showBookingSuccess({required String destination}) async {
    if (!_notificationsEnabled) return;
    const title = 'Trip Saved 🎉';
    final body = 'Your trip to $destination has been saved successfully!';

    try {
      await _localNotifications.show(
        1,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: '/notifications',
      );
    } catch (e) {
      debugPrint("Error displaying booking notification: $e");
    }

    try {
      await _notificationRepository.addNotification(title: title, body: body);
    } catch (e) {
      debugPrint("Could not persist notification: $e");
    }
  }

  Future<void> showTripReminder({required String destination}) async {
    if (!_notificationsEnabled) return;
    const title = "Trip Reminder ✈️";
    final body = "Your trip to $destination starts tomorrow.";

    try {
      await _localNotifications.show(
        2,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: '/notifications',
      );
    } catch (e) {
      debugPrint("Error displaying trip reminder: $e");
    }

    try {
      await _notificationRepository.addNotification(title: title, body: body);
    } catch (e) {
      debugPrint("Could not persist notification: $e");
    }
  }

  tz.Location _safeLocalLocation() {
    tz.initializeTimeZones();
    try {
      return tz.local;
    } catch (_) {
      try {
        final loc = tz.getLocation('Asia/Kolkata');
        tz.setLocalLocation(loc);
        return loc;
      } catch (_) {
        final utc = tz.UTC;
        tz.setLocalLocation(utc);
        return utc;
      }
    }
  }

  Future<void> scheduleTripReminder({
    required String destination,
    required DateTime travelDate,
    String? tripId,
  }) async {
    if (!_notificationsEnabled) return;

    // Schedule for 9:00 AM on the day before the trip starts
    final dayBefore = travelDate.subtract(const Duration(days: 1));
    final reminderTime = DateTime(
      dayBefore.year,
      dayBefore.month,
      dayBefore.day,
      9,
      0,
    );

    // Don't schedule notifications in the past.
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final location = _safeLocalLocation();
    final scheduledDate = tz.TZDateTime.from(reminderTime, location);
    final notificationId = tripId != null
        ? (tripId.hashCode.abs() % 100000 + 1000)
        : (destination.hashCode.abs() % 100000 + 1000);

    try {
      await _localNotifications.zonedSchedule(
        notificationId,
        'Trip Reminder ✈️',
        'Your trip to $destination starts tomorrow.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: '/notifications',
      );
    } catch (e) {
      debugPrint("Error scheduling trip reminder: $e");
    }
  }

  Future<void> cancelTripReminder(String identifier) async {
    try {
      final notificationId = (identifier.hashCode.abs() % 100000 + 1000);
      await _localNotifications.cancel(notificationId);
    } catch (e) {
      debugPrint("Error cancelling trip reminder: $e");
    }
  }

  Future<void> scheduleDailyNotification({
    int hour = 9,
    int minute = 0,
  }) async {
    if (!_notificationsEnabled) return;

    final location = _safeLocalLocation();
    final now = tz.TZDateTime.now(location);
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _localNotifications.zonedSchedule(
        dailyNotificationId,
        'Daily Travel Inspiration 🌍',
        'Ready for your next trip? Explore trending destinations in Voyara!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/home',
      );
    } catch (e) {
      debugPrint("Error scheduling daily notification: $e");
    }
  }

  Future<void> cancelDailyNotification() async {
    try {
      await _localNotifications.cancel(dailyNotificationId);
    } catch (e) {
      debugPrint("Error cancelling daily notification: $e");
    }
  }
}
