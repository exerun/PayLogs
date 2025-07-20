import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../data/db_helper.dart';
import '../data/accounts_data.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final DBHelper _dbHelper = DBHelper();

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  TransactionProvider() {
    // Auto-load transactions when provider is created
    _loadTransactions();
  }

  Future<void> load(BuildContext context) async {
    await _loadTransactions();
    _accountsData = Provider.of<AccountsData>(context, listen: false);
  }

  AccountsData? _accountsData;

  Future<void> _loadTransactions() async {
    try {
      print('Loading transactions from database...');
      final txnMaps = await _dbHelper.getTransactions();
      print('Found ${txnMaps.length} transactions in database');
      _transactions.clear();
      _transactions.addAll(txnMaps.map((e) => Transaction.fromJson(e)));
      print('Loaded ${_transactions.length} transactions into memory');
      notifyListeners();
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction, BuildContext context) async {
    try {
      // First, try to update account balances in memory
      final balanceUpdateSuccess = await _updateAccountBalancesOnAdd(transaction, context);
      
      if (!balanceUpdateSuccess) {
        throw Exception('Failed to update account balances');
      }
      
      // If balance update succeeds, save transaction to database
      await _dbHelper.insertTransaction(transaction.toJson());
      _transactions.add(transaction);
      notifyListeners();
    } catch (e) {
      // If anything fails, revert the balance changes
      await _revertBalanceChanges(transaction, context);
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction newTxn, BuildContext context) async {
    try {
      final idx = _transactions.indexWhere((t) => t.id == newTxn.id);
      if (idx != -1) {
        final oldTxn = _transactions[idx];
        
        // First update the database
        await _dbHelper.updateTransaction(newTxn.toJson());
        
        // Then update account balances
        await _updateAccountBalancesOnUpdate(oldTxn, newTxn, context);
        
        // Finally update the in-memory transaction
        _transactions[idx] = newTxn;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id, BuildContext context) async {
    try {
      final idx = _transactions.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final txn = _transactions[idx];
        
        // First update account balances
        await _updateAccountBalancesOnDelete(txn, context);
        
        // Then delete from database
        await _dbHelper.deleteTransaction(id);
        
        // Finally remove from memory
        _transactions.removeAt(idx);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<bool> _updateAccountBalancesOnAdd(Transaction txn, BuildContext context) async {
    try {
      final accountsData = Provider.of<AccountsData>(context, listen: false);
      
      if (txn.type == TransactionType.expense && txn.accountId != null) {
        final accList = accountsData.accounts.where((a) => a.id == txn.accountId);
        final Account? acc = accList.isNotEmpty ? accList.first : null;
        if (acc != null) {
          await accountsData.updateAccount(acc.copyWith(balance: acc.balance - txn.amount));
          return true;
        }
        return false;
      } else if (txn.type == TransactionType.income && txn.accountId != null) {
        final accList2 = accountsData.accounts.where((a) => a.id == txn.accountId);
        final Account? acc2 = accList2.isNotEmpty ? accList2.first : null;
        if (acc2 != null) {
          await accountsData.updateAccount(acc2.copyWith(balance: acc2.balance + txn.amount));
          return true;
        }
        return false;
      } else if (txn.type == TransactionType.transfer && txn.fromAccountId != null && txn.toAccountId != null) {
        final fromAccList = accountsData.accounts.where((a) => a.id == txn.fromAccountId);
        final toAccList = accountsData.accounts.where((a) => a.id == txn.toAccountId);
        final Account? fromAcc = fromAccList.isNotEmpty ? fromAccList.first : null;
        final Account? toAcc = toAccList.isNotEmpty ? toAccList.first : null;
        if (fromAcc != null && toAcc != null) {
          await accountsData.updateAccount(fromAcc.copyWith(balance: fromAcc.balance - txn.amount));
          await accountsData.updateAccount(toAcc.copyWith(balance: toAcc.balance + txn.amount));
          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateAccountBalancesOnUpdate(Transaction oldTxn, Transaction newTxn, BuildContext context) async {
    await _updateAccountBalancesOnDelete(oldTxn, context);
    await _updateAccountBalancesOnAdd(newTxn, context);
  }

  Future<void> _updateAccountBalancesOnDelete(Transaction txn, BuildContext context) async {
    try {
      final accountsData = Provider.of<AccountsData>(context, listen: false);
      if (txn.type == TransactionType.expense && txn.accountId != null) {
        final accList3 = accountsData.accounts.where((a) => a.id == txn.accountId);
        final Account? acc3 = accList3.isNotEmpty ? accList3.first : null;
        if (acc3 != null) {
          await accountsData.updateAccount(acc3.copyWith(balance: acc3.balance + txn.amount));
        }
      } else if (txn.type == TransactionType.income && txn.accountId != null) {
        final accList4 = accountsData.accounts.where((a) => a.id == txn.accountId);
        final Account? acc4 = accList4.isNotEmpty ? accList4.first : null;
        if (acc4 != null) {
          await accountsData.updateAccount(acc4.copyWith(balance: acc4.balance - txn.amount));
        }
      } else if (txn.type == TransactionType.transfer && txn.fromAccountId != null && txn.toAccountId != null) {
        final fromAccList2 = accountsData.accounts.where((a) => a.id == txn.fromAccountId);
        final toAccList2 = accountsData.accounts.where((a) => a.id == txn.toAccountId);
        final Account? fromAcc2 = fromAccList2.isNotEmpty ? fromAccList2.first : null;
        final Account? toAcc2 = toAccList2.isNotEmpty ? toAccList2.first : null;
        if (fromAcc2 != null && toAcc2 != null) {
          await accountsData.updateAccount(fromAcc2.copyWith(balance: fromAcc2.balance + txn.amount));
          await accountsData.updateAccount(toAcc2.copyWith(balance: toAcc2.balance - txn.amount));
        }
      }
    } catch (e) {
      // Log error but don't throw to avoid breaking the delete operation
      print('Error updating account balances on delete: $e');
    }
  }

  Future<void> _revertBalanceChanges(Transaction txn, BuildContext context) async {
    try {
      final accountsData = Provider.of<AccountsData>(context, listen: false);
      if (txn.type == TransactionType.expense && txn.accountId != null) {
        final accList = accountsData.accounts.where((a) => a.id == txn.accountId);
        final Account? acc = accList.isNotEmpty ? accList.first : null;
        if (acc != null) {
          await accountsData.updateAccount(acc.copyWith(balance: acc.balance + txn.amount));
        }
      } else if (txn.type == TransactionType.income && txn.accountId != null) {
        final accList2 = accountsData.accounts.where((a) => a.id == txn.accountId);
        final Account? acc2 = accList2.isNotEmpty ? accList2.first : null;
        if (acc2 != null) {
          await accountsData.updateAccount(acc2.copyWith(balance: acc2.balance - txn.amount));
        }
      } else if (txn.type == TransactionType.transfer && txn.fromAccountId != null && txn.toAccountId != null) {
        final fromAccList = accountsData.accounts.where((a) => a.id == txn.fromAccountId);
        final toAccList = accountsData.accounts.where((a) => a.id == txn.toAccountId);
        final Account? fromAcc = fromAccList.isNotEmpty ? fromAccList.first : null;
        final Account? toAcc = toAccList.isNotEmpty ? toAccList.first : null;
        if (fromAcc != null && toAcc != null) {
          await accountsData.updateAccount(fromAcc.copyWith(balance: fromAcc.balance + txn.amount));
          await accountsData.updateAccount(toAcc.copyWith(balance: toAcc.balance - txn.amount));
        }
      }
    } catch (e) {
      print('Error reverting balance changes: $e');
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