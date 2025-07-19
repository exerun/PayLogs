import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'paylogs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        notes TEXT,
        category TEXT,
        accountId INTEGER,
        fromAccountId INTEGER,
        toAccountId INTEGER,
        account TEXT,
        fromAccount TEXT,
        toAccount TEXT,
        date TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets (
        category TEXT PRIMARY KEY,
        amount REAL NOT NULL
      )
    ''');
  }

  // --- Accounts ---
  Future<int> insertAccount(Map<String, dynamic> account) async {
    final dbClient = await db;
    return await dbClient.insert('accounts', account);
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final dbClient = await db;
    return await dbClient.query('accounts');
  }

  Future<int> updateAccount(Map<String, dynamic> account) async {
    final dbClient = await db;
    return await dbClient.update('accounts', account, where: 'id = ?', whereArgs: [account['id']]);
  }

  Future<int> deleteAccount(int id) async {
    final dbClient = await db;
    return await dbClient.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // --- Transactions ---
  Future<int> insertTransaction(Map<String, dynamic> txn) async {
    final dbClient = await db;
    return await dbClient.insert('transactions', txn);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final dbClient = await db;
    return await dbClient.query('transactions', orderBy: 'date DESC');
  }

  Future<int> updateTransaction(Map<String, dynamic> txn) async {
    final dbClient = await db;
    return await dbClient.update('transactions', txn, where: 'id = ?', whereArgs: [txn['id']]);
  }

  Future<int> deleteTransaction(String id) async {
    final dbClient = await db;
    return await dbClient.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Budgets ---
  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final dbClient = await db;
    return await dbClient.insert('budgets', budget, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getBudgets() async {
    final dbClient = await db;
    return await dbClient.query('budgets');
  }

  Future<int> deleteBudget(String category) async {
    final dbClient = await db;
    return await dbClient.delete('budgets', where: 'category = ?', whereArgs: [category]);
  }
} 