import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';
import '../models/wallet.dart';

class ExpenseManager with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  List<Expense> _expenses = [];
  Wallet? _wallet;

  List<Expense> get expenses => _expenses;
  Wallet? get wallet => _wallet;

  // ================= WALLET =================
  Future<void> initWallet(double totalIncome) async {
    await _db.collection('users').doc(_uid).set({
      'wallet': {'total': totalIncome, 'remaining': totalIncome}
    });
    await fetchWallet();
  }

  Future<void> fetchWallet() async {
    final doc = await _db.collection('users').doc(_uid).get();
    if (doc.exists && doc.data() != null && doc.data()!.containsKey('wallet')) {
      _wallet = Wallet.fromMap(doc.data()!['wallet']);
      notifyListeners();
    }
  }

  // ================= EXPENSES =================
  // Real-time listener for expenses
  void listenExpenses() {
    _db
        .collection('users')
        .doc(_uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      _expenses = snap.docs.map((doc) => Expense.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  Future<void> addExpense(Expense expense) async {
    if (_wallet == null || expense.amount > _wallet!.remaining) return;

    final expenseRef = _db
        .collection('users')
        .doc(_uid)
        .collection('expenses')
        .doc(); // Firestore generated ID

    final newRemaining = _wallet!.remaining - expense.amount;

    await _db.runTransaction((transaction) async {
      transaction.set(expenseRef, expense.toMap());
      transaction.update(_db.collection('users').doc(_uid), {
        'wallet.remaining': newRemaining,
      });
    });

    // Update local list instantly
    _expenses.insert(
      0,
      Expense(
        id: expenseRef.id,
        title: expense.title,
        amount: expense.amount,
        category: expense.category,
        date: expense.date,
      ),
    );

    _wallet = Wallet(total: _wallet!.total, remaining: newRemaining);

    notifyListeners();
  }

  Future<void> deleteExpense(String expenseId) async {
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index == -1) return;

    final expense = _expenses[index];

    await _db.runTransaction((transaction) async {
      final docRef = _db.collection('users').doc(_uid);
      final newRemaining = (_wallet?.remaining ?? 0) + expense.amount;
      transaction.delete(docRef.collection('expenses').doc(expenseId));
      transaction.update(docRef, {'wallet.remaining': newRemaining});
    });

    _expenses.removeAt(index);
    _wallet = Wallet(
      total: _wallet!.total,
      remaining: (_wallet!.remaining + expense.amount),
    );

    notifyListeners();
  }

  // ================= WARNING =================
  String getWarning() {
    if (_wallet == null) return '';
    final percent = (_wallet!.remaining / _wallet!.total) * 100;

    if (percent <= 0) return "❌ 0% Remaining! Budget exhausted!";
    if (percent <= 25) return "⚠️ Only 25% left!";
    if (percent <= 50) return "⚠️ 50% remaining!";
    if (percent <= 75) return "⚠️ 75% remaining!";
    return "✅ Budget is healthy";
  }
}
