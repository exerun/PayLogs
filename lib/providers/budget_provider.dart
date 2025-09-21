import 'package:flutter/material.dart';
import '../data/db_helper.dart';

class BudgetProvider extends ChangeNotifier {
  final Map<String, double> _budgets = {};
  final DBHelper _dbHelper = DBHelper();

  Map<String, double> get budgets => Map.unmodifiable(_budgets);

  BudgetProvider() {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgetMaps = await _dbHelper.getBudgets();
    _budgets.clear();
    for (final b in budgetMaps) {
      _budgets[b['category']] = b['amount'].toDouble();
    }
    notifyListeners();
  }

  Future<void> setBudget(String category, double amount) async {
    _budgets[category] = amount;
    await _dbHelper.insertBudget({'category': category, 'amount': amount});
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    if (!_budgets.containsKey(category)) {
      _budgets[category] = 0.0;
      await _dbHelper.insertBudget({'category': category, 'amount': 0.0});
      notifyListeners();
    }
  }

  Future<void> removeCategory(String category) async {
    if (_budgets.containsKey(category)) {
      _budgets.remove(category);
      await _dbHelper.deleteBudget(category);
      notifyListeners();
    }
  }

  Future<void> updateBudget(String category, double amount) async {
    if (_budgets.containsKey(category)) {
      _budgets[category] = amount;
      await _dbHelper.insertBudget({'category': category, 'amount': amount});
      notifyListeners();
    }
  }

  double getBudget(String category) {
    return _budgets[category] ?? 0.0;
  }
} 