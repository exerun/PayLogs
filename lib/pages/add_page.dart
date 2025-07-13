import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/accounts_data.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/custom_keypad.dart';
import '../widgets/selection_modal.dart';

const double gap = 14.0;

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
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Category options with Lucide icons
  final List<SelectionOption> _categoryOptions = [
    const SelectionOption(value: 'Food', label: 'Food', icon: LucideIcons.utensils),
    const SelectionOption(value: 'Transport', label: 'Transport', icon: LucideIcons.car),
    const SelectionOption(value: 'Electronics', label: 'Electronics', icon: LucideIcons.smartphone),
    const SelectionOption(value: 'Rent', label: 'Rent', icon: LucideIcons.home),
    const SelectionOption(value: 'Shopping', label: 'Shopping', icon: LucideIcons.shoppingBag),
    const SelectionOption(value: 'Entertainment', label: 'Entertainment', icon: LucideIcons.tv),
    const SelectionOption(value: 'Health', label: 'Health', icon: LucideIcons.heart),
    const SelectionOption(value: 'Education', label: 'Education', icon: LucideIcons.bookOpen),
    const SelectionOption(value: 'Others', label: 'Others', icon: LucideIcons.moreHorizontal),
  ];

  void _onDigitPressed(String digit) {
    setState(() {
      if (_amountText == '0') {
        _amountText = digit;
      } else {
        _amountText += digit;
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_amountText.length > 1) {
        _amountText = _amountText.substring(0, _amountText.length - 1);
      } else {
        _amountText = '0';
      }
    });
  }

  void _showAccountSelector() {
    final accountsData = context.read<AccountsData>();
    final accountOptions = accountsData.accountNames.map((account) => 
      SelectionOption(
        value: account,
        label: account,
        icon: LucideIcons.creditCard,
      )
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionModal(
        title: 'Select Account',
        options: accountOptions,
        selectedValue: _selectedAccount,
        onSelectionChanged: (value) {
          setState(() {
            _selectedAccount = value;
          });
        },
      ),
    );
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionModal(
        title: 'Select Category',
        options: _categoryOptions,
        selectedValue: _selectedCategory,
        onSelectionChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
      ),
    );
  }

  void _showFromAccountSelector() {
    final accountsData = context.read<AccountsData>();
    final accountOptions = accountsData.accountNames.map((account) => 
      SelectionOption(
        value: account,
        label: account,
        icon: LucideIcons.creditCard,
      )
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionModal(
        title: 'Select From Account',
        options: accountOptions,
        selectedValue: _selectedFromAccount,
        onSelectionChanged: (value) {
          setState(() {
            _selectedFromAccount = value;
          });
        },
      ),
    );
  }

  void _showToAccountSelector() {
    final accountsData = context.read<AccountsData>();
    final accountOptions = accountsData.accountNames.map((account) => 
      SelectionOption(
        value: account,
        label: account,
        icon: LucideIcons.creditCard,
      )
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionModal(
        title: 'Select To Account',
        options: accountOptions,
        selectedValue: _selectedToAccount,
        onSelectionChanged: (value) {
          setState(() {
            _selectedToAccount = value;
          });
        },
      ),
    );
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    // Get transaction type
    final transactionTypes = [TransactionType.income, TransactionType.expense, TransactionType.transfer];
    final type = transactionTypes[_selectedToggleIndex];

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

    // Show success message
    _showSnackBar('Transaction saved successfully!');

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

  void _saveTransactionAndShowSnackbar() {
    final amount = double.tryParse(_amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    // Get transaction type
    final transactionTypes = [TransactionType.income, TransactionType.expense, TransactionType.transfer];
    final type = transactionTypes[_selectedToggleIndex];

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

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction added!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

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

  Widget _buildSelectionField({
    required String label,
    required String? selectedValue,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 18),
            SizedBox(width: gap),
            Expanded(
              child: Text(
                selectedValue ?? label,
                style: TextStyle(
                  color: selectedValue != null ? Colors.black : Colors.grey[600],
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(LucideIcons.chevronDown, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = viewInsets > 0;

    Widget mainContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top App Bar Row: [Cancel] [Slider] [Save]
          SizedBox(
            height: 52.0,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    LucideIcons.x,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: ['INCOME', 'EXPENSE', 'TRANSFER'].asMap().entries.map((entry) {
                        final index = entry.key;
                        final label = entry.value;
                        final isSelected = index == _selectedToggleIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedToggleIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orange : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _saveTransactionAndShowSnackbar();
                  },
                  icon: const Icon(
                    LucideIcons.check,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap + 2),
          // Amount display
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '₹$_amountText',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(height: gap + 2),
          // Account and Category selectors side by side (for income/expense)
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _buildSelectionField(
                      label: _selectedToggleIndex == 2 ? 'From Account' : 'Select Account',
                      selectedValue: _selectedToggleIndex == 2 ? _selectedFromAccount : _selectedAccount,
                      onTap: _selectedToggleIndex == 2 ? _showFromAccountSelector : _showAccountSelector,
                      icon: LucideIcons.creditCard,
                    ),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _buildSelectionField(
                      label: _selectedToggleIndex == 2 ? 'To Account' : 'Select Category',
                      selectedValue: _selectedToggleIndex == 2 ? _selectedToAccount : _selectedCategory,
                      onTap: _selectedToggleIndex == 2 ? _showToAccountSelector : _showCategorySelector,
                      icon: _selectedToggleIndex == 2 ? LucideIcons.creditCard : LucideIcons.tag,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap + 2),
          // Date and Time pickers
          SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(LucideIcons.calendar, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _formatTime(_selectedTime),
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(LucideIcons.clock, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap + 2),
          // Notes field
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add notes...',
                  prefixIcon: const Icon(LucideIcons.fileText, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          SizedBox(height: gap + 2),
          // Keypad (fills remaining space)
          Expanded(
            flex: 3,
            child: CustomKeypad(
              onDigitPressed: _onDigitPressed,
              onBackspace: _onBackspacePressed,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      key: const PageStorageKey('add'),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: isKeyboardOpen
            ? SingleChildScrollView(child: mainContent)
            : mainContent,
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
} 