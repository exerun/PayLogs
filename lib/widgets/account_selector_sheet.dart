import 'package:flutter/material.dart';

Future<String?> showAccountPicker(BuildContext context, List<String> accounts, String? selectedAccount) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Choose an Account',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 0),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: accounts.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Text('\uD83C\uDFE6', style: TextStyle(fontSize: 24)),
                title: Text(accounts[i]),
                selected: accounts[i] == selectedAccount,
                onTap: () => Navigator.pop(context, accounts[i]),
              ),
              separatorBuilder: (_, __) => const Divider(height: 0),
            ),
          ),
        ],
      ),
    ),
  );
}

class AccountSelectorSheet extends StatelessWidget {
  final List<String> accounts;
  final String? selectedAccount;
  final ValueChanged<String> onSelected;

  const AccountSelectorSheet({
    super.key,
    required this.accounts,
    required this.selectedAccount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Deprecated: use showAccountPicker instead
    return const SizedBox.shrink();
  }
} 