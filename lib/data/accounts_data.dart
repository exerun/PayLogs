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
    try {
      print('Adding account: $name with balance: $balance');
      final id = await _dbHelper.insertAccount({'name': name, 'balance': balance});
      print('Account inserted with ID: $id');
      _accounts.add(Account(id: id, name: name, balance: balance));
      print('Account added to memory. Total accounts: ${_accounts.length}');
      notifyListeners();
    } catch (e) {
      print('Error adding account: $e');
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      if (account.id == null) {
        throw Exception('Cannot update account without ID');
      }
      
      await _dbHelper.updateAccount(account.toJson());
      final idx = _accounts.indexWhere((a) => a.id == account.id);
      if (idx != -1) {
        _accounts[idx] = account;
        notifyListeners();
      } else {
        throw Exception('Account not found in memory');
      }
    } catch (e) {
      print('Error updating account: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(int id) async {
    await _dbHelper.deleteAccount(id);
    _accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  List<String> get accountNames => _accounts.map((account) => account.name).toList();
} 