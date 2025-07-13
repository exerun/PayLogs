import 'package:hive/hive.dart';
part 'transaction.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}

@HiveType(typeId: 2)
class Transaction {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final String? notes;
  @HiveField(3)
  final String? category;
  @HiveField(4)
  final String? account;
  @HiveField(5)
  final String? fromAccount;
  @HiveField(6)
  final String? toAccount;
  @HiveField(7)
  final DateTime date;
  @HiveField(8)
  final TransactionType type;
  @HiveField(9)
  final String? bankName;
  @HiveField(10)
  final String? extractedText;

  Transaction({
    required this.id,
    required this.amount,
    this.notes,
    this.category,
    this.account,
    this.fromAccount,
    this.toAccount,
    required this.date,
    required this.type,
    this.bankName,
    this.extractedText,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? notes,
    String? category,
    String? account,
    String? fromAccount,
    String? toAccount,
    DateTime? date,
    TransactionType? type,
    String? bankName,
    String? extractedText,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      account: account ?? this.account,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      date: date ?? this.date,
      type: type ?? this.type,
      bankName: bankName ?? this.bankName,
      extractedText: extractedText ?? this.extractedText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'notes': notes,
      'category': category,
      'account': account,
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'date': date.toIso8601String(),
      'type': type.name,
      'bankName': bankName,
      'extractedText': extractedText,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      notes: json['notes'],
      category: json['category'],
      account: json['account'],
      fromAccount: json['fromAccount'],
      toAccount: json['toAccount'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      bankName: json['bankName'],
      extractedText: json['extractedText'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, type: $type, date: $date)';
  }
} 