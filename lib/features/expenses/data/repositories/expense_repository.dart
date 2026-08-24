import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  const ExpenseRepository({required ExpenseService service})
    : _service = service;

  final ExpenseService _service;

  Future<void> addExpense(ExpenseModel expense) {
    return _service.addExpense(expense);
  }

  Future<void> updateExpense(ExpenseModel expense) {
    return _service.updateExpense(expense);
  }

  Stream<List<ExpenseModel>> getExpenses(String tripId) {
    return _service.getExpenses(tripId);
  }

  Future<void> deleteExpense(String id) {
    return _service.deleteExpense(id);
  }
}
