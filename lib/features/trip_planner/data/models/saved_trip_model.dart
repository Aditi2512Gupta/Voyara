class SavedTripDayModel {
  const SavedTripDayModel({
    required this.day,
    required this.date,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.meals,
    required this.transport,
    required this.estimatedCost,
    required this.estimatedCostValue,
  });

  final int day;
  final String date;
  final String morning;
  final String afternoon;
  final String evening;
  final String meals;
  final String transport;

  final String estimatedCost;
  final double estimatedCostValue;

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'date': date,
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'meals': meals,
      'transport': transport,
      'estimatedCost': estimatedCost,
      'estimatedCostValue': estimatedCostValue,
    };
  }

  factory SavedTripDayModel.fromMap(Map<String, dynamic> map) {
    return SavedTripDayModel(
      day: (map['day'] as num?)?.toInt() ?? 1,
      date: map['date']?.toString() ?? '',
      morning: map['morning']?.toString() ?? '',
      afternoon: map['afternoon']?.toString() ?? '',
      evening: map['evening']?.toString() ?? '',
      meals: map['meals']?.toString() ?? '',
      transport: map['transport']?.toString() ?? '',
      estimatedCost: map['estimatedCost']?.toString() ?? '',
      estimatedCostValue: (map['estimatedCostValue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SavedTripModel {
  const SavedTripModel({
    required this.id,
    required this.destination,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.days,
    required this.budget,
    required this.travelers,
    required this.interests,
    required this.overview,
    required this.budgetSummary,
    required this.dailyItinerary,
    required this.packingChecklist,
    required this.safetyTips,
    required this.localTips,
    required this.createdAt,
  });

  final String id;
  final String destination;
  final double latitude;
  final double longitude;

  final DateTime startDate;
  final int days;

  // Trip planning information
  final double budget;
  final int travelers;
  final List<String> interests;

  // AI-generated information
  final String overview;
  final String budgetSummary;
  final List<SavedTripDayModel> dailyItinerary;
  final List<String> packingChecklist;
  final List<String> safetyTips;
  final List<String> localTips;

  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'destination': destination,
      'latitude': latitude,
      'longitude': longitude,
      'startDate': startDate.toIso8601String(),
      'days': days,
      'budget': budget,
      'travelers': travelers,
      'interests': interests,
      'overview': overview,
      'budgetSummary': budgetSummary,
      'dailyItinerary': dailyItinerary.map((day) => day.toMap()).toList(),
      'packingChecklist': packingChecklist,
      'safetyTips': safetyTips,
      'localTips': localTips,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedTripModel.fromMap(Map<String, dynamic> map, String id) {
    final rawDays = map['dailyItinerary'] as List? ?? [];

    return SavedTripModel(
      id: id,
      destination: map['destination']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      startDate: DateTime.parse(
        map['startDate']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      days: (map['days'] as num?)?.toInt() ?? 1,
      budget: (map['budget'] as num?)?.toDouble() ?? 0,
      travelers: (map['travelers'] as num?)?.toInt() ?? 1,
      interests: List<String>.from(map['interests'] ?? []),
      overview: map['overview']?.toString() ?? '',
      budgetSummary: map['budgetSummary']?.toString() ?? '',
      dailyItinerary: rawDays
          .whereType<Map>()
          .map(
            (day) => SavedTripDayModel.fromMap(Map<String, dynamic>.from(day)),
          )
          .toList(),
      packingChecklist: List<String>.from(map['packingChecklist'] ?? []),
      safetyTips: List<String>.from(map['safetyTips'] ?? []),
      localTips: List<String>.from(map['localTips'] ?? []),
      createdAt: DateTime.parse(
        map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
