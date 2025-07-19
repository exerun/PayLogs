import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/accounts_data.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/custom_keypad.dart';

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
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  final List<String> _categories = [
    "Food",
    "Transport",
    "Electronics",
    "Rent",
    "Others"
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

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    // Validate fields
    if (_selectedAccount == null) {
      _showSnackBar('Please select an account');
      setState(() => _isSaving = false);
      return;
    }
    
    if (_selectedCategory == null) {
      _showSnackBar('Please select a category');
      setState(() => _isSaving = false);
      return;
    }
    
    final amount = double.tryParse(_amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      setState(() => _isSaving = false);
      return;
    }

    // Get transaction type
    final transactionTypes = ['INCOME', 'EXPENSE', 'TRANSFER'];
    final type = transactionTypes[_selectedToggleIndex].toLowerCase();

    // Create transaction
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.values.firstWhere((e) => e.name == type),
      account: _selectedAccount!,
      category: _selectedCategory!,
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

    // Add transaction to provider
    await context.read<TransactionProvider>().addTransaction(transaction);

    // Show success message
    _showSnackBar('Transaction saved successfully!');

    // Reset form
    setState(() {
      _amountText = '0';
      _selectedAccount = null;
      _selectedCategory = null;
      _notesController.clear();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
    setState(() => _isSaving = false);
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important!
    return Scaffold(
      key: const PageStorageKey('add'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            // TODO: Implement cancel functionality
          },
          icon: const Icon(
            Icons.close,
            color: Colors.orange,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : () async { await _saveTransaction(); },
            icon: const Icon(
              Icons.check,
              color: Colors.orange,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented control for INCOME | EXPENSE | TRANSFER
            Container(
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account and Category dropdowns
            Row(
              children: [
                Expanded(
                  child: Consumer<AccountsData>(
                    builder: (context, accountsData, child) {
                      return DropdownButtonFormField<String>(
                        value: _selectedAccount,
                        decoration: InputDecoration(
                          labelText: 'Select Account',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items: accountsData.accountNames.map((String account) {
                          return DropdownMenuItem<String>(
                            value: account,
                            child: Text(account),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedAccount = newValue;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notes text field
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Amount display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                '₹$_amountText',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Custom numeric keypad
            CustomKeypad(
              onDigitPressed: _onDigitPressed,
              onBackspace: _onBackspacePressed,
            ),
            
            const SizedBox(height: 24),
            
            // Date and Time pickers
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
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
          ],
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