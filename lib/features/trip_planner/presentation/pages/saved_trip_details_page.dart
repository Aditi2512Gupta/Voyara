import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../expenses/presentation/pages/expense_page.dart';
import '../../data/models/saved_trip_model.dart';
import '../../providers/pdf_provider.dart';
import '../../providers/saved_trip_provider.dart';
import 'edit_trip_page.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../home/presentation/widgets/destination_map.dart';
import '../../providers/trip_weather_provider.dart';

class SavedTripDetailsPage extends ConsumerStatefulWidget {
  const SavedTripDetailsPage({super.key, required this.trip});

  final SavedTripModel trip;

  @override
  ConsumerState<SavedTripDetailsPage> createState() =>
      _SavedTripDetailsPageState();
}

class _SavedTripDetailsPageState extends ConsumerState<SavedTripDetailsPage> {
  late SavedTripModel _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _infoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(content, style: const TextStyle(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletSection({
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    if (items.isEmpty) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• "),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCard(BuildContext context, SavedTripDayModel day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Day ${day.day}",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            if (day.date.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(day.date, style: TextStyle(color: Colors.grey.shade600)),
            ],

            const Divider(height: 24),

            _infoCard(
              title: "Morning",
              content: day.morning,
              icon: Icons.wb_sunny_outlined,
            ),

            _infoCard(
              title: "Afternoon",
              content: day.afternoon,
              icon: Icons.wb_sunny,
            ),

            _infoCard(
              title: "Evening",
              content: day.evening,
              icon: Icons.nightlight_outlined,
            ),

            _infoCard(
              title: "Meals",
              content: day.meals,
              icon: Icons.restaurant,
            ),

            _infoCard(
              title: "Transport",
              content: day.transport,
              icon: Icons.directions_car,
            ),

            _infoCard(
              title: "Estimated Cost",
              content: day.estimatedCost,
              icon: Icons.currency_rupee,
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherSection(BuildContext context, SavedTripModel trip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherAsync = ref.watch(tripWeatherProvider(trip));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Trip Weather", style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: "Refresh weather",
              onPressed: () {
                ref.invalidate(tripWeatherProvider(trip));
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: weatherAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, size: 36, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        "Weather unavailable",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          ref.invalidate(tripWeatherProvider(trip));
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                if (!state.isAvailable) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 36,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message.isNotEmpty
                                ? state.message
                                : "Weather unavailable",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              ref.invalidate(tripWeatherProvider(trip));
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          state.mode == TripWeatherMode.forecast
                              ? Icons.wb_sunny_outlined
                              : Icons.thermostat_outlined,
                          size: 20,
                          color: state.mode == TripWeatherMode.forecast
                              ? (isDark
                                    ? AppColors.secondary
                                    : AppColors.primary)
                              : (isDark
                                    ? Colors.amber.shade300
                                    : Colors.amber.shade800),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (state.mode == TripWeatherMode.forecast &&
                        state.matchingForecasts.isNotEmpty) ...[
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.matchingForecasts.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final f = state.matchingForecasts[index];
                            const weekdays = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun',
                            ];
                            final dayLabel = weekdays[f.date.weekday - 1];
                            final dateLabel = "${f.date.day}/${f.date.month}";

                            return Container(
                              width: 85,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark.withValues(alpha: 0.8)
                                    : AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    dayLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dateLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (f.icon.isNotEmpty)
                                    Image.network(
                                      'https://openweathermap.org/img/wn/${f.icon}@2x.png',
                                      width: 34,
                                      height: 34,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.wb_sunny_outlined,
                                        size: 24,
                                      ),
                                    ),
                                  Text(
                                    "${f.maxTemp.toStringAsFixed(0)}° / ${f.minTemp.toStringAsFixed(0)}°",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    f.condition,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ] else if (state.currentWeather != null &&
                        state.currentWeather!.isAvailable) ...[
                      Row(
                        children: [
                          if (state.currentWeather!.icon != null)
                            Image.network(
                              'https://openweathermap.org/img/wn/${state.currentWeather!.icon}@2x.png',
                              width: 50,
                              height: 50,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.wb_sunny_outlined, size: 40),
                            ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${state.currentWeather!.temperature?.toStringAsFixed(1) ?? 'N/A'}°C",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (state.currentWeather!.condition != null)
                                Text(
                                  state.currentWeather!.condition!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _shareText(SavedTripModel trip) {
    final buffer = StringBuffer();

    buffer.writeln("✈️ ${trip.destination}");
    buffer.writeln();
    buffer.writeln("📅 ${_formatDate(trip.startDate)}");
    buffer.writeln("👥 Travelers: ${trip.travelers}");
    buffer.writeln("💰 Budget: ₹${trip.budget.toStringAsFixed(0)}");
    buffer.writeln();

    buffer.writeln("OVERVIEW");
    buffer.writeln(trip.overview);
    buffer.writeln();

    buffer.writeln("BUDGET SUMMARY");
    buffer.writeln(trip.budgetSummary);
    buffer.writeln();

    for (final day in trip.dailyItinerary) {
      buffer.writeln("DAY ${day.day}");
      buffer.writeln("Morning: ${day.morning}");
      buffer.writeln("Afternoon: ${day.afternoon}");
      buffer.writeln("Evening: ${day.evening}");
      buffer.writeln("Meals: ${day.meals}");
      buffer.writeln("Transport: ${day.transport}");
      buffer.writeln("Estimated Cost: ${day.estimatedCost}");
      buffer.writeln();
    }

    if (trip.packingChecklist.isNotEmpty) {
      buffer.writeln("PACKING CHECKLIST");
      for (final item in trip.packingChecklist) {
        buffer.writeln("• $item");
      }
      buffer.writeln();
    }

    if (trip.safetyTips.isNotEmpty) {
      buffer.writeln("SAFETY TIPS");
      for (final tip in trip.safetyTips) {
        buffer.writeln("• $tip");
      }
      buffer.writeln();
    }

    if (trip.localTips.isNotEmpty) {
      buffer.writeln("USEFUL LOCAL TIPS");
      for (final tip in trip.localTips) {
        buffer.writeln("• $tip");
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<SavedTripModel>>>(savedTripsProvider, (
      previous,
      next,
    ) {
      next.whenData((trips) {
        final match = trips.where((t) => t.id == _trip.id).firstOrNull;
        if (match != null && mounted) {
          setState(() {
            _trip = match;
          });
        }
      });
    });

    final trip = _trip;

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.destination),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Edit Trip",
            onPressed: () async {
              final updated = await Navigator.push<SavedTripModel>(
                context,
                MaterialPageRoute(builder: (_) => EditTripPage(trip: trip)),
              );

              if (updated != null && mounted) {
                setState(() {
                  _trip = updated;
                });
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(_shareText(trip), subject: trip.destination);
            },
          ),

          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await ref
                  .read(pdfServiceProvider)
                  .exportTrip(
                    destination: trip.destination,
                    itinerary: _shareText(trip),
                  );
            },
          ),
        ],
      ),

      body: ResponsiveContentWrapper(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              trip.destination,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text("Start Date"),
                      trailing: Text(_formatDate(trip.startDate)),
                    ),

                    ListTile(
                      leading: const Icon(Icons.timelapse),
                      title: const Text("Duration"),
                      trailing: Text(
                        "${trip.days} day${trip.days == 1 ? '' : 's'}",
                      ),
                    ),

                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text("Travelers"),
                      trailing: Text("${trip.travelers}"),
                    ),

                    ListTile(
                      leading: const Icon(Icons.currency_rupee),
                      title: const Text("Budget"),
                      trailing: Text("₹${trip.budget.toStringAsFixed(0)}"),
                    ),
                  ],
                ),
              ),
            ),

            if (trip.interests.isNotEmpty) ...[
              const SizedBox(height: 20),

              Text("Interests", style: Theme.of(context).textTheme.titleLarge),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trip.interests
                    .map((interest) => Chip(label: Text(interest)))
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            Text("Overview", style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  trip.overview,
                  style: const TextStyle(height: 1.6, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Budget Summary",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  trip.budgetSummary,
                  style: const TextStyle(height: 1.6, fontSize: 16),
                ),
              ),
            ),

            if (trip.latitude != 0 && trip.longitude != 0) ...[
              const SizedBox(height: 24),

              Text(
                "Location & Map",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              DestinationMap(
                latitude: trip.latitude,
                longitude: trip.longitude,
                destinationTitle: trip.destination,
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final currentPos = ref
                        .read(currentLocationProvider)
                        .valueOrNull;
                    MapLauncher.openDirections(
                      destinationLatitude: trip.latitude,
                      destinationLongitude: trip.longitude,
                      originLatitude: currentPos?.latitude,
                      originLongitude: currentPos?.longitude,
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Directions in Google Maps',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Turn-by-turn navigation • Live traffic',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExpensePage(
                      tripId: trip.id,
                      budget: trip.budget,
                      plannedCost: trip.dailyItinerary.fold<double>(
                        0,
                        (sum, day) => sum + day.estimatedCostValue,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text("Track Trip Expenses"),
            ),

            if (trip.latitude != 0 && trip.longitude != 0) ...[
              const SizedBox(height: 24),
              _weatherSection(context, trip),
            ],

            const SizedBox(height: 24),

            Text(
              "Daily Itinerary",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            if (trip.dailyItinerary.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No daily itinerary available."),
                ),
              )
            else
              ...trip.dailyItinerary.map((day) => _dayCard(context, day)),

            _bulletSection(
              title: "Packing Checklist",
              items: trip.packingChecklist,
              icon: Icons.luggage,
            ),

            _bulletSection(
              title: "Safety Tips",
              items: trip.safetyTips,
              icon: Icons.health_and_safety,
            ),

            _bulletSection(
              title: "Useful Local Tips",
              items: trip.localTips,
              icon: Icons.tips_and_updates,
            ),
          ],
        ),
      ),
    );
  }
}
