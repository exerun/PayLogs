import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'add_page.dart';
import '../widgets/expense_item.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../data/accounts_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return const Color(0xFFD2B48C);
    }
  }

  void _showTransactionOptions(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(LucideIcons.edit),
              title: const Text('Edit Transaction'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit functionality later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.red),
              title: const Text(
                'Delete Transaction',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: const Text(
                      'Are you sure you want to delete this transaction?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await context.read<TransactionProvider>().deleteTransaction(
                    transaction.id,
                    context,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    Transaction transaction,
  ) {
    final notesController = TextEditingController(
      text: transaction.notes ?? '',
    );
    final amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    bool isSaving = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Transaction'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() => isSaving = true);
                          final amount =
                              double.tryParse(amountController.text) ?? 0.0;
                          final notes = notesController.text.trim();
                          if (amount > 0) {
                            await context
                                .read<TransactionProvider>()
                                .updateTransaction(
                                  transaction.copyWith(
                                    amount: amount,
                                    notes: notes,
                                  ),
                                  context,
                                );
                            Navigator.of(context).pop();
                          }
                          setState(() => isSaving = false);
                        },
                  child: const Text('Save'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: isSaving
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Transaction'),
                              content: const Text(
                                'Are you sure you want to delete this transaction?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            setState(() => isSaving = true);
                            await context
                                .read<TransactionProvider>()
                                .deleteTransaction(transaction.id, context);
                            Navigator.of(context).pop();
                            setState(() => isSaving = false);
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
    super.build(context); // Important!

    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight
        ? const Color(0xFFFAF9F5)
        : Theme.of(context).colorScheme.surface;
    return Scaffold(
      key: const PageStorageKey('home'),
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'PayLogs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: bgColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer2<TransactionProvider, AccountsData>(
        builder: (context, transactionProvider, accountsData, child) {
          final transactions = transactionProvider.transactions;
          // Sort transactions by date (most recent first)
          final sortedTransactions = List.from(transactions)
            ..sort((a, b) => b.date.compareTo(a.date));

          if (sortedTransactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.receipt, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first transaction using the + button',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group transactions by date
          Map<String, List<Transaction>> groupedTransactions = {};
          for (var transaction in sortedTransactions) {
            String dateKey = _formatDate(transaction.date);
            if (!groupedTransactions.containsKey(dateKey)) {
              groupedTransactions[dateKey] = [];
            }
            groupedTransactions[dateKey]!.add(transaction);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              String dateKey = groupedTransactions.keys.elementAt(index);
              List<Transaction> dayTransactions = groupedTransactions[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      dateKey,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  // Transactions for this date
                  ...dayTransactions.map((transaction) {
                    String accountLabel = '';
                    if (transaction.type == TransactionType.transfer) {
                      final fromAccList = accountsData.accounts.where(
                        (a) => a.id == transaction.fromAccountId,
                      );
                      final toAccList = accountsData.accounts.where(
                        (a) => a.id == transaction.toAccountId,
                      );
                      final fromAcc = fromAccList.isNotEmpty
                          ? fromAccList.first
                          : null;
                      final toAcc = toAccList.isNotEmpty
                          ? toAccList.first
                          : null;
                      if (fromAcc != null && toAcc != null) {
                        accountLabel = '${fromAcc.name} → ${toAcc.name}';
                      } else {
                        accountLabel =
                            '${transaction.fromAccount ?? ''} → ${transaction.toAccount ?? ''}';
                      }
                    } else {
                      final accList = accountsData.accounts.where(
                        (a) => a.id == transaction.accountId,
                      );
                      final acc = accList.isNotEmpty ? accList.first : null;
                      accountLabel = acc != null
                          ? acc.name
                          : (transaction.account ?? '');
                    }

                    return ExpenseItem(
                      amount: transaction.amount,
                      category: transaction.category ?? accountLabel,
                      categoryIcon: transaction.categoryIcon,
                      date: '', // Empty date since we're grouping by date
                      type: '',
                      typeColor: _getTypeColor(transaction.type),
                      onOptionsPressed: () =>
                          _showTransactionOptions(context, transaction),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.01),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPage(),
                fullscreenDialog: true,
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: Icon(
            LucideIcons.plus,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            size: 18,
          ),
          label: Text(
            'Add',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32), // pill shape
          ),
          elevation: 6,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
