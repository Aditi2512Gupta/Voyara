import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/startup/presentation/pages/splash_page.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../features/home/presentation/pages/destination_details_page.dart';
import '../../features/home/presentation/pages/popular_destinations_page.dart';
import '../../features/bookings/presentation/pages/booking_success_page.dart';
import '../../features/bookings/presentation/pages/booking_page.dart';
import '../../features/home/data/models/destination_model.dart';
import '../../features/bookings/data/models/booking_model.dart';
import '../../features/bookings/presentation/pages/booking_details_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/home/presentation/pages/search_results_page.dart';
import '../../features/trip_planner/presentation/pages/saved_trips_page.dart';
import '../../features/trip_planner/presentation/pages/saved_trip_details_page.dart';
import '../../features/trip_planner/data/models/saved_trip_model.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/trip_planner/presentation/pages/trip_planner_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    // GoRoute(
    //   path: '/onboarding',
    //   builder: (context, state) => const OnboardingPage(),
    // ),
    GoRoute(
      path: '/home',
      redirect: (context, state) {
        final tabParam = state.uri.queryParameters['tab'];
        if (tabParam == 'ai' || tabParam == 'planner') {
          return '/trip-planner';
        }
        return null;
      },
      builder: (context, state) {
        int initialIndex = 0;
        final tabParam = state.uri.queryParameters['tab'];
        if (tabParam != null) {
          if (tabParam == 'trips' || tabParam == '1') {
            initialIndex = 1;
          } else if (tabParam == 'favorites' || tabParam == '2') {
            initialIndex = 2;
          } else if (tabParam == 'profile' ||
              tabParam == '3' ||
              tabParam == '4') {
            initialIndex = 3;
          } else {
            final parsed = int.tryParse(tabParam);
            if (parsed != null && parsed >= 0 && parsed < 4) {
              initialIndex = parsed;
            }
          }
        } else if (state.extra is int) {
          final extra = state.extra as int;
          if (extra == 4) {
            initialIndex = 3;
          } else if (extra >= 0 && extra < 4) {
            initialIndex = extra;
          }
        }

        return MainNavigationPage(initialIndex: initialIndex);
      },
    ),
    GoRoute(path: '/trips', redirect: (context, state) => '/home?tab=1'),
    GoRoute(path: '/favorites', redirect: (context, state) => '/home?tab=2'),

    GoRoute(
      path: '/destination',
      builder: (context, state) {
        final destination = state.extra as DestinationModel;

        return DestinationDetailsPage(destination: destination);
      },
    ),

    GoRoute(
      path: '/booking',
      builder: (context, state) {
        final destination = state.extra as DestinationModel;

        return BookingPage(destination: destination);
      },
    ),

    GoRoute(
      path: '/popular-destinations',
      builder: (context, state) => const PopularDestinationsPage(),
    ),

    // GoRoute(
    //   path: '/category',
    //   builder: (context, state) {
    //     final category = state.extra as String;

    //     return CategoryDestinationsPage(category: category);
    //   },
    // ),
    GoRoute(
      path: '/booking-success',
      builder: (context, state) => const BookingSuccessPage(),
    ),

    GoRoute(
      path: '/booking-details',
      builder: (context, state) {
        final booking = state.extra as BookingModel;

        return BookingDetailsPage(booking: booking);
      },
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),

    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),

    GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),

    GoRoute(path: '/search', builder: (_, _) => const SearchResultsPage()),

    GoRoute(
      path: '/trip-planner',
      builder: (context, state) => const TripPlannerPage(),
    ),

    GoRoute(
      path: '/saved-trips',
      builder: (context, state) {
        final title = state.uri.queryParameters['title'] ?? 'My Trips';
        return SavedTripsPage(title: title);
      },
    ),

    GoRoute(
      path: '/my-trips',
      builder: (context, state) => const SavedTripsPage(title: 'My Trips'),
    ),

    GoRoute(
      path: '/saved-trip-details',
      builder: (context, state) {
        return SavedTripDetailsPage(trip: state.extra as SavedTripModel);
      },
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
  ],
);
