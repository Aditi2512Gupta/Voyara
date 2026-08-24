import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../expenses/presentation/pages/expense_page.dart';
import '../../data/models/saved_trip_model.dart';
import '../../providers/pdf_provider.dart';

class SavedTripDetailsPage extends ConsumerWidget {
  const SavedTripDetailsPage({super.key, required this.trip});

  final SavedTripModel trip;

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

  String _shareText() {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.destination),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(_shareText(), subject: trip.destination);
            },
          ),

          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await ref
                  .read(pdfServiceProvider)
                  .exportTrip(
                    destination: trip.destination,
                    itinerary: _shareText(),
                  );
            },
          ),
        ],
      ),

      body: ListView(
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

          Text("Budget Summary", style: Theme.of(context).textTheme.titleLarge),

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
    );
  }
}
