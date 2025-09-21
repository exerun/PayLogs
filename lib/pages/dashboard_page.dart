import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../data/settings_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  double dailyTarget = 500.0;
  double monthlyTarget = 15000.0;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    final targets = await SettingsService.getTargets();
    if (mounted) {
      setState(() {
        dailyTarget = targets['daily'] ?? 500.0;
        monthlyTarget = targets['monthly'] ?? 15000.0;
      });
    }
  }

  double _getTodayExpenses(List<Transaction> transactions) {
    final today = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _getMonthExpenses(List<Transaction> transactions) {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> _getCategoryBreakdown(List<Transaction> transactions) {
    final now = DateTime.now();
    final monthlyExpenses = transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.year == now.year &&
        t.date.month == now.month);

    Map<String, double> breakdown = {};
    for (var transaction in monthlyExpenses) {
      String category = transaction.category ?? 'Other';
      breakdown[category] = (breakdown[category] ?? 0) + transaction.amount;
    }
    return breakdown;
  }

  List<Color> _getCategoryColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight
        ? const Color(0xFFFAF9F5)
        : Theme.of(context).colorScheme.surface;

    return Scaffold(
      key: const PageStorageKey('dashboard'),
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
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final transactions = transactionProvider.transactions;
          final todayExpenses = _getTodayExpenses(transactions);
          final monthExpenses = _getMonthExpenses(transactions);
          final categoryBreakdown = _getCategoryBreakdown(transactions);

          return RefreshIndicator(
            onRefresh: () async {
              await _loadTargets();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense Target Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Daily Indicator
                      Column(
                        children: [
                          CircularPercentIndicator(
                            radius: 60.0,
                            lineWidth: 12.0,
                            percent: dailyTarget > 0
                                ? (todayExpenses / dailyTarget).clamp(0.0, 1.0)
                                : 0.0,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '₹${todayExpenses.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                Text(
                                  'spent',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            footer: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'of ₹${dailyTarget.toStringAsFixed(0)} daily target',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            progressColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                          ),
                        ],
                      ),
                      // Monthly Indicator
                      Column(
                        children: [
                          CircularPercentIndicator(
                            radius: 60.0,
                            lineWidth: 12.0,
                            percent: monthlyTarget > 0
                                ? (monthExpenses / monthlyTarget).clamp(0.0, 1.0)
                                : 0.0,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '₹${monthExpenses.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                Text(
                                  'spent',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            footer: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'of ₹${monthlyTarget.toStringAsFixed(0)} monthly target',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            progressColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Category Breakdown Section
                  Text(
                    'Category Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (categoryBreakdown.isNotEmpty) ...[
                    // Category Breakdown Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 20,
                          child: Row(
                            children: categoryBreakdown.entries
                                .map((entry) {
                                  final percentage = monthExpenses > 0
                                      ? (entry.value / monthExpenses * 100)
                                      : 0.0;
                                  final colorIndex = categoryBreakdown.keys
                                      .toList()
                                      .indexOf(entry.key);
                                  final colors = _getCategoryColors();
                                  
                                  return Expanded(
                                    flex: percentage.round(),
                                    child: Container(
                                      height: 20,
                                      color: colors[colorIndex % colors.length],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Category Legend
                    ...categoryBreakdown.entries.map((entry) {
                      final percentage = monthExpenses > 0
                          ? (entry.value / monthExpenses * 100)
                          : 0.0;
                      final colorIndex =
                          categoryBreakdown.keys.toList().indexOf(entry.key);
                      final colors = _getCategoryColors();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[colorIndex % colors.length],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                            ),
                            Text(
                              '₹${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 48,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No expenses this month',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some transactions to see your category breakdown',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Quick Stats
                  Text(
                    'Quick Stats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Transactions',
                          transactions.length.toString(),
                          Icons.receipt_long,
                          context,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Avg Daily Expense',
                          monthExpenses > 0
                              ? '₹${(monthExpenses / DateTime.now().day).toStringAsFixed(0)}'
                              : '₹0',
                          Icons.trending_up,
                          context,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
