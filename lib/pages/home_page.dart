import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/transaction_card.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'settings_page.dart';
import 'add_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatFullDate(DateTime dateTime) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  Widget _buildDateDivider(DateTime date) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Divider(
              color: theme.dividerColor.withValues(alpha: 0.5),
              thickness: 1,
              endIndent: 8,
            ),
          ),
          Text(
            _formatFullDate(date),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.dividerColor.withValues(alpha: 0.5),
              thickness: 1,
              indent: 8,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions, String emptyMessage) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.withValues(alpha: 0.8),
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      );
    }

    // Group transactions by date
    final grouped = <DateTime, List<Transaction>>{};
    for (final tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      grouped.putIfAbsent(date, () => []).add(tx);
    }
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: sortedDates.fold<int>(0, (sum, d) => sum + (grouped[d]?.length ?? 0) + 1),
      itemBuilder: (context, index) {
        int running = 0;
        for (final date in sortedDates) {
          if (index == running) {
            return _buildDateDivider(date);
          }
          running++;
          final txs = grouped[date]!;
          if (index < running + txs.length) {
            final tx = txs[index - running];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TransactionCard(
                transaction: tx,
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Transaction'),
                      content: const Text('Are you sure you want to delete this transaction?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  final provider = Provider.of<TransactionProvider>(context, listen: false);
                  final idx = provider.transactions.indexWhere((t) => t.id == tx.id);
                  final deleted = await provider.deleteTransactionById(tx.id);
                  if (deleted != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Transaction deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await provider.insertTransactionAt(deleted, idx);
                          },
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            );
          }
          running += txs.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      key: const PageStorageKey('home'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'PayLogs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
              final transactions = transactionProvider.transactions;
              final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
              final income = transactions.where((t) => t.type == TransactionType.income).toList();
              final transfers = transactions.where((t) => t.type == TransactionType.transfer).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  
                  // Ensure minimum width for tabs
                  final minTabWidth = 120.0; // Minimum width per tab
                  final totalMinWidth = minTabWidth * 3; // 3 tabs
                  
                  // If screen is too narrow, adjust tab content
                  final isCompact = screenWidth < totalMinWidth;
                  
                  return Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      labelStyle: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 10 : 12,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.w500,
                        fontSize: isCompact ? 10 : 12,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_down,
                                size: isCompact ? 14 : 16,
                                color: _selectedTabIndex == 0 ? Colors.white : null,
                              ),
                              SizedBox(width: isCompact ? 2 : 4),
                              Flexible(
                                child: Text(
                                  isCompact ? 'Exp (${expenses.length})' : 'Expenses (${expenses.length})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: isCompact ? 14 : 16,
                                color: _selectedTabIndex == 1 ? Colors.white : null,
                              ),
                              SizedBox(width: isCompact ? 2 : 4),
                              Flexible(
                                child: Text(
                                  isCompact ? 'Inc (${income.length})' : 'Income (${income.length})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                size: isCompact ? 14 : 16,
                                color: _selectedTabIndex == 2 ? Colors.white : null,
                              ),
                              SizedBox(width: isCompact ? 2 : 4),
                              Flexible(
                                child: Text(
                                  isCompact ? 'Trans (${transfers.length})' : 'Transfers (${transfers.length})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final transactions = transactionProvider.transactions;
          
          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first transaction using the + button',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ],
              ),
            );
          }

          final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
          final income = transactions.where((t) => t.type == TransactionType.income).toList();
          final transfers = transactions.where((t) => t.type == TransactionType.transfer).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionList(expenses, 'No expenses yet'),
              _buildTransactionList(income, 'No income yet'),
              _buildTransactionList(transfers, 'No transfers yet'),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: SizedBox(
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddPage()),
              );
            },
            label: const Text(
              'Add',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            icon: const Icon(Icons.add),
            shape: const StadiumBorder(),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF232323)
                : Colors.black,
            foregroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.white,
            elevation: 3,
          ),
        ),
      ),
    );
  }
} 