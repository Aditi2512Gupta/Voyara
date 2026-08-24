import '../../../trips/data/models/trip_status.dart';

class BookingModel {
  final String id;
  final String destinationId;
  final String destinationName;
  final String destinationLocation;
  final String destinationImageUrl;
  final double destinationLatitude;
  final double destinationLongitude;
  final String userId;
  final DateTime travelDate;
  final int travelers;
  final TripStatus status;
  final DateTime bookingDate;

  const BookingModel({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.destinationLocation,
    required this.destinationImageUrl,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.userId,
    required this.travelDate,
    required this.travelers,
    required this.status,
    required this.bookingDate,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      destinationId: map['destinationId'] ?? '',
      destinationName: map['destinationName'] ?? '',
      destinationLocation: map['destinationLocation'] ?? '',
      destinationImageUrl: map['destinationImageUrl'] ?? '',
      destinationLatitude:
          (map['destinationLatitude'] as num?)?.toDouble() ?? 0,
      destinationLongitude:
          (map['destinationLongitude'] as num?)?.toDouble() ?? 0,
      userId: map['userId'] ?? '',
      travelDate: DateTime.parse(map['travelDate']),
      travelers: (map['travelers'] as num?)?.toInt() ?? 1,
      status: TripStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TripStatus.upcoming,
      ),

      bookingDate: DateTime.parse(map['bookingDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'destinationName': destinationName,
      'destinationLocation': destinationLocation,
      'destinationImageUrl': destinationImageUrl,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'userId': userId,
      'travelDate': travelDate.toIso8601String(),
      'travelers': travelers,
      'status': status.name,
      'bookingDate': bookingDate.toIso8601String(),
    };
  }

  bool get canCancel => status == TripStatus.upcoming;
}
