import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/trip_plan_model.dart';
import 'trip_planner_service.dart';

class GeminiTripPlannerService implements TripPlannerService {
  GeminiTripPlannerService()
    : _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-3.6-flash');

  final GenerativeModel _model;

  @override
  Future<TripPlanModel> generateTripPlan({
    required String destination,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required int days,
    required double budget,
    required int travelers,
    required List interests,
  }) async {
    final prompt =
        '''
You are Voyara AI, a professional travel assistant.

Create a personalized travel itinerary.

Trip Details:
Destination: $destination
Starting Date: ${startDate.toIso8601String().split('T').first}
Latitude: $latitude
Longitude: $longitude
Duration: $days days
Budget: ₹$budget
Travelers: $travelers
Interests: ${interests.isEmpty ? "No specific interests provided." : interests.join(", ")}

Instructions:
- Respect the user's budget.
- Create exactly $days days.
- Avoid repeating attractions.
- Recommend realistic timings.
- Include estimated travel time between places.
- Suggest local transport.
- Recommend authentic local food.
- Mention approximate entry/ticket fees when known.
- Mention the best time to visit attractions.
- Include safety tips.
- Include packing suggestions.
- Include useful local tips.
- Keep the estimated daily costs realistic.
- Consider the number of travelers when estimating costs.
- estimatedCost must be a human-readable INR amount.
- estimatedCostValue must be a numeric INR value only.
- Do not include ₹ or any currency symbol in estimatedCostValue.
- Do not return a range for estimatedCostValue.

IMPORTANT:
Return ONLY valid JSON.
Do not use Markdown.
Do not add ```json or ``` around the response.

Use exactly this structure:

{
  "overview": "Short overview of the trip",
  "budgetSummary": "Estimated overall budget breakdown",
  "days": [
    {
      "day": 1,
      "date": "YYYY-MM-DD",
      "morning": "Morning activities",
      "afternoon": "Afternoon activities",
      "evening": "Evening activities",
      "meals": "Food recommendations",
      "transport": "Transport suggestions",
      "estimatedCost": "Human-readable INR estimate",
      "estimatedCostValue": 0
    }
  ],
  "packingChecklist": [
    "item 1",
    "item 2"
  ],
  "safetyTips": [
    "tip 1",
    "tip 2"
  ],
  "localTips": [
    "tip 1",
    "tip 2"
  ]
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);

    final text = response.text?.trim();

    if (text == null || text.isEmpty) {
      throw Exception('Unable to generate itinerary.');
    }

    try {
      var cleanedText = text;

      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }

      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }

      cleanedText = cleanedText.trim();

      final Map<String, dynamic> json =
          jsonDecode(cleanedText) as Map<String, dynamic>;

      final rawDays = json['days'] as List? ?? [];

      final tripDays = rawDays
          .whereType<Map>()
          .map((day) => TripDayModel.fromMap(Map<String, dynamic>.from(day)))
          .toList();

      final packingChecklist = (json['packingChecklist'] as List? ?? [])
          .map((item) => item.toString())
          .toList();

      final safetyTips = (json['safetyTips'] as List? ?? [])
          .map((item) => item.toString())
          .toList();

      final localTips = (json['localTips'] as List? ?? [])
          .map((item) => item.toString())
          .toList();

      return TripPlanModel(
        destination: destination,
        startDate: startDate,
        endDate: startDate.add(Duration(days: days - 1)),
        travelers: travelers,
        budget: budget,
        interests: interests.map((e) => e.toString()).toList(),
        overview: json['overview']?.toString() ?? '',
        budgetSummary: json['budgetSummary']?.toString() ?? '',
        days: tripDays,
        packingChecklist: packingChecklist,
        safetyTips: safetyTips,
        localTips: localTips,
      );
    } catch (e) {
      throw Exception('AI returned an invalid itinerary format.');
    }
  }
}
