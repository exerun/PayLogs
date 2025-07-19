enum TransactionType {
  income,
  expense,
  transfer,
}

class Transaction {
  final String id;
  final double amount;
  final String? notes;
  final String? category;
  final int? accountId;
  final int? fromAccountId;
  final int? toAccountId;
  final String? account; // for display only
  final String? fromAccount; // for display only
  final String? toAccount; // for display only
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.amount,
    this.notes,
    this.category,
    this.accountId,
    this.fromAccountId,
    this.toAccountId,
    this.account,
    this.fromAccount,
    this.toAccount,
    required this.date,
    required this.type,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? notes,
    String? category,
    int? accountId,
    int? fromAccountId,
    int? toAccountId,
    String? account,
    String? fromAccount,
    String? toAccount,
    DateTime? date,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      account: account ?? this.account,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'notes': notes,
      'category': category,
      'accountId': accountId,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'account': account,
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'date': date.toIso8601String(),
      'type': type.name,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      notes: json['notes'],
      category: json['category'],
      accountId: json['accountId'],
      fromAccountId: json['fromAccountId'],
      toAccountId: json['toAccountId'],
      account: json['account'],
      fromAccount: json['fromAccount'],
      toAccount: json['toAccount'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
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