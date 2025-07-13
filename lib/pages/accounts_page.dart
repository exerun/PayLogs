import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              onPressed: () {
                final name = nameController.text.trim();
                final balance = double.tryParse(balanceController.text) ?? 0.0;
                
                if (name.isNotEmpty) {
                  context.read<AccountsData>().addAccount(name, balance);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Account'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important!
    return Scaffold(
      key: const PageStorageKey('accounts'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Accounts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                        child: const Icon(
                          Icons.account_balance,
                          color: Colors.blue,
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
                          final nameController = TextEditingController(text: account.name);
                          final balanceController = TextEditingController(text: account.balance.toString());
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
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
                                        prefixText: '\u20b9',
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
                                    onPressed: () {
                                      final newName = nameController.text.trim();
                                      final newBalance = double.tryParse(balanceController.text) ?? account.balance;
                                      if (newName.isNotEmpty) {
                                        context.read<AccountsData>().editAccount(index, newName, newBalance);
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 