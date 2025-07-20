import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/accounts_data.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(
                  labelText: 'Initial Balance',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final balance = double.tryParse(balanceController.text) ?? 0.0;
                
                if (name.isNotEmpty) {
                  try {
                    print('Attempting to add account from UI: $name');
                    await context.read<AccountsData>().addAccount(name, balance);
                    print('Account added successfully from UI');
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error adding account from UI: $e');
                    // Show error to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding account: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add Account'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAccountDialog(BuildContext context, Account account) {
    final nameController = TextEditingController(text: account.name);
    final balanceController = TextEditingController(text: account.balance.toString());
    bool _isSaving = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Account Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: balanceController,
                    decoration: const InputDecoration(
                      labelText: 'Balance',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
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
                    final name = nameController.text.trim();
                    final balance = double.tryParse(balanceController.text) ?? 0.0;
                    if (name.isNotEmpty) {
                      await context.read<AccountsData>().updateAccount(
                        Account(id: account.id, name: name, balance: balance),
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
                        title: const Text('Delete Account'),
                        content: const Text('Are you sure you want to delete this account?'),
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
                      await context.read<AccountsData>().deleteAccount(account.id!);
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
      key: const PageStorageKey('accounts'),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Accounts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Consumer<AccountsData>(
        builder: (context, accountsData, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accountsData.accounts.length,
            itemBuilder: (context, index) {
              final account = accountsData.accounts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          LucideIcons.building2,
                          color: Theme.of(context).iconTheme.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${account.balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showEditAccountDialog(context, account);
                        },
                        icon: Icon(LucideIcons.edit, color: Theme.of(context).iconTheme.color),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddAccountDialog(context),
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
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 6,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
} 