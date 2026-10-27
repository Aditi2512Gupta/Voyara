import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voyara/core/services/notification_service.dart';
import 'package:voyara/features/trip_planner/data/models/saved_trip_model.dart';
import 'package:voyara/features/trip_planner/data/repositories/saved_trip_repository.dart';
import 'package:voyara/features/trip_planner/data/services/saved_trip_service.dart';

class FakeSavedTripService extends SavedTripService {
  final Map<String, SavedTripModel> trips = {};

  @override
  Future<void> saveTrip(SavedTripModel trip) async {
    trips[trip.id] = trip;
  }

  @override
  Future<void> updateTrip(SavedTripModel trip) async {
    trips[trip.id] = trip;
  }

  @override
  Future<void> deleteTrip(String id) async {
    trips.remove(id);
  }

  @override
  Stream<List<SavedTripModel>> getTrips() {
    return Stream.value(trips.values.toList());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('NotificationService defaults to enabled and can toggle ON/OFF', () async {
    final service = NotificationService.instance;

    await service.setNotificationsEnabled(true);
    expect(service.areNotificationsEnabled, isTrue);

    // Verify it persists in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('voyara_notifications_enabled'), isTrue);

    // Disable notifications
    await service.setNotificationsEnabled(false);
    expect(service.areNotificationsEnabled, isFalse);
    expect(prefs.getBool('voyara_notifications_enabled'), isFalse);

    // Restore to true
    await service.setNotificationsEnabled(true);
    expect(service.areNotificationsEnabled, isTrue);
  });

  test('NotificationService respects disabled state when showing or scheduling notifications', () async {
    final service = NotificationService.instance;

    // Turn OFF notifications
    await service.setNotificationsEnabled(false);

    // These should return early without errors when notifications are disabled
    await service.showBookingSuccess(destination: 'Paris');
    await service.showTripReminder(destination: 'Tokyo');
    await service.scheduleTripReminder(
      destination: 'Bali',
      travelDate: DateTime.now().add(const Duration(days: 5)),
    );
    await service.scheduleDailyNotification();

    expect(service.areNotificationsEnabled, isFalse);

    // Re-enable
    await service.setNotificationsEnabled(true);
    expect(service.areNotificationsEnabled, isTrue);
  });

  test('scheduleDailyNotification can be called repeatedly without errors or duplicate alarms', () async {
    final service = NotificationService.instance;
    await service.setNotificationsEnabled(true);

    // Calling multiple times (e.g. at app init, on login, on settings toggle)
    await service.scheduleDailyNotification(hour: 9, minute: 0);
    await service.scheduleDailyNotification(hour: 9, minute: 0);
    await service.scheduleDailyNotification(hour: 9, minute: 0);

    expect(service.areNotificationsEnabled, isTrue);
    await service.cancelDailyNotification();
  });

  test('scheduleTripReminder skips dates in the past safely', () async {
    final service = NotificationService.instance;
    await service.setNotificationsEnabled(true);

    // Date in the past
    final pastDate = DateTime.now().subtract(const Duration(days: 10));

    // Should complete cleanly without error
    await service.scheduleTripReminder(
      destination: 'Rome',
      travelDate: pastDate,
      tripId: 'test_trip_123',
    );

    await service.cancelTripReminder('test_trip_123');
    await service.cancelDailyNotification();
  });

  test('SavedTripRepository schedules reminder on save/update and cancels on delete', () async {
    final fakeService = FakeSavedTripService();
    final repo = SavedTripRepository(service: fakeService);

    final futureDate = DateTime.now().add(const Duration(days: 7));
    final trip = SavedTripModel(
      id: 'trip_swiss_1',
      destination: 'Switzerland',
      latitude: 46.8182,
      longitude: 8.2275,
      budget: 150000,
      days: 5,
      travelers: 2,
      startDate: futureDate,
      interests: ['Nature', 'Mountains'],
      overview: 'Swiss Alps tour',
      budgetSummary: '₹150,000 for 2',
      dailyItinerary: [],
      packingChecklist: [],
      safetyTips: [],
      localTips: [],
      createdAt: DateTime.now(),
    );

    // 1. Save trip should persist to service and schedule reminder
    await repo.saveTrip(trip);
    expect(fakeService.trips.containsKey('trip_swiss_1'), isTrue);

    // 2. Update trip should update service and replace scheduled reminder
    final updatedTrip = trip.copyWith(
      destination: 'Zurich & Lucerne',
      startDate: futureDate.add(const Duration(days: 2)),
    );
    await repo.updateTrip(updatedTrip);
    expect(fakeService.trips['trip_swiss_1']?.destination, 'Zurich & Lucerne');

    // 3. Delete trip should remove from service and cancel reminder
    await repo.deleteTrip('trip_swiss_1');
    expect(fakeService.trips.containsKey('trip_swiss_1'), isFalse);
  });
}
