import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExpenseItem extends StatelessWidget {
  final double amount;
  final String category;
  final String? categoryIcon; // New parameter for category icon
  final String date;
  final String type;
  final Color typeColor;
  final VoidCallback? onOptionsPressed;

  const ExpenseItem({
    super.key,
    required this.amount,
    required this.category,
    this.categoryIcon,
    required this.date,
    required this.type,
    required this.typeColor,
    this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category icon placeholder
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(category, categoryIcon),
                color: typeColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            // Category and date info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (onOptionsPressed != null)
                  GestureDetector(
                    onTap: onOptionsPressed,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        LucideIcons.moreVertical,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category, String? categoryIcon) {
    // Check if it's a transfer transaction first
    if (category.contains('→') || category.toLowerCase().contains('transfer')) {
      return LucideIcons.arrowLeftRight;
    }

    // First try to use the stored category icon
    if (categoryIcon != null) {
      switch (categoryIcon) {
        case 'utensils':
          return LucideIcons.utensils;
        case 'car':
          return LucideIcons.car;
        case 'smartphone':
          return LucideIcons.smartphone;
        case 'home':
          return LucideIcons.home;
        case 'shoppingBag':
          return LucideIcons.shoppingBag;
        case 'tv':
          return LucideIcons.tv;
        case 'heart':
          return LucideIcons.heart;
        case 'bookOpen':
          return LucideIcons.bookOpen;
        case 'moreHorizontal':
          return LucideIcons.moreHorizontal;
        case 'star':
          return LucideIcons.star;
        case 'smile':
          return LucideIcons.smile;
        case 'sun':
          return LucideIcons.sun;
        case 'moon':
          return LucideIcons.moon;
        case 'book':
          return LucideIcons.book;
        case 'briefcase':
          return LucideIcons.briefcase;
        case 'camera':
          return LucideIcons.camera;
        case 'gift':
          return LucideIcons.gift;
        case 'music':
          return LucideIcons.music;
        case 'pizza':
          return LucideIcons.pizza;
        case 'shoppingCart':
          return LucideIcons.shoppingCart;
        case 'trophy':
          return LucideIcons.trophy;
        case 'zap':
          return LucideIcons.zap;
        case 'creditCard':
          return LucideIcons.creditCard;
        case 'tag':
          return LucideIcons.tag;
        case 'plusCircle':
          return LucideIcons.plusCircle;
      }
    }

    // Fallback to category name matching
    switch (category.toLowerCase()) {
      case 'food':
        return LucideIcons.utensils;
      case 'transport':
        return LucideIcons.car;
      case 'shopping':
        return LucideIcons.shoppingBag;
      case 'entertainment':
        return LucideIcons.tv;
      case 'health':
        return LucideIcons.heart;
      case 'income':
        return LucideIcons.trendingUp;
      default:
        return LucideIcons.tag;
    }
  }
}
