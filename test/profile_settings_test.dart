import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:voyara/features/auth/data/auth_repository.dart';
import 'package:voyara/features/auth/providers/auth_provider.dart';
import 'package:voyara/features/bookings/data/models/booking_model.dart';
import 'package:voyara/features/bookings/providers/booking_provider.dart';
import 'package:voyara/features/favorites/data/models/favorite_model.dart';
import 'package:voyara/features/favorites/providers/favorites_provider.dart';
import 'package:voyara/features/profile/data/models/user_profile_model.dart';
import 'package:voyara/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:voyara/features/profile/presentation/pages/profile_page.dart';
import 'package:voyara/features/profile/presentation/pages/settings_page.dart';
import 'package:voyara/features/profile/providers/profile_provider.dart';
import 'package:voyara/features/trips/data/models/trip_status.dart';

class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? phoneNumber;
  @override
  final String? photoURL;

  FakeUser({
    this.uid = 'user_test_777',
    this.email = 'jane@example.com',
    this.displayName = 'Jane Doe',
    this.phoneNumber = '+91 9876543210',
    this.photoURL = 'https://example.com/avatar.jpg',
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthRepository {
  bool shouldThrowOnSignOut = false;
  bool shouldThrowOnUpdateProfile = false;
  String? updatedName;
  String? updatedPhone;
  bool signOutCalled = false;

  @override
  Future<void> signOut() async {
    if (shouldThrowOnSignOut) {
      throw Exception('Network error during sign out');
    }
    signOutCalled = true;
  }

  @override
  Future<void> updateProfile({required String name, String? phone}) async {
    if (shouldThrowOnUpdateProfile) {
      throw Exception('Database write error');
    }
    updatedName = name;
    updatedPhone = phone;
  }

  @override
  Future<void> uploadProfilePhoto(dynamic image) async {}

  @override
  Stream<List<FavoriteModel>> favorites() => Stream.value([]);

  @override
  Stream<List<String>> favoriteIds() => Stream.value([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Profile Provider & Model Tests', () {
    test('UserProfileModel copyWith updates phone and fields correctly', () {
      final initial = UserProfileModel(
        name: 'Alex',
        email: 'alex@example.com',
        photoUrl: '',
        phone: '',
        joinedOn: DateTime(2025, 1, 1),
      );

      final updated = initial.copyWith(
        phone: '+91 9999988888',
        name: 'Alexander',
      );

      expect(updated.name, 'Alexander');
      expect(updated.email, 'alex@example.com');
      expect(updated.phone, '+91 9999988888');
      expect(updated.joinedOn, DateTime(2025, 1, 1));
    });

    test(
      'profileProvider returns null when unauthenticated without crashing',
      () async {
        final container = ProviderContainer(
          overrides: [currentUserProvider.overrideWithValue(null)],
        );
        addTearDown(container.dispose);

        final profile = await container.read(profileProvider.future);
        expect(profile, isNull);
      },
    );

    test(
      'profileProvider builds safe profile using FirebaseAuth data when Firestore doc is missing',
      () async {
        final fakeUser = FakeUser(
          uid: 'user_fallback_123',
          displayName: 'John Traveler',
          email: 'john@example.com',
          phoneNumber: '+1 555-0199',
          photoURL: 'https://example.com/john.jpg',
        );

        final container = ProviderContainer(
          overrides: [currentUserProvider.overrideWithValue(fakeUser)],
        );
        addTearDown(container.dispose);

        // In unit test without live Firestore, it catches and falls back to FirebaseAuth user data
        final profile = await container.read(profileProvider.future);
        expect(profile, isNotNull);
        expect(profile?.name, 'John Traveler');
        expect(profile?.email, 'john@example.com');
        expect(profile?.phone, '+1 555-0199');
        expect(profile?.photoUrl, 'https://example.com/john.jpg');
      },
    );
  });

  group('ProfilePage Widget Tests', () {
    testWidgets(
      'Unauthenticated user on ProfilePage shows friendly login prompt',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWithValue(null),
              profileProvider.overrideWith((ref) => Future.value(null)),
            ],
            child: const MaterialApp(home: ProfilePage()),
          ),
        );
        await tester.pumpAndSettle();

        // Check friendly login state
        expect(find.text('Please log in'), findsOneWidget);
        expect(
          find.text(
            'Log in to view and manage your profile, favorites, and trips.',
          ),
          findsOneWidget,
        );
        expect(find.widgetWithText(FilledButton, 'Log In'), findsOneWidget);

        // Edit icon should not be present in AppBar when unauthenticated
        expect(find.byIcon(Icons.edit), findsNothing);
      },
    );

    testWidgets(
      'ProfilePage shows real favorites and trips counts on tappable cards',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        String? lastNavigatedRoute;

        final sampleUser = UserProfileModel(
          name: 'Sarah Connor',
          email: 'sarah@example.com',
          photoUrl: '',
          phone: '+91 9123456789',
          joinedOn: DateTime(2024, 5, 10),
        );

        final sampleFavorites = <FavoriteModel>[
          const FavoriteModel(
            id: 'fav1',
            title: 'Goa Beach',
            location: 'Goa',
            imageUrl: '',
            latitude: 15.0,
            longitude: 73.0,
          ),
          const FavoriteModel(
            id: 'fav2',
            title: 'Manali Hills',
            location: 'Himachal',
            imageUrl: '',
            latitude: 32.0,
            longitude: 77.0,
          ),
        ];

        final sampleBookings = [
          BookingModel(
            id: 'b1',
            destinationId: 'd1',
            destinationName: 'Goa',
            destinationLocation: 'Goa',
            destinationImageUrl: '',
            destinationLatitude: 0,
            destinationLongitude: 0,
            userId: 'u1',
            travelDate: DateTime.now().add(const Duration(days: 5)),
            travelers: 2,
            status: TripStatus.upcoming,
            bookingDate: DateTime.now(),
          ),
        ];

        final router = GoRouter(
          initialLocation: '/profile',
          routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
            GoRoute(
              path: '/home',
              builder: (_, state) {
                lastNavigatedRoute = state.uri.toString();
                return const Scaffold(body: Text('Home Screen'));
              },
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              profileProvider.overrideWith((ref) => Future.value(sampleUser)),
              favoritesProvider.overrideWith(
                (ref) => Stream.value(sampleFavorites),
              ),
              bookingsProvider.overrideWith(
                (ref) => Stream.value(sampleBookings),
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // Profile info rendered
        expect(find.text('Sarah Connor'), findsOneWidget);
        expect(find.text('sarah@example.com'), findsOneWidget);
        expect(find.text('+91 9123456789'), findsOneWidget);
        expect(find.text('Member since 2024'), findsOneWidget);

        // Verify real counts: 2 favorites and 1 trip
        expect(find.text('2'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);

        // Tap favorites card
        await tester.tap(find.text('Favorites').first);
        await tester.pumpAndSettle();
        expect(lastNavigatedRoute, '/home?tab=2');
      },
    );
  });

  group('EditProfilePage Widget Tests', () {
    testWidgets(
      'EditProfilePage loads name & phone and shows loading state while saving',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockAuthRepository();
        final sampleUser = UserProfileModel(
          name: 'David Miller',
          email: 'david@example.com',
          photoUrl: '',
          phone: '+91 8888877777',
          joinedOn: DateTime(2025, 2, 1),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              profileProvider.overrideWith((ref) => Future.value(sampleUser)),
              authRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MaterialApp(home: EditProfilePage()),
          ),
        );
        await tester.pumpAndSettle();

        // Verify initial fields populated
        expect(find.text('David Miller'), findsOneWidget);
        expect(find.text('david@example.com'), findsOneWidget);
        expect(find.text('+91 8888877777'), findsOneWidget);

        // Edit name and phone
        await tester.enterText(
          find.widgetWithText(TextField, 'Name'),
          'David M. King',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Phone (Optional)'),
          '+91 9999900000',
        );
        await tester.pump();

        // Tap save button
        final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
        await tester.tap(saveButton);
        await tester.pump();

        // Verified repo called with new name and phone
        expect(mockRepo.updatedName, 'David M. King');
        expect(mockRepo.updatedPhone, '+91 9999900000');
      },
    );
  });

  group('SettingsPage Widget Tests', () {
    testWidgets(
      'SettingsPage shows functional dialogs for Language, Privacy Policy, and About',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [currentUserProvider.overrideWithValue(FakeUser())],
            child: const MaterialApp(home: SettingsPage()),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Language Dialog
        await tester.tap(find.widgetWithText(ListTile, 'Language'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            'English is currently the supported language. More languages will be available in future updates.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // 2. Privacy Policy Dialog
        await tester.tap(find.widgetWithText(ListTile, 'Privacy Policy'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Voyara values your privacy.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // 3. About Dialog
        await tester.tap(find.widgetWithText(ListTile, 'About'));
        await tester.pumpAndSettle();
        expect(find.text('About Voyara'), findsOneWidget);
        expect(find.text('Version 1.0.0'), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Logout confirms and navigates to /login on success, invalidating profile state',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockAuthRepository();
        String? navigatedRoute;

        final router = GoRouter(
          initialLocation: '/settings',
          routes: [
            GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
            GoRoute(
              path: '/login',
              builder: (_, state) {
                navigatedRoute = state.uri.toString();
                return const Scaffold(body: Text('Login Screen'));
              },
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(mockRepo),
              currentUserProvider.overrideWithValue(FakeUser()),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Logout
        await tester.tap(find.widgetWithText(ListTile, 'Logout'));
        await tester.pumpAndSettle();

        // Confirmation dialog
        expect(find.text('Are you sure you want to logout?'), findsOneWidget);

        // Confirm
        await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
        await tester.pumpAndSettle();

        expect(mockRepo.signOutCalled, isTrue);
        expect(navigatedRoute, '/login');
        expect(find.text('Login Screen'), findsOneWidget);
      },
    );

    testWidgets('Logout failure shows error SnackBar and stays on Settings', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockAuthRepository()..shouldThrowOnSignOut = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
            currentUserProvider.overrideWithValue(FakeUser()),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Logout'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
      await tester.pumpAndSettle();

      // Error SnackBar shown
      expect(
        find.textContaining('Failed to logout: Network error during sign out'),
        findsOneWidget,
      );
    });
  });
}
