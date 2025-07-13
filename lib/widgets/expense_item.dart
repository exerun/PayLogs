import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  final double amount;
  final String category;
  final String date;
  final String type;
  final Color typeColor;
  final String? account;
  final String? fromAccount;
  final String? toAccount;
  final VoidCallback? onDelete;
  final String? transactionId;

  const ExpenseItem({
    super.key,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.typeColor,
    this.account,
    this.fromAccount,
    this.toAccount,
    this.onDelete,
    this.transactionId,
  });

  static const Map<String, String> _categoryEmojis = {
    'Food': '🍔',
    'Transport': '🚗',
    'Electronics': '💻',
    'Rent': '🏠',
    'Utilities': '💡',
    'Others': '📦',
    'Unknown': '❓',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: Stack(
        children: [
          Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
                // Category icon and account name
                Column(
                  children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
                      child: Center(
                        child: Text(
                          _categoryEmojis[category] ?? _categoryEmojis['Unknown']!,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 56,
                      child: Text(
                        _getAccountLabel(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontFamily: 'JetBrainsMono',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
                  ],
            ),
            const SizedBox(width: 12),
            // Category and date info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 10,
                            color: typeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                    color: typeColor,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ],
            ),
          ),
          // Delete button (top right)
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.red[200]
                          : Colors.red[700],
                    ),
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }

  String _getAccountLabel() {
    if (type.toLowerCase() == 'transfer') {
      if (fromAccount != null && toAccount != null) {
        return 'From: $fromAccount\nTo: $toAccount';
      } else {
        return 'Transfer';
      }
    }
    return account ?? '';
  }
} 