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
      builder: (context, state) => const MainNavigationPage(),
    ),

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

    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),

    GoRoute(path: '/search', builder: (_, __) => const SearchResultsPage()),

    GoRoute(
      path: '/trip-planner',
      builder: (context, state) => const TripPlannerPage(),
    ),

    GoRoute(
      path: '/saved-trips',
      builder: (context, state) => const SavedTripsPage(),
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
