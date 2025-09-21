import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../providers/currency_provider.dart';
import '../data/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _dailyTargetController = TextEditingController();
  final _monthlyTargetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTargets();
  }

  Future<void> _loadCurrentTargets() async {
    final targets = await SettingsService.getTargets();
    if (mounted) {
      _dailyTargetController.text = targets['daily']!.toStringAsFixed(0);
      _monthlyTargetController.text = targets['monthly']!.toStringAsFixed(0);
    }
  }

  Future<void> _saveTargets() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dailyTarget = double.tryParse(_dailyTargetController.text) ?? 500.0;
      final monthlyTarget = double.tryParse(_monthlyTargetController.text) ?? 15000.0;

      await SettingsService.setDailyTarget(dailyTarget);
      await SettingsService.setMonthlyTarget(monthlyTarget);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Targets saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving targets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _dailyTargetController.dispose();
    _monthlyTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Expense Targets Section
            const Text('Expense Targets', 
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
            const SizedBox(height: 16),
            
            // Daily Target
            TextFormField(
              controller: _dailyTargetController,
              decoration: const InputDecoration(
                labelText: 'Daily Expense Target',
                prefixText: '₹',
                border: OutlineInputBorder(),
                helperText: 'Set your daily spending limit',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a daily target';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Target must be greater than 0';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Monthly Target
            TextFormField(
              controller: _monthlyTargetController,
              decoration: const InputDecoration(
                labelText: 'Monthly Expense Target',
                prefixText: '₹',
                border: OutlineInputBorder(),
                helperText: 'Set your monthly spending limit',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a monthly target';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Target must be greater than 0';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Dark Mode Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Mode', 
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
                Switch(
                  value: isDark,
                  onChanged: (val) => themeNotifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Currency Selection
            const Text('Currency', 
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: currencyProvider.currency,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
                DropdownMenuItem(value: 'USD', child: Text('24 USD')),
                DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                DropdownMenuItem(value: 'JPY', child: Text('¥ JPY')),
                DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
              ],
              onChanged: (val) {
                if (val != null) currencyProvider.setCurrency(val);
              },
            ),
            const SizedBox(height: 32),
            
            // Save Targets Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTargets,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Text('Save Targets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Backup & Restore
            const Text('Backup and Restore', 
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
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
      ),
    );
  }
} 