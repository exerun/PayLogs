import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/budget_provider.dart';

class BudgetSection extends StatefulWidget {
  const BudgetSection({super.key});

  @override
  State<BudgetSection> createState() => _BudgetSectionState();
}

class _BudgetSectionState extends State<BudgetSection> {
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _newBudgetController = TextEditingController();

  @override
  void dispose() {
    _newCategoryController.dispose();
    _newBudgetController.dispose();
    super.dispose();
  }

  void _showEditBudgetDialog(BuildContext context, String category, double amount) {
    final controller = TextEditingController(text: amount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Budget for $category'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monthly Budget',
            prefixText: '₹',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = double.tryParse(controller.text) ?? 0.0;
              if (newValue > 0) {
                await context.read<BudgetProvider>().updateBudget(category, newValue);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Category'),
                  content: const Text('Delete this budget category?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await context.read<BudgetProvider>().removeCategory(category);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final budgets = budgetProvider.budgets;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add budget section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Budget Category',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _newCategoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category Name',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _newBudgetController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Budget',
                                border: OutlineInputBorder(),
                                prefixText: '₹',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final newCategory = _newCategoryController.text.trim();
                              final budget = double.tryParse(_newBudgetController.text) ?? 0.0;
                              if (newCategory.isNotEmpty && budget > 0) {
                                budgetProvider.setBudget(newCategory, budget);
                                _newCategoryController.clear();
                                _newBudgetController.clear();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD2B48C),
                            ),
                            child: Icon(
                              LucideIcons.plus,
                              size: 16,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Budget categories
              if (budgets.isNotEmpty) ...[
                const Text(
                  'Budget Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                for (final entry in budgets.entries)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Budget: ₹${entry.value.toStringAsFixed(0)}'),
                      trailing: IconButton(
                        icon: const Icon(LucideIcons.edit, size: 16),
                        onPressed: () => _showEditBudgetDialog(context, entry.key, entry.value),
                      ),
                    ),
                  ),
              ] else ...[
                const Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.target, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No budgets set yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add a budget category above to get started',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
