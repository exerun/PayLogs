import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../providers/currency_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Dark Mode Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dark Mode', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
              Switch(
                value: isDark,
                onChanged: (val) => themeNotifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Currency Selection
          const Text('Currency', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: currencyProvider.currency,
            items: const [
              DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
              DropdownMenuItem(value: 'USD', child: Text(' 24 USD')),
              DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
              DropdownMenuItem(value: 'JPY', child: Text('¥ JPY')),
              DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
            ],
            onChanged: (val) {
              if (val != null) currencyProvider.setCurrency(val);
            },
          ),
          const SizedBox(height: 40),
          // Backup & Restore
          const Text('Backup and Restore', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Backup'),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Restore'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 