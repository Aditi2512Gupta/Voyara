import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/models/geoapify_place_model.dart';
import '../../data/models/saved_trip_model.dart';
import '../../data/models/trip_plan_request.dart';
import '../../data/services/travel_interest_service.dart';
import '../../providers/destination_search_provider.dart';
import '../../providers/saved_trip_provider.dart';
import '../../providers/travel_interest_provider.dart';
import '../../providers/trip_planner_provider.dart';
import '../../../../core/utils/responsive.dart';

class EditTripPage extends ConsumerStatefulWidget {
  const EditTripPage({super.key, required this.trip});

  final SavedTripModel trip;

  @override
  ConsumerState<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends ConsumerState<EditTripPage> {
  late final TextEditingController _destinationController;
  late final TextEditingController _budgetController;

  late DateTime _startDate;
  late int _days;
  late int _travelers;
  late Set<String> _selectedInterests;

  String _searchQuery = "";
  GeoapifyPlaceModel? _selectedPlace;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(
      text: widget.trip.destination,
    );
    _budgetController = TextEditingController(
      text: widget.trip.budget.toStringAsFixed(0),
    );
    _startDate = widget.trip.startDate;
    _days = widget.trip.days.clamp(1, 30);
    _travelers = widget.trip.travelers.clamp(1, 20);
    _selectedInterests = Set<String>.from(widget.trip.interests);
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _handleSave() async {
    final destination = _destinationController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0;

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a destination.")),
      );
      return;
    }

    if (budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid budget.")),
      );
      return;
    }

    final isDestinationChanged =
        destination.toLowerCase() !=
        widget.trip.destination.trim().toLowerCase();
    if (isDestinationChanged && _selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select destination from the suggestions."),
        ),
      );
      return;
    }

    final initialDate = widget.trip.startDate;
    final isDateChanged =
        _startDate.year != initialDate.year ||
        _startDate.month != initialDate.month ||
        _startDate.day != initialDate.day;

    final originalInterestsSet = widget.trip.interests
        .map((e) => e.trim().toLowerCase())
        .toSet();
    final currentInterestsSet = _selectedInterests
        .map((e) => e.trim().toLowerCase())
        .toSet();
    final isInterestsChanged =
        originalInterestsSet.length != currentInterestsSet.length ||
        !originalInterestsSet.containsAll(currentInterestsSet);

    final isPlanningChanged =
        isDestinationChanged ||
        _days != widget.trip.days ||
        (budget - widget.trip.budget).abs() > 0.01 ||
        _travelers != widget.trip.travelers ||
        isDateChanged ||
        isInterestsChanged;

    setState(() {
      _isSaving = true;
    });

    try {
      final double latitude = _selectedPlace?.latitude ?? widget.trip.latitude;
      final double longitude =
          _selectedPlace?.longitude ?? widget.trip.longitude;

      SavedTripModel updatedTrip;

      if (isPlanningChanged) {
        final request = TripPlanRequest(
          destination: destination,
          latitude: latitude,
          longitude: longitude,
          startDate: _startDate,
          days: _days,
          budget: budget,
          travelers: _travelers,
          interests: _selectedInterests.toList(),
        );

        final plan = await ref
            .read(tripPlannerRepositoryProvider)
            .generatePlan(request);

        final updatedDailyItinerary = plan.days.map((day) {
          final dayDate = _startDate.add(Duration(days: day.day - 1));
          final fallbackDate =
              "${dayDate.day}/${dayDate.month}/${dayDate.year}";
          return SavedTripDayModel(
            day: day.day,
            date: day.date.isNotEmpty ? day.date : fallbackDate,
            morning: day.morning,
            afternoon: day.afternoon,
            evening: day.evening,
            meals: day.meals,
            transport: day.transport,
            estimatedCost: day.estimatedCost,
            estimatedCostValue: day.estimatedCostValue,
          );
        }).toList();

        updatedTrip = widget.trip.copyWith(
          destination: destination,
          latitude: latitude,
          longitude: longitude,
          startDate: _startDate,
          days: _days,
          budget: budget,
          travelers: _travelers,
          interests: _selectedInterests.toList(),
          overview: plan.overview.isNotEmpty
              ? plan.overview
              : widget.trip.overview,
          budgetSummary: plan.budgetSummary.isNotEmpty
              ? plan.budgetSummary
              : widget.trip.budgetSummary,
          dailyItinerary: updatedDailyItinerary,
          packingChecklist: plan.packingChecklist.isNotEmpty
              ? plan.packingChecklist
              : widget.trip.packingChecklist,
          safetyTips: plan.safetyTips.isNotEmpty
              ? plan.safetyTips
              : widget.trip.safetyTips,
          localTips: plan.localTips.isNotEmpty
              ? plan.localTips
              : widget.trip.localTips,
        );
      } else {
        updatedTrip = widget.trip.copyWith(
          destination: destination,
          latitude: latitude,
          longitude: longitude,
          startDate: _startDate,
          days: _days,
          budget: budget,
          travelers: _travelers,
          interests: _selectedInterests.toList(),
        );
      }

      await ref.read(savedTripRepositoryProvider).updateTrip(updatedTrip);

      try {
        for (final interest in _selectedInterests) {
          ref
              .read(travelInterestRepositoryProvider)
              .saveInterest(interest)
              .catchError((_) {});
        }
      } catch (_) {}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPlanningChanged
                ? "Trip plan regenerated and updated successfully!"
                : "Trip updated successfully!",
          ),
        ),
      );

      Navigator.pop(context, updatedTrip);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update trip: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Trip")),
        body: ResponsiveContentWrapper(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_isSaving) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "Regenerating trip plan with AI...",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
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
                      error: (error, _) => const SizedBox(),
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
                initialValue: _days,
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
                initialValue: _travelers,
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
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    initialDate: _startDate,
                  );

                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
                icon: const Icon(Icons.date_range),
                label: Text("Start Date: ${_formatDate(_startDate)}"),
              ),

              const SizedBox(height: 24),

              Text(
                "Interests",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Consumer(
                builder: (context, ref, child) {
                  final interestsAsync = ref.watch(travelInterestsProvider);

                  return interestsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) {
                      final uniqueInterests = List<String>.from(
                        _selectedInterests,
                      );
                      for (final defaultName
                          in TravelInterestService.defaultInterests) {
                        if (!uniqueInterests.any(
                          (n) => n.toLowerCase() == defaultName.toLowerCase(),
                        )) {
                          uniqueInterests.add(defaultName);
                        }
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: uniqueInterests.map((interestName) {
                          final selected = _selectedInterests.contains(
                            interestName,
                          );

                          return FilterChip(
                            label: Text(interestName),
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _selectedInterests.add(interestName);
                                } else {
                                  _selectedInterests.remove(interestName);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                    data: (interests) {
                      final seen = <String>{};

                      final uniqueInterests = interests
                          .where((interest) {
                            final key = interest.name.trim().toLowerCase();
                            return key.isNotEmpty && seen.add(key);
                          })
                          .map((i) => i.name)
                          .toList();

                      // Ensure all currently selected interests from the trip are available
                      for (final item in _selectedInterests) {
                        if (!uniqueInterests.any(
                          (n) => n.toLowerCase() == item.toLowerCase(),
                        )) {
                          uniqueInterests.add(item);
                        }
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: uniqueInterests.map((interestName) {
                          final selected = _selectedInterests.contains(
                            interestName,
                          );

                          return FilterChip(
                            label: Text(interestName),
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _selectedInterests.add(interestName);
                                } else {
                                  _selectedInterests.remove(interestName);
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

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _isSaving ? "Regenerating & Saving..." : "Save Changes",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
