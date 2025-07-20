import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExpenseItem extends StatelessWidget {
  final double amount;
  final String category;
  final String? categoryIcon; // New parameter for category icon
  final String date;
  final String type;
  final Color typeColor;

  const ExpenseItem({
    super.key,
    required this.amount,
    required this.category,
    this.categoryIcon,
    required this.date,
    required this.type,
    required this.typeColor,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(category, categoryIcon),
                color: typeColor,
                size: 20,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (date.isNotEmpty) ...[
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category, String? categoryIcon) {
    // First try to use the stored category icon
    if (categoryIcon != null) {
      switch (categoryIcon) {
        case 'utensils': return LucideIcons.utensils;
        case 'car': return LucideIcons.car;
        case 'smartphone': return LucideIcons.smartphone;
        case 'home': return LucideIcons.home;
        case 'shoppingBag': return LucideIcons.shoppingBag;
        case 'tv': return LucideIcons.tv;
        case 'heart': return LucideIcons.heart;
        case 'bookOpen': return LucideIcons.bookOpen;
        case 'moreHorizontal': return LucideIcons.moreHorizontal;
        case 'star': return LucideIcons.star;
        case 'smile': return LucideIcons.smile;
        case 'sun': return LucideIcons.sun;
        case 'moon': return LucideIcons.moon;
        case 'book': return LucideIcons.book;
        case 'briefcase': return LucideIcons.briefcase;
        case 'camera': return LucideIcons.camera;
        case 'gift': return LucideIcons.gift;
        case 'music': return LucideIcons.music;
        case 'pizza': return LucideIcons.pizza;
        case 'shoppingCart': return LucideIcons.shoppingCart;
        case 'trophy': return LucideIcons.trophy;
        case 'zap': return LucideIcons.zap;
        case 'creditCard': return LucideIcons.creditCard;
        case 'tag': return LucideIcons.tag;
        case 'plusCircle': return LucideIcons.plusCircle;
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