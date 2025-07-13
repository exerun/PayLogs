import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  static const Map<String, String> _categoryEmojis = {
    'Food': '🍕',
    'Transport': '🛵',
    'Electronics': '💻',
    'Rent': '🏠',
    'Utilities': '💡',
    'Shopping': '🛍️',
    'Entertainment': '🎬',
    'Healthcare': '🏥',
    'Education': '📚',
    'Travel': '✈️',
    'Others': '📦',
    'Unknown': '❓',
  };

  static const Map<String, Color> _categoryColors = {
    'Food': Color(0xFFFF6B6B),
    'Transport': Color(0xFF4ECDC4),
    'Electronics': Color(0xFF45B7D1),
    'Rent': Color(0xFF96CEB4),
    'Utilities': Color(0xFFFFEAA7),
    'Shopping': Color(0xFFDDA0DD),
    'Entertainment': Color(0xFFF8B500),
    'Healthcare': Color(0xFFFF8A80),
    'Education': Color(0xFF81C784),
    'Travel': Color(0xFF64B5F6),
    'Others': Color(0xFFA1887F),
    'Unknown': Color(0xFF9E9E9E),
  };

  Color _getAmountColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return const Color(0xFF4CAF50);
      case TransactionType.expense:
        return const Color(0xFFF44336);
      case TransactionType.transfer:
        return const Color(0xFFFF9800);
    }
  }

  String _getTypeString(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.transfer:
        return 'TRANSFER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _categoryColors[transaction.category] ?? _categoryColors['Unknown']!;
    
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.cardColor,
              theme.cardColor.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Category icon, type badge, and delete button
              Row(
                children: [
                  // Category icon with gradient background
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          categoryColor,
                          categoryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _categoryEmojis[transaction.category] ?? _categoryEmojis['Unknown']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Transaction type badge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getAmountColor(transaction.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getAmountColor(transaction.type).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getTypeString(transaction.type),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getAmountColor(transaction.type),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrainsMono',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  // Delete button
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Category name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withValues(alpha: 0.1),
                      categoryColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  transaction.category ?? 'Unknown',
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'JetBrainsMono',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Notes
              if (transaction.notes?.isNotEmpty == true)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    transaction.notes!,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontFamily: 'JetBrainsMono',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              if (transaction.notes?.isNotEmpty == true) const SizedBox(height: 12),
              
              // Amount section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getAmountColor(transaction.type).withValues(alpha: 0.1),
                      _getAmountColor(transaction.type).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getAmountColor(transaction.type).withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getAmountColor(transaction.type).withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '₹${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _getAmountColor(transaction.type),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'JetBrainsMono',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Account info
              if (transaction.account != null || transaction.fromAccount != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getAccountInfo(),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      fontFamily: 'JetBrainsMono',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAccountInfo() {
    if (transaction.type == TransactionType.transfer) {
      if (transaction.fromAccount != null && transaction.toAccount != null) {
        return '${transaction.fromAccount} → ${transaction.toAccount}';
      } else {
        return 'Transfer';
      }
    }
    return transaction.account ?? '';
  }
} 