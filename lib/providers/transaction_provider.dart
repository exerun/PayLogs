import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../data/db_helper.dart';
import '../data/accounts_data.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final DBHelper _dbHelper = DBHelper();

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  TransactionProvider();

  Future<void> load(BuildContext context) async {
    await _loadTransactions();
    _accountsData = Provider.of<AccountsData>(context, listen: false);
  }

  AccountsData? _accountsData;

  Future<void> _loadTransactions() async {
    final txnMaps = await _dbHelper.getTransactions();
    _transactions.clear();
    _transactions.addAll(txnMaps.map((e) => Transaction.fromJson(e)));
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction, BuildContext context) async {
    await _dbHelper.insertTransaction(transaction.toJson());
    _transactions.add(transaction);
    _updateAccountBalancesOnAdd(transaction, context);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction newTxn, BuildContext context) async {
    final idx = _transactions.indexWhere((t) => t.id == newTxn.id);
    if (idx != -1) {
      final oldTxn = _transactions[idx];
      await _dbHelper.updateTransaction(newTxn.toJson());
      _transactions[idx] = newTxn;
      _updateAccountBalancesOnUpdate(oldTxn, newTxn, context);
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id, BuildContext context) async {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final txn = _transactions[idx];
      await _dbHelper.deleteTransaction(id);
      _transactions.removeAt(idx);
      _updateAccountBalancesOnDelete(txn, context);
      notifyListeners();
    }
  }

  void _updateAccountBalancesOnAdd(Transaction txn, BuildContext context) {
    final accountsData = Provider.of<AccountsData>(context, listen: false);
    if (txn.type == TransactionType.expense && txn.accountId != null) {
      final Account? acc = accountsData.accounts.firstWhere((a) => a.id == txn.accountId, orElse: () => null);
      if (acc != null) {
        accountsData.updateAccount(acc.copyWith(balance: acc.balance - txn.amount));
      }
    } else if (txn.type == TransactionType.income && txn.accountId != null) {
      final Account? acc = accountsData.accounts.firstWhere((a) => a.id == txn.accountId, orElse: () => null);
      if (acc != null) {
        accountsData.updateAccount(acc.copyWith(balance: acc.balance + txn.amount));
      }
    } else if (txn.type == TransactionType.transfer && txn.fromAccountId != null && txn.toAccountId != null) {
      final Account? fromAcc = accountsData.accounts.firstWhere((a) => a.id == txn.fromAccountId, orElse: () => null);
      final Account? toAcc = accountsData.accounts.firstWhere((a) => a.id == txn.toAccountId, orElse: () => null);
      if (fromAcc != null && toAcc != null) {
        accountsData.updateAccount(fromAcc.copyWith(balance: fromAcc.balance - txn.amount));
        accountsData.updateAccount(toAcc.copyWith(balance: toAcc.balance + txn.amount));
      }
    }
  }

  void _updateAccountBalancesOnUpdate(Transaction oldTxn, Transaction newTxn, BuildContext context) {
    _updateAccountBalancesOnDelete(oldTxn, context);
    _updateAccountBalancesOnAdd(newTxn, context);
  }

  void _updateAccountBalancesOnDelete(Transaction txn, BuildContext context) {
    final accountsData = Provider.of<AccountsData>(context, listen: false);
    if (txn.type == TransactionType.expense && txn.accountId != null) {
      final Account? acc = accountsData.accounts.firstWhere((a) => a.id == txn.accountId, orElse: () => null);
      if (acc != null) {
        accountsData.updateAccount(acc.copyWith(balance: acc.balance + txn.amount));
      }
    } else if (txn.type == TransactionType.income && txn.accountId != null) {
      final Account? acc = accountsData.accounts.firstWhere((a) => a.id == txn.accountId, orElse: () => null);
      if (acc != null) {
        accountsData.updateAccount(acc.copyWith(balance: acc.balance - txn.amount));
      }
    } else if (txn.type == TransactionType.transfer && txn.fromAccountId != null && txn.toAccountId != null) {
      final Account? fromAcc = accountsData.accounts.firstWhere((a) => a.id == txn.fromAccountId, orElse: () => null);
      final Account? toAcc = accountsData.accounts.firstWhere((a) => a.id == txn.toAccountId, orElse: () => null);
      if (fromAcc != null && toAcc != null) {
        accountsData.updateAccount(fromAcc.copyWith(balance: fromAcc.balance + txn.amount));
        accountsData.updateAccount(toAcc.copyWith(balance: toAcc.balance - txn.amount));
      }
    }
  }

  Future<void> clearTransactions(BuildContext context) async {
    final txnList = List<Transaction>.from(_transactions);
    for (final txn in txnList) {
      await deleteTransaction(txn.id, context);
    }
    _transactions.clear();
    notifyListeners();
  }
} 