import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';
import '../data/services/expense_service.dart';

final expenseServiceProvider = Provider<ExpenseService>(
  (ref) => ExpenseService(),
);

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepository(service: ref.read(expenseServiceProvider)),
);

final expensesProvider = StreamProvider.family<List<ExpenseModel>, String>((
  ref,
  tripId,
) {
  return ref.read(expenseRepositoryProvider).getExpenses(tripId);
});
