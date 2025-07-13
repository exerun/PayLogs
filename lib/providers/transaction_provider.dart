import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  static const String _boxName = 'transactionsBox';
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final box = await Hive.openBox<Transaction>(_boxName);
    _transactions = box.values.toList();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final box = await Hive.openBox<Transaction>(_boxName);
    await box.add(transaction);
    _transactions.add(transaction);
    notifyListeners();
  }

  Future<void> clearTransactions() async {
    final box = await Hive.openBox<Transaction>(_boxName);
    await box.clear();
    _transactions.clear();
    notifyListeners();
  }

  double getCategoryExpense(String category) {
    return _transactions
        .where((t) => t.type == TransactionType.expense && t.category == category)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<Transaction?> deleteTransactionById(String id) async {
    final box = await Hive.openBox<Transaction>(_boxName);
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return null;
    final tx = _transactions.removeAt(idx);
    // Remove from Hive by key
    final key = box.keys.firstWhere((k) => box.get(k)?.id == id, orElse: () => null);
    if (key != null) await box.delete(key);
    notifyListeners();
    return tx;
  }

  Future<void> insertTransactionAt(Transaction transaction, int index) async {
    final box = await Hive.openBox<Transaction>(_boxName);
    _transactions.insert(index, transaction);
    await box.add(transaction);
    notifyListeners();
  }
} 