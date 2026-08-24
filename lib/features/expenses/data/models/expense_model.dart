class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.tripId,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  final String id;
  final String tripId;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String notes;

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      tripId: map['tripId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.parse(
        map['date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      notes: map['notes']?.toString() ?? '',
    );
  }
}
