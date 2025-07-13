import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class BudgetProvider extends ChangeNotifier {
  static const String _boxName = 'budgetsBox';
  Map<String, double> _budgets = {
    'Food': 0.0,
    'Transport': 0.0,
    'Electronics': 0.0,
    'Rent': 0.0,
    'Others': 0.0,
  };

  Map<String, double> get budgets => Map.unmodifiable(_budgets);

  BudgetProvider() {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final box = await Hive.openBox(_boxName);
    if (box.isNotEmpty) {
      _budgets = Map<String, double>.from(box.toMap());
    }
    notifyListeners();
  }

  Future<void> setBudget(String category, double amount) async {
    _budgets[category] = amount;
    final box = await Hive.openBox(_boxName);
    await box.put(category, amount);
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    if (!_budgets.containsKey(category)) {
      _budgets[category] = 0.0;
      final box = await Hive.openBox(_boxName);
      await box.put(category, 0.0);
      notifyListeners();
    }
  }

  Future<void> removeCategory(String category) async {
    if (_budgets.containsKey(category)) {
      _budgets.remove(category);
      final box = await Hive.openBox(_boxName);
      await box.delete(category);
      notifyListeners();
    }
  }

  double getBudget(String category) {
    return _budgets[category] ?? 0.0;
  }
} 