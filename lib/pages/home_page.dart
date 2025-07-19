import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'add_page.dart';
import '../widgets/expense_item.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'settings_page.dart';
import '../providers/accounts_provider.dart';

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
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
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
          if (transactions.isEmpty) {
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
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              String accountLabel = '';
              if (transaction.type == TransactionType.transfer) {
                final fromAcc = accountsData.accounts.firstWhere(
                  (a) => a.id == transaction.fromAccountId,
                  orElse: () => null,
                );
                final toAcc = accountsData.accounts.firstWhere(
                  (a) => a.id == transaction.toAccountId,
                  orElse: () => null,
                );
                accountLabel = fromAcc != null && toAcc != null
                  ? '${fromAcc.name} → ${toAcc.name}'
                  : (transaction.fromAccount ?? '') + ' → ' + (transaction.toAccount ?? '');
              } else {
                final acc = accountsData.accounts.firstWhere(
                  (a) => a.id == transaction.accountId,
                  orElse: () => null,
                );
                accountLabel = acc?.name ?? transaction.account ?? '';
              }
              return GestureDetector(
                onTap: () => _showEditTransactionDialog(context, transaction),
                child: ExpenseItem(
                  amount: transaction.amount,
                  category: transaction.category ?? accountLabel,
                  date: _formatDate(transaction.date),
                  type: _getTypeString(transaction.type),
                  typeColor: _getTypeColor(transaction.type),
                ),
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
          backgroundColor: Colors.orange,
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