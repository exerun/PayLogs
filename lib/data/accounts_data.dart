import 'package:flutter/material.dart';
import 'db_helper.dart';

class Account {
  final int? id;
  final String name;
  final double balance;

  Account({this.id, required this.name, required this.balance});

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'],
    name: json['name'],
    balance: json['balance'].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'balance': balance,
  };

  Account copyWith({int? id, String? name, double? balance}) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
    );
  }
}

class AccountsData extends ChangeNotifier {
  final List<Account> _accounts = [];
  final DBHelper _dbHelper = DBHelper();

  List<Account> get accounts => List.unmodifiable(_accounts);

  AccountsData() {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accMaps = await _dbHelper.getAccounts();
    _accounts.clear();
    _accounts.addAll(accMaps.map((e) => Account.fromJson(e)));
    notifyListeners();
  }

  Future<void> addAccount(String name, double balance) async {
    final id = await _dbHelper.insertAccount({'name': name, 'balance': balance});
    _accounts.add(Account(id: id, name: name, balance: balance));
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    await _dbHelper.updateAccount(account.toJson());
    final idx = _accounts.indexWhere((a) => a.id == account.id);
    if (idx != -1) {
      _accounts[idx] = account;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(int id) async {
    await _dbHelper.deleteAccount(id);
    _accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  List<String> get accountNames => _accounts.map((account) => account.name).toList();
} 