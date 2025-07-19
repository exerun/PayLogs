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
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    _newCategoryController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showEditBudgetDialog(BuildContext context, String category, double amount) {
    final controller = TextEditingController(text: amount == 0.0 ? '' : amount.toStringAsFixed(0));
    bool _isSaving = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
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
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : () async {
                    setState(() => _isSaving = true);
                    final newValue = double.tryParse(controller.text) ?? 0.0;
                    await context.read<BudgetProvider>().updateBudget(category, newValue);
                    Navigator.of(context).pop();
                    setState(() => _isSaving = false);
                  },
                  child: const Text('Save'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: _isSaving ? null : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Category'),
                        content: const Text('Are you sure you want to delete this category?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      setState(() => _isSaving = true);
                      await context.read<BudgetProvider>().removeCategory(category);
                      Navigator.of(context).pop();
                      setState(() => _isSaving = false);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Add Category',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final newCategory = _newCategoryController.text.trim();
                      if (newCategory.isNotEmpty) {
                        budgetProvider.addCategory(newCategory);
                        _newCategoryController.clear();
                        // Create a controller for the new category
                        _controllers[newCategory] = TextEditingController();
                      }
                    },
                    child: const Icon(LucideIcons.plus),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final category = budgets.keys.elementAt(index);
                  final amount = budgets[category]!;
                  final controller = _controllers.putIfAbsent(
                    category,
                    () => TextEditingController(text: amount == 0.0 ? '' : amount.toStringAsFixed(0)),
                  );
                  // Keep controller in sync with provider if changed elsewhere
                  if (controller.text != (amount == 0.0 ? '' : amount.toStringAsFixed(0))) {
                    controller.text = amount == 0.0 ? '' : amount.toStringAsFixed(0);
                    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                  }
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        category,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Budget: ₹${amount.toStringAsFixed(0)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditBudgetDialog(context, category, amount),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 