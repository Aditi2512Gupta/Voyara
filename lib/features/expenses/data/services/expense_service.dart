import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';

class ExpenseService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore.collection('users').doc(user.uid).collection('expenses');
  }

  Future<void> addExpense(ExpenseModel expense) {
    return _collection.doc(expense.id).set(expense.toMap());
  }

  Future<void> updateExpense(ExpenseModel expense) {
    return _collection.doc(expense.id).update(expense.toMap());
  }

  Stream<List<ExpenseModel>> getExpenses(String tripId) {
    return _collection
        .where('tripId', isEqualTo: tripId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> deleteExpense(String id) {
    return _collection.doc(id).delete();
  }
}
