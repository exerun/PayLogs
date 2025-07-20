import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'add_page.dart';
import '../widgets/expense_item.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../data/accounts_data.dart';
import 'settings_page.dart';

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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return const Color.fromRGBO(179, 255, 179, 1); // green
      case TransactionType.expense:
        return const Color.fromRGBO(139, 30, 63, 1); // red
      case TransactionType.transfer:
        return const Color.fromRGBO(255, 207, 153, 1); // yellow
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

  void _showEditTransactionDialog(BuildContext context, Transaction transaction) {
    final notesController = TextEditingController(text: transaction.notes ?? '');
    final amountController = TextEditingController(text: transaction.amount.toString());
    bool _isSaving = false;
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
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : () async {
                    setState(() => _isSaving = true);
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    final notes = notesController.text.trim();
                    if (amount > 0) {
                      await context.read<TransactionProvider>().updateTransaction(
                        transaction.copyWith(amount: amount, notes: notes),
                        context,
                      );
                      Navigator.of(context).pop();
                    }
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
                        title: const Text('Delete Transaction'),
                        content: const Text('Are you sure you want to delete this transaction?'),
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
                      await context.read<TransactionProvider>().deleteTransaction(transaction.id, context);
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
    super.build(context); // Important!
    
    return Scaffold(
      key: const PageStorageKey('home'),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        title: Text(
          'PayLogs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
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
                  Icon(
                    LucideIcons.receipt,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first transaction using the + button',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      dateKey,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ),
                  // Transactions for this date
                  ...dayTransactions.map((transaction) {
                    String accountLabel = '';
                    if (transaction.type == TransactionType.transfer) {
                      final fromAccList = accountsData.accounts.where((a) => a.id == transaction.fromAccountId);
                      final toAccList = accountsData.accounts.where((a) => a.id == transaction.toAccountId);
                      final fromAcc = fromAccList.isNotEmpty ? fromAccList.first : null;
                      final toAcc = toAccList.isNotEmpty ? toAccList.first : null;
                      if (fromAcc != null && toAcc != null) {
                        accountLabel = '${fromAcc.name} → ${toAcc.name}';
                      } else {
                        accountLabel = (transaction.fromAccount ?? '') + ' → ' + (transaction.toAccount ?? '');
                      }
                    } else {
                      final accList = accountsData.accounts.where((a) => a.id == transaction.accountId);
                      final acc = accList.isNotEmpty ? accList.first : null;
                      accountLabel = acc != null ? acc.name : (transaction.account ?? '');
                    }
                    
                    return GestureDetector(
                      onTap: () => _showEditTransactionDialog(context, transaction),
                      child: ExpenseItem(
                        amount: transaction.amount,
                        category: transaction.category ?? accountLabel,
                        categoryIcon: transaction.categoryIcon,
                        date: '', // Empty date since we're grouping by date
                        type: _getTypeString(transaction.type),
                        typeColor: _getTypeColor(transaction.type),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // sits well above nav bar
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
          backgroundColor: const Color.fromRGBO(249, 87, 56, 1),
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: const Text(
            'Add',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32), // pill shape
          ),
          elevation: 6,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
} 