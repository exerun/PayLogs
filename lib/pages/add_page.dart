import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/accounts_data.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/numeric_keypad.dart';
import '../providers/budget_provider.dart';
import '../widgets/account_selector_sheet.dart';
import '../widgets/category_selector_sheet.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedToggleIndex = 1; // EXPENSE selected by default
  String _amountText = '0';
  String? _selectedAccount;
  String? _selectedCategory;
  String? _selectedFromAccount;
  String? _selectedToAccount;
  final TextEditingController _notesController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  List<String> _categories = [
    "Food",
    "Transport",
    "Electronics",
    "Rent",
    "Others"
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  void _handleDigit(String digit) {
    setState(() {
      if (digit == '.') {
        if (_amountText.contains('.')) return; // Only one decimal allowed
        _amountText += '.';
      } else {
      if (_amountText == '0') {
        _amountText = digit;
      } else {
        _amountText += digit;
        }
      }
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_amountText.length > 1) {
        _amountText = _amountText.substring(0, _amountText.length - 1);
      } else {
        _amountText = '0';
      }
    });
  }

  void _saveTransaction() async {
    final amount = double.tryParse(_amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    // Get transaction type
    final transactionTypes = [TransactionType.income, TransactionType.expense, TransactionType.transfer];
    final type = transactionTypes[_selectedToggleIndex];

    // For expense, check budget before proceeding
    if (type == TransactionType.expense) {
      if (_selectedCategory == null) {
        _showSnackBar('Please select a category');
        return;
      }
      final budgetProvider = context.read<BudgetProvider>();
      final transactionProvider = context.read<TransactionProvider>();
      final budget = budgetProvider.getBudget(_selectedCategory!);
      final spent = transactionProvider.getCategoryExpense(_selectedCategory!);
      if (budget > 0 && spent + amount > budget) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Budget Exceeded'),
            content: Text('You have exceeded the budget for $_selectedCategory! Do you want to proceed?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Proceed'),
              ),
            ],
          ),
        );
        if (proceed != true) {
          return;
        }
      }
    }

    // Create transaction based on type
    Transaction transaction;
    
    if (type == TransactionType.transfer) {
      // For transfers, we need fromAccount and toAccount
      if (_selectedFromAccount == null || _selectedToAccount == null) {
        _showSnackBar('Please select both accounts for transfer');
        return;
      }
      if (_selectedFromAccount == _selectedToAccount) {
        _showSnackBar('Cannot transfer to the same account');
        return;
      }
      
      transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        fromAccount: _selectedFromAccount,
        toAccount: _selectedToAccount,
        amount: amount,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
      );
    } else {
      // For income/expense, we need account and category
      if (_selectedAccount == null) {
        _showSnackBar('Please select an account');
        return;
      }

      if (_selectedCategory == null) {
        _showSnackBar('Please select a category');
        return;
      }
      
      transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        account: _selectedAccount,
        category: _selectedCategory,
        notes: _notesController.text.trim(),
        amount: amount,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
      );
    }

    // Add transaction to provider
    context.read<TransactionProvider>().addTransaction(transaction);
    if (type == TransactionType.transfer) {
      context.read<AccountsData>().transfer(_selectedFromAccount!, _selectedToAccount!, amount);
    } else if (type == TransactionType.income) {
      context.read<AccountsData>().addIncome(_selectedAccount!, amount);
    } else if (type == TransactionType.expense) {
      context.read<AccountsData>().addExpense(_selectedAccount!, amount);
    }

    // Show success message
    _showSnackBar('Transaction saved successfully!');

    // Pop back to HomePage after a short delay to allow the snackbar to show
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) Navigator.of(context).pop();
    });

    // Reset form
    setState(() {
      _amountText = '0';
      _selectedAccount = null;
      _selectedCategory = null;
      _selectedFromAccount = null;
      _selectedToAccount = null;
      _notesController.clear();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectAccount() async {
    final result = await showAccountPicker(
      context,
      context.read<AccountsData>().accountNames,
      _selectedAccount,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _selectedAccount = result);
    }
  }

  Future<void> _selectCategory() async {
    final result = await showCategoryPicker(
      context,
      _categories,
      _selectedCategory,
    );
    if (!mounted) return;
    if (result != null && !_categories.contains(result)) {
      setState(() {
        _categories.add(result);
        _selectedCategory = result;
      });
    } else if (result != null) {
      setState(() => _selectedCategory = result);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important!
    return Scaffold(
      key: const PageStorageKey('add'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.close,
                color: Colors.orange,
                size: 20,
              ),
              label: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(
                Icons.check,
                color: Colors.orange,
                size: 20,
              ),
              label: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight < 600) {
              return const Center(
                child: Text(
                  "Screen too small",
                  style: TextStyle(fontSize: 18, fontFamily: 'JetBrainsMono'),
                ),
              );
            }
            final isTransfer = _selectedToggleIndex == 2;
            final accounts = context.read<AccountsData>().accountNames;
            final keypadHeight = constraints.maxHeight * 0.38;
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 600,
                maxHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                          // Transaction type toggle
            Container(
              decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF232323) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: ['INCOME', 'EXPENSE', 'TRANSFER'].asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = index == _selectedToggleIndex;
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                Color selectedColor;
                                Color textColor;
                                if (isSelected) {
                                  // Use soft pastel for selected tab in dark mode, muted in light
                                  if (index == 0) selectedColor = isDark ? const Color(0xFF2E4D3A) : const Color(0xFFD6F5E3); // Income
                                  else if (index == 1) selectedColor = isDark ? const Color(0xFF4D2E2E) : const Color(0xFFF5D6D6); // Expense
                                  else selectedColor = isDark ? const Color(0xFF4D4D2E) : const Color(0xFFF5F3D6); // Transfer
                                  textColor = isDark ? Colors.white : Colors.black;
                                } else {
                                  selectedColor = Colors.transparent;
                                  textColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
                                }
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedToggleIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                                        color: selectedColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                                          color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
                          const SizedBox(height: 12),
            // Amount display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF232323) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                              '₹ $_amountText',
                textAlign: TextAlign.right,
                              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
            ),
                          const SizedBox(height: 12),
                          // Account selectors
                          if (isTransfer)
                      Row(
                        children: [
                          Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () async {
                                      final result = await showAccountPicker(
                                        context,
                                        accounts,
                                        _selectedFromAccount,
                                      );
                                      if (!mounted) return;
                                      if (result != null) {
                                        setState(() => _selectedFromAccount = result);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                      child: Row(
                                        children: [
                                          const Text('🏦', style: TextStyle(fontSize: 20)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedFromAccount ?? 'From Account',
                                              style: TextStyle(
                                                color: _selectedFromAccount == null
                                                    ? Colors.grey
                                                    : Theme.of(context).textTheme.bodyLarge?.color,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () async {
                                      final result = await showAccountPicker(
                                        context,
                                        accounts,
                                        _selectedToAccount,
                                      );
                                      if (!mounted) return;
                                      if (result != null) {
                                        setState(() => _selectedToAccount = result);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                      child: Row(
                                        children: [
                                          const Text('🏦', style: TextStyle(fontSize: 20)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedToAccount ?? 'To Account',
                                              style: TextStyle(
                                                color: _selectedToAccount == null
                                                    ? Colors.grey
                                                    : Theme.of(context).textTheme.bodyLarge?.color,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ],
                            ),
                          ),
                                  ),
                      ),
                    ],
                            )
                          else
                            Row(
                    children: [
                      Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: _selectAccount,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                                      child: Row(
                                        children: [
                                          const Text('🏦', style: TextStyle(fontSize: 20)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedAccount ?? 'Account',
                                              style: TextStyle(
                                                color: _selectedAccount == null
                                                    ? Colors.grey
                                                    : Theme.of(context).textTheme.bodyLarge?.color,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: _selectCategory,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                                      child: Row(
                                        children: [
                                          const Text('📦', style: TextStyle(fontSize: 20)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedCategory ?? 'Category',
                                              style: TextStyle(
                                                color: _selectedCategory == null
                                                    ? Colors.grey
                                                    : Theme.of(context).textTheme.bodyLarge?.color,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                    ],
            ),
                          const SizedBox(height: 12),
                          // Date + Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                                  borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                                  borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(_selectedTime),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.access_time, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
                          const SizedBox(height: 12),
                          // Note field
                          if (_selectedToggleIndex != 2)
                  TextField(
                    controller: _notesController,
                              minLines: 1,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Add notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                              style: const TextStyle(fontFamily: 'JetBrainsMono'),
                  ),
                ],
              ),
                    ),
                  ),
                  // Responsive Keypad
                  SizedBox(
                    height: keypadHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: NumericKeypad(
                        onTap: _handleDigit,
                        onBack: _handleBackspace,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
            ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
} 