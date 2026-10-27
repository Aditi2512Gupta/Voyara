import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
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
  final _budgetController = TextEditingController(text: "25000");

  DateTime? _startDate;
  String _searchQuery = "";
  GeoapifyPlaceModel? _selectedPlace;

  final Set<String> _selectedInterests = {'Relaxed', 'Adventure'};

  int _days = 4;
  int _travelers = 2;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 14));
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }


  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String description,
    required bool isLast,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.secondary : AppColors.primary,
                ),
              ),
            ),
          ),

          // Timeline connector
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.secondary : AppColors.primary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDay(BuildContext context, dynamic day) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Day ${day.day}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (day.estimatedCost != null && day.estimatedCost.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${day.estimatedCost}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            time: "9:00 AM",
            title: "Morning Activity",
            description: day.morning,
            isLast: false,
          ),
          _buildTimelineItem(
            time: "1:00 PM",
            title: "Afternoon Plan",
            description: day.afternoon,
            isLast: false,
          ),
          _buildTimelineItem(
            time: "6:00 PM",
            title: "Evening & Leisure",
            description: day.evening,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletList(
    BuildContext context,
    String title,
    List<String> items,
    IconData icon,
  ) {
    if (items.isEmpty) return const SizedBox();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: isDark ? AppColors.secondary : AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AI Trip Planner",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              "Let AI create your perfect itinerary",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: "Saved Trips",
            onPressed: () {
              context.push('/saved-trips');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Where do you want to go? Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 20,
                      color: isDark ? AppColors.secondary : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Where do you want to go?",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _destinationController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _selectedPlace = null;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "e.g. Manali, Goa, Rajasthan...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
                          if (results.isEmpty) return const SizedBox();

                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.inputLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: results.length > 4 ? 4 : results.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final place = results[index];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.location_on, size: 18),
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Travel Dates & Duration Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: isDark ? AppColors.secondary : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Travel Dates & Duration",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Date button
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            initialDate: _startDate ?? DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.inputDark : AppColors.inputLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _startDate == null ? "Select date" : _formatDate(_startDate!),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Days counter stepper
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.inputDark : AppColors.inputLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: _days > 1 ? () => setState(() => _days--) : null,
                          ),
                          Text(
                            "$_days ${_days == 1 ? 'Day' : 'Days'}",
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: _days < 30 ? () => setState(() => _days++) : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Travelers Stepper Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 20,
                      color: isDark ? AppColors.secondary : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Number of Travelers",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.inputDark : AppColors.inputLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: _travelers > 1 ? () => setState(() => _travelers--) : null,
                      ),
                      Text(
                        "$_travelers",
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: _travelers < 20 ? () => setState(() => _travelers++) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Budget & Travel Style Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      size: 20,
                      color: isDark ? AppColors.secondary : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Travel Style & Budget",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Estimated Budget",
                    prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
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
                            final selected = _selectedInterests.contains(interest.name);
                            return FilterChip(
                              label: Text(interest.name),
                              selected: selected,
                              selectedColor: isDark ? AppColors.secondary : AppColors.primary,
                              labelStyle: TextStyle(
                                color: selected
                                    ? (isDark ? AppColors.primaryDark : Colors.white)
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              ),
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. Generate Itinerary Button
          Consumer(
            builder: (context, ref, child) {
              final planAsync = ref.watch(tripPlanProvider);

              return SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: planAsync.isLoading
                      ? null
                      : () async {
                          final destination = _destinationController.text.trim();
                          final budget = double.tryParse(_budgetController.text.trim()) ?? 0;

                          if (destination.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Enter a destination")),
                            );
                            return;
                          }

                          if (_selectedPlace == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a destination from suggestions."),
                              ),
                            );
                            return;
                          }

                          if (_startDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select a start date.")),
                            );
                            return;
                          }

                          await ref.read(tripPlanProvider.notifier).generatePlan(
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
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
                    foregroundColor: isDark ? AppColors.primaryDark : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  icon: planAsync.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    planAsync.isLoading ? "Generating Itinerary..." : "Generate Itinerary ✨",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // 6. Generated Plan View
          Consumer(
            builder: (context, ref, child) {
              final plan = ref.watch(tripPlanProvider);

              return plan.when(
                loading: () => const SizedBox(),
                error: (error, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    error.toString(),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
                data: (trip) {
                  if (trip == null) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Generated Header Banner
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.cardDark, const Color(0xFF1B3835)]
                                : [AppColors.secondaryLight, Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: AppColors.tertiary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Your Custom Itinerary",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${trip.days.length} Days • ${trip.destination} • ${trip.travelers} Travelers",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.secondary : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              trip.overview,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Day Selector Pills
                      if (trip.days.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(trip.days.length, (idx) {
                              final isSelected = _selectedDayIndex == idx;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text("Day ${idx + 1}"),
                                  selected: isSelected,
                                  selectedColor: isDark ? AppColors.secondary : AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? (isDark ? AppColors.primaryDark : Colors.white)
                                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                  onSelected: (_) {
                                    setState(() => _selectedDayIndex = idx);
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTripDay(
                          context,
                          trip.days[_selectedDayIndex.clamp(0, trip.days.length - 1)],
                        ),
                      ],

                      _buildBulletList(
                        context,
                        "Packing Checklist",
                        trip.packingChecklist,
                        Icons.luggage_outlined,
                      ),

                      _buildBulletList(
                        context,
                        "Safety Tips",
                        trip.safetyTips,
                        Icons.health_and_safety_outlined,
                      ),

                      _buildBulletList(
                        context,
                        "Local Insights",
                        trip.localTips,
                        Icons.tips_and_updates_outlined,
                      ),

                      const SizedBox(height: 12),

                      // Save Trip Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () async {
                            if (_selectedPlace == null || _startDate == null) return;

                            final tripToSave = SavedTripModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
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
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
                            foregroundColor: isDark ? AppColors.primaryDark : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          icon: const Icon(Icons.bookmark_added),
                          label: const Text(
                            "Save Itinerary to Trips",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
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
