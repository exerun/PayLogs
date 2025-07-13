import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'accounts_data.g.dart';

@HiveType(typeId: 3)
class Account {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double balance;

  Account({required this.name, required this.balance});
}

class AccountsData extends ChangeNotifier {
  static const String _boxName = 'accountsBox';
  List<Account> _accounts = [];

  List<Account> get accounts => List.unmodifiable(_accounts);

  AccountsData() {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final box = await Hive.openBox<Account>(_boxName);
    _accounts = box.values.toList();
    notifyListeners();
  }

  Future<void> addAccount(String name, double balance) async {
    final box = await Hive.openBox<Account>(_boxName);
    final account = Account(name: name, balance: balance);
    await box.add(account);
    _accounts.add(account);
    notifyListeners();
  }

  List<String> get accountNames => _accounts.map((account) => account.name).toList();

  Future<void> editAccount(int index, String newName, double newBalance) async {
    final box = await Hive.openBox<Account>(_boxName);
    final newAccount = Account(name: newName, balance: newBalance);
    await box.putAt(index, newAccount);
    _accounts[index] = newAccount;
    notifyListeners();
  }

  Future<void> transfer(String fromAccountName, String toAccountName, double amount) async {
    final box = await Hive.openBox<Account>(_boxName);
    final fromIndex = _accounts.indexWhere((a) => a.name == fromAccountName);
    final toIndex = _accounts.indexWhere((a) => a.name == toAccountName);
    if (fromIndex == -1 || toIndex == -1) return;

    final fromAccount = _accounts[fromIndex];
    final toAccount = _accounts[toIndex];

    final updatedFrom = Account(name: fromAccount.name, balance: fromAccount.balance - amount);
    final updatedTo = Account(name: toAccount.name, balance: toAccount.balance + amount);

    await box.putAt(fromIndex, updatedFrom);
    await box.putAt(toIndex, updatedTo);

    _accounts[fromIndex] = updatedFrom;
    _accounts[toIndex] = updatedTo;
    notifyListeners();
  }

  Future<void> addIncome(String accountName, double amount) async {
    final box = await Hive.openBox<Account>(_boxName);
    final index = _accounts.indexWhere((a) => a.name == accountName);
    if (index == -1) return;
    final account = _accounts[index];
    final updated = Account(name: account.name, balance: account.balance + amount);
    await box.putAt(index, updated);
    _accounts[index] = updated;
    notifyListeners();
  }

  Future<void> addExpense(String accountName, double amount) async {
    final box = await Hive.openBox<Account>(_boxName);
    final index = _accounts.indexWhere((a) => a.name == accountName);
    if (index == -1) return;
    final account = _accounts[index];
    final updated = Account(name: account.name, balance: account.balance - amount);
    await box.putAt(index, updated);
    _accounts[index] = updated;
    notifyListeners();
  }
} 