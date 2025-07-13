import 'package:flutter/material.dart';

class BudgetProvider extends ChangeNotifier {
  final Map<String, double> _budgets = {
    'Food': 0.0,
    'Transport': 0.0,
    'Electronics': 0.0,
    'Rent': 0.0,
    'Others': 0.0,
  };

  Map<String, double> get budgets => Map.unmodifiable(_budgets);

  void setBudget(String category, double amount) {
    _budgets[category] = amount;
    notifyListeners();
  }

  void addCategory(String category) {
    if (!_budgets.containsKey(category)) {
      _budgets[category] = 0.0;
      notifyListeners();
    }
  }

  void removeCategory(String category) {
    if (_budgets.containsKey(category)) {
      _budgets.remove(category);
      notifyListeners();
    }
  }

  double getBudget(String category) {
    return _budgets[category] ?? 0.0;
  }
} 