import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/destination_search_provider.dart';
import '../../../home/data/models/geoapify_place_model.dart';
import '../../providers/trip_planner_provider.dart';
import '../../data/models/trip_plan_request.dart';
import '../../providers/travel_interest_provider.dart';
import '../../data/models/saved_trip_model.dart';
import '../../providers/saved_trip_provider.dart';

class TripPlannerPage extends ConsumerStatefulWidget {
  const TripPlannerPage({super.key});

  @override
  ConsumerState<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends ConsumerState<TripPlannerPage> {
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  String _searchQuery = "";
  GeoapifyPlaceModel? _selectedPlace;

  final Set<String> _selectedInterests = {};

  int _days = 3;
  int _travelers = 2;

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
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
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDay(BuildContext context, dynamic day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Day ${day.day}",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            if (day.date.toString().isNotEmpty) ...[
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

  Widget _buildBulletList(
    BuildContext context,
    String title,
    List<String> items,
    IconData icon,
  ) {
    if (items.isEmpty) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, title, icon),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Trip Planner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              context.push('/saved-trips');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _destinationController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _selectedPlace = null;
              });
            },
            decoration: const InputDecoration(
              labelText: "Destination",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),

          if (_searchQuery.isNotEmpty)
            Consumer(
              builder: (context, ref, child) {
                final places = ref.watch(
                  destinationSearchProvider(_searchQuery),
                );

                return places.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const SizedBox(),
                  data: (results) {
                    if (results.isEmpty) {
                      return const SizedBox();
                    }

                    return Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: results.length > 5 ? 5 : results.length,
                        itemBuilder: (context, index) {
                          final place = results[index];

                          return ListTile(
                            leading: const Icon(Icons.place),
                            title: Text(place.name),
                            subtitle: Text(place.country),
                            onTap: () {
                              _destinationController.text = place.name;

                              setState(() {
                                _selectedPlace = place;
                                _searchQuery = "";
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),

          const SizedBox(height: 20),

          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Budget",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.currency_rupee),
            ),
          ),

          const SizedBox(height: 24),

          DropdownButtonFormField<int>(
            value: _days,
            decoration: const InputDecoration(
              labelText: "Trip Duration",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            items: List.generate(
              30,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text("${index + 1} Day${index == 0 ? "" : "s"}"),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _days = value;
                });
              }
            },
          ),

          const SizedBox(height: 24),

          DropdownButtonFormField<int>(
            value: _travelers,
            decoration: const InputDecoration(
              labelText: "Travelers",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.group),
            ),
            items: List.generate(
              20,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text("${index + 1}"),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _travelers = value;
                });
              }
            },
          ),

          const SizedBox(height: 32),

          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: DateTime.now(),
              );

              if (picked != null) {
                setState(() {
                  _startDate = picked;
                });
              }
            },
            icon: const Icon(Icons.date_range),
            label: Text(
              _startDate == null
                  ? "Select Start Date"
                  : _formatDate(_startDate!),
            ),
          ),

          const SizedBox(height: 24),

          Consumer(
            builder: (context, ref, child) {
              final interestsAsync = ref.watch(travelInterestsProvider);

              return interestsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(error.toString()),
                data: (interests) {
                  final seen = <String>{};

                  final uniqueInterests = interests.where((interest) {
                    final key = interest.name.trim().toLowerCase();

                    return key.isNotEmpty && seen.add(key);
                  }).toList();

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: uniqueInterests.map((interest) {
                      final selected = _selectedInterests.contains(
                        interest.name,
                      );

                      return FilterChip(
                        label: Text(interest.name),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedInterests.add(interest.name);
                            } else {
                              _selectedInterests.remove(interest.name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          Consumer(
            builder: (context, ref, child) {
              final planAsync = ref.watch(tripPlanProvider);

              return FilledButton.icon(
                onPressed: planAsync.isLoading
                    ? null
                    : () async {
                        final destination = _destinationController.text.trim();

                        final budget =
                            double.tryParse(_budgetController.text.trim()) ?? 0;

                        if (destination.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Enter a destination"),
                            ),
                          );
                          return;
                        }

                        if (_selectedPlace == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please select a destination from the suggestions.",
                              ),
                            ),
                          );
                          return;
                        }

                        if (_startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a start date."),
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(tripPlanProvider.notifier)
                            .generatePlan(
                              TripPlanRequest(
                                destination: destination,
                                latitude: _selectedPlace!.latitude,
                                longitude: _selectedPlace!.longitude,
                                startDate: _startDate!,
                                days: _days,
                                budget: budget,
                                travelers: _travelers,
                                interests: _selectedInterests.toList(),
                              ),
                            );
                      },
                icon: planAsync.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  planAsync.isLoading
                      ? "Generating..."
                      : "Generate AI Trip Plan",
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          Consumer(
            builder: (context, ref, child) {
              final plan = ref.watch(tripPlanProvider);

              return plan.when(
                loading: () => const SizedBox(),

                error: (error, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(error.toString()),
                  ),
                ),

                data: (trip) {
                  if (trip == null) {
                    return const SizedBox();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(context, "Trip Overview", Icons.explore),

                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            trip.overview,
                            style: const TextStyle(height: 1.6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        context,
                        "Trip Details",
                        Icons.info_outline,
                      ),

                      const SizedBox(height: 12),

                      _infoCard(
                        title: "Destination",
                        content: trip.destination,
                        icon: Icons.location_on,
                      ),

                      _infoCard(
                        title: "Dates",
                        content:
                            "${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}",
                        icon: Icons.calendar_today,
                      ),

                      _infoCard(
                        title: "Travelers",
                        content: "${trip.travelers}",
                        icon: Icons.group,
                      ),

                      _infoCard(
                        title: "Planned Budget",
                        content: "₹${trip.budget.toStringAsFixed(0)}",
                        icon: Icons.currency_rupee,
                      ),

                      if (trip.interests.isNotEmpty)
                        _infoCard(
                          title: "Interests",
                          content: trip.interests.join(", "),
                          icon: Icons.favorite_outline,
                        ),

                      const SizedBox(height: 8),

                      _sectionTitle(
                        context,
                        "Budget Summary",
                        Icons.account_balance_wallet,
                      ),

                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            trip.budgetSummary,
                            style: const TextStyle(height: 1.6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle(
                        context,
                        "Daily Itinerary",
                        Icons.calendar_month,
                      ),

                      const SizedBox(height: 12),

                      if (trip.days.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No daily itinerary was generated."),
                          ),
                        )
                      else
                        ...trip.days.map((day) => _buildTripDay(context, day)),

                      _buildBulletList(
                        context,
                        "Packing Checklist",
                        trip.packingChecklist,
                        Icons.luggage,
                      ),

                      _buildBulletList(
                        context,
                        "Safety Tips",
                        trip.safetyTips,
                        Icons.health_and_safety,
                      ),

                      _buildBulletList(
                        context,
                        "Useful Local Tips",
                        trip.localTips,
                        Icons.tips_and_updates,
                      ),

                      const SizedBox(height: 12),

                      FilledButton.icon(
                        onPressed: () async {
                          if (_selectedPlace == null || _startDate == null) {
                            return;
                          }

                          final tripToSave = SavedTripModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            destination: trip.destination,
                            latitude: _selectedPlace!.latitude,
                            longitude: _selectedPlace!.longitude,
                            startDate: trip.startDate,
                            days: _days,
                            budget: trip.budget,
                            travelers: trip.travelers,
                            interests: trip.interests,

                            overview: trip.overview,
                            budgetSummary: trip.budgetSummary,

                            dailyItinerary: trip.days
                                .map(
                                  (day) => SavedTripDayModel(
                                    day: day.day,
                                    date: day.date,
                                    morning: day.morning,
                                    afternoon: day.afternoon,
                                    evening: day.evening,
                                    meals: day.meals,
                                    transport: day.transport,
                                    estimatedCost: day.estimatedCost,
                                    estimatedCostValue: day.estimatedCostValue,
                                  ),
                                )
                                .toList(),

                            packingChecklist: trip.packingChecklist,
                            safetyTips: trip.safetyTips,
                            localTips: trip.localTips,

                            createdAt: DateTime.now(),
                          );

                          await ref
                              .read(savedTripRepositoryProvider)
                              .saveTrip(tripToSave);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Trip saved successfully!"),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("Save Trip"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
