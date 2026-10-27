import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyara/core/data/models/notification_model.dart';
import 'package:voyara/core/data/repositories/notification_repository.dart';
import 'package:voyara/core/providers/notification_provider.dart';
import 'package:voyara/features/home/presentation/widgets/home_app_bar.dart';
import 'package:voyara/features/notifications/presentation/pages/notifications_page.dart';
import 'package:voyara/features/profile/data/models/user_profile_model.dart';
import 'package:voyara/features/profile/providers/profile_provider.dart';
import 'package:voyara/shared/widgets/voyara_logo.dart';

class MockNotificationRepository implements NotificationRepository {
  List<NotificationModel> notificationList = [];
  bool markAllCalled = false;
  String? markedReadId;
  String? deletedId;

  @override
  Stream<List<NotificationModel>> notifications() {
    return Stream.value(notificationList);
  }

  @override
  Future<void> addNotification({required String title, required String body}) async {}

  @override
  Future<void> markAsRead(String notificationId) async {
    markedReadId = notificationId;
  }

  @override
  Future<void> markAllAsRead() async {
    markAllCalled = true;
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    deletedId = notificationId;
  }
}

void main() {
  group('HomeAppBar Widget Tests', () {
    testWidgets('Renders Voyara logo, app name, greeting, bell, and avatar',
        (WidgetTester tester) async {
      final mockRepo = MockNotificationRepository();
      mockRepo.notificationList = [
        NotificationModel(
          id: '1',
          title: 'Trip Confirmed',
          body: 'Your trip to Goa is booked.',
          createdAt: DateTime.now(),
          read: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider.overrideWith((ref) => Stream.value(mockRepo.notificationList)),
            profileProvider.overrideWith(
              (ref) => Future.value(
                UserProfileModel(
                  name: 'Aditi Gupta',
                  email: 'aditi@example.com',
                  photoUrl: '',
                  phone: '1234567890',
                  joinedOn: DateTime.now(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16),
                child: HomeAppBar(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Brand name & logo
      expect(find.text('Voyara'), findsOneWidget);
      expect(find.byType(VoyaraLogo), findsOneWidget);

      // Greeting & User name
      expect(find.textContaining('Aditi 👋'), findsOneWidget);
      expect(find.text('Discover amazing destinations around the world'), findsOneWidget);

      // Notification icon and unread badge
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Profile avatar with initial 'A'
      expect(find.text('A'), findsOneWidget);
    });
  });

  group('NotificationsPage Widget Tests', () {
    testWidgets('Renders empty state with All Caught Up when no notifications',
        (WidgetTester tester) async {
      final mockRepo = MockNotificationRepository();
      mockRepo.notificationList = [];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider.overrideWith((ref) => Stream.value(mockRepo.notificationList)),
            notificationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('All Caught Up!'), findsOneWidget);
      expect(find.textContaining('You don\'t have any notifications'), findsOneWidget);
      expect(find.text('Discover Destinations'), findsOneWidget);
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('Renders modern notification cards, groups by date, and styles Mark all read',
        (WidgetTester tester) async {
      final mockRepo = MockNotificationRepository();
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      mockRepo.notificationList = [
        NotificationModel(
          id: 'n1',
          title: 'Special Flight Discount',
          body: 'Get 20% off on Mumbai flights today!',
          createdAt: now,
          read: false,
        ),
        NotificationModel(
          id: 'n2',
          title: 'Booking Completed',
          body: 'Your reservation at Taj Lake Palace is confirmed.',
          createdAt: yesterday,
          read: true,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider.overrideWith((ref) => Stream.value(mockRepo.notificationList)),
            notificationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title & Mark all read pill button
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      // Date Group Headers
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);

      // Notification cards
      expect(find.text('Special Flight Discount'), findsOneWidget);
      expect(find.text('Booking Completed'), findsOneWidget);

      // Tap Mark all read
      await tester.tap(find.text('Mark all read'));
      await tester.pump();
      expect(mockRepo.markAllCalled, isTrue);

      // Tap unread notification card to mark as read
      await tester.tap(find.text('Special Flight Discount'));
      await tester.pump();
      expect(mockRepo.markedReadId, equals('n1'));
    });
  });
}
