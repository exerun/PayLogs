import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  // Map categories to Lucide icons
  static const Map<String, IconData> _categoryIcons = {
    'Food': LucideIcons.utensils,
    'Transport': LucideIcons.bus,
    'Electronics': LucideIcons.monitor,
    'Rent': LucideIcons.building,
    'Utilities': LucideIcons.lightbulb,
    'Shopping': LucideIcons.shoppingBag,
    'Entertainment': LucideIcons.film,
    'Healthcare': LucideIcons.heartPulse,
    'Education': LucideIcons.bookOpen,
    'Travel': LucideIcons.plane,
    'Others': LucideIcons.box,
    'Unknown': LucideIcons.info,
  };

  Color _getAmountColor(TransactionType type, BuildContext context) {
    // Use theme accent for all, but slightly tint for type
    final theme = Theme.of(context);
    switch (type) {
      case TransactionType.income:
        return theme.colorScheme.secondary.withOpacity(0.8);
      case TransactionType.expense:
        return theme.colorScheme.error.withOpacity(0.8);
      case TransactionType.transfer:
        return theme.colorScheme.primary.withOpacity(0.8);
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
    final isDark = theme.brightness == Brightness.dark;
    final neutralCardColor = isDark
        ? const Color(0xFF23242A)
        : const Color(0xFFF6F7FA);
    final iconColor = isDark ? Colors.white : Colors.black87;
    final iconBg = isDark ? const Color(0xFF35363C) : const Color(0xFFE0E2E7);
    final icon = _categoryIcons[transaction.category] ?? _categoryIcons['Unknown'];

    return SizedBox(
      width: 160,
      height: 136,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        color: neutralCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Lucide icon in a circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getAmountColor(transaction.type, context).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getTypeString(transaction.type),
                        style: TextStyle(
                          fontSize: 9,
                          color: _getAmountColor(transaction.type, context),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrainsMono',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                transaction.category ?? 'Unknown',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'JetBrainsMono',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (transaction.notes?.isNotEmpty == true)
                Text(
                  transaction.notes!,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    fontSize: 10,
                    fontFamily: 'JetBrainsMono',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (transaction.notes?.isNotEmpty == true) const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'JetBrainsMono',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (transaction.account != null || transaction.fromAccount != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getAccountInfo(),
                          style: TextStyle(
                            fontSize: 8,
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            fontFamily: 'JetBrainsMono',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
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