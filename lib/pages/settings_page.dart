import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedCurrency = 'INR';
  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Switch Row
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(isDark ? Icons.nightlight_round : Icons.lightbulb_outline, color: isDark ? Colors.amber[700] : Colors.amber),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Dark Mode')),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Switch(
                        key: ValueKey(isDark),
                        value: isDark,
                        onChanged: (val) async {
                          await themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            // Currency Selector
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.green),
                    const SizedBox(width: 12),
                    const Text('Currency'),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _selectedCurrency,
                      items: _currencies.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      )).toList(),
                      onChanged: (val) {
                        // TODO: Implement currency change
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            // Storage Directory
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.folder, color: Colors.blue),
                title: const Text('Storage Directory'),
                subtitle: const Text('/storage/emulated/0/PayLogs'),
                trailing: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () {
                    // TODO: Open directory picker
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            // Backup & Recover
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.backup),
                    label: const Text('Backup'),
                    onPressed: () {
                      // TODO: Backup logic
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.restore),
                    label: const Text('Recover'),
                    onPressed: () {
                      // TODO: Recover logic
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            // Rate the App
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.star_rate, color: Colors.orange),
                title: const Text('Rate PayLogs'),
                onTap: () {
                  // TODO: Rate app
                },
              ),
            ),
            const SizedBox(height: 24),
            // Credits
            const Center(
              child: Text(
                'Made with ❤️ by Adityas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 