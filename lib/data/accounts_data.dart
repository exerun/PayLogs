import 'package:flutter/material.dart';

class Account {
  final String name;
  final double balance;

  Account({required this.name, required this.balance});
}

class AccountsData extends ChangeNotifier {
  final List<Account> _accounts = [
    Account(name: 'SBI Bank', balance: 5000.00),
    Account(name: 'HDFC Bank', balance: 12500.50),
    Account(name: 'Cash', balance: 2500.00),
    Account(name: 'PayPal', balance: 3200.75),
  ];

  List<Account> get accounts => List.unmodifiable(_accounts);

  void addAccount(String name, double balance) {
    _accounts.add(Account(name: name, balance: balance));
    notifyListeners();
  }

  List<String> get accountNames => _accounts.map((account) => account.name).toList();
} 