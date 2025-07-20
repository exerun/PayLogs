import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/accounts_data.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/custom_keypad.dart';
import '../widgets/selection_modal.dart';

const double gap = 14.0;
const double fieldHeight = 56.0;

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
  String? _selectedCategoryIcon; // Store the icon name for the selected category
  String? _selectedFromAccount;
  String? _selectedToAccount;
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  // Category options with Lucide icons
  final List<SelectionOption> _defaultCategoryOptions = [
    SelectionOption(value: 'Food', label: 'Food', icon: LucideIcons.utensils),
    SelectionOption(value: 'Transport', label: 'Transport', icon: LucideIcons.car),
    SelectionOption(value: 'Electronics', label: 'Electronics', icon: LucideIcons.smartphone),
    SelectionOption(value: 'Rent', label: 'Rent', icon: LucideIcons.home),
    SelectionOption(value: 'Shopping', label: 'Shopping', icon: LucideIcons.shoppingBag),
    SelectionOption(value: 'Entertainment', label: 'Entertainment', icon: LucideIcons.tv),
    SelectionOption(value: 'Health', label: 'Health', icon: LucideIcons.heart),
    SelectionOption(value: 'Education', label: 'Education', icon: LucideIcons.bookOpen),
    SelectionOption(value: 'Others', label: 'Others', icon: LucideIcons.moreHorizontal),
  ];
  List<SelectionOption> _customCategoryOptions = [];

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

  String _getIconName(IconData icon) {
    // Convert IconData to a string representation
    // This is a simple mapping for Lucide icons
    if (icon == LucideIcons.utensils) return 'utensils';
    if (icon == LucideIcons.car) return 'car';
    if (icon == LucideIcons.smartphone) return 'smartphone';
    if (icon == LucideIcons.home) return 'home';
    if (icon == LucideIcons.shoppingBag) return 'shoppingBag';
    if (icon == LucideIcons.tv) return 'tv';
    if (icon == LucideIcons.heart) return 'heart';
    if (icon == LucideIcons.bookOpen) return 'bookOpen';
    if (icon == LucideIcons.moreHorizontal) return 'moreHorizontal';
    if (icon == LucideIcons.star) return 'star';
    if (icon == LucideIcons.smile) return 'smile';
    if (icon == LucideIcons.sun) return 'sun';
    if (icon == LucideIcons.moon) return 'moon';
    if (icon == LucideIcons.book) return 'book';
    if (icon == LucideIcons.briefcase) return 'briefcase';
    if (icon == LucideIcons.camera) return 'camera';
    if (icon == LucideIcons.gift) return 'gift';
    if (icon == LucideIcons.music) return 'music';
    if (icon == LucideIcons.pizza) return 'pizza';
    if (icon == LucideIcons.shoppingCart) return 'shoppingCart';
    if (icon == LucideIcons.trophy) return 'trophy';
    if (icon == LucideIcons.zap) return 'zap';
    if (icon == LucideIcons.creditCard) return 'creditCard';
    if (icon == LucideIcons.tag) return 'tag';
    if (icon == LucideIcons.plusCircle) return 'plusCircle';
    return 'tag'; // default fallback
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

  void _showCategorySelector() async {
    // Compose the full list with custom categories
    final allOptions = [
      ..._defaultCategoryOptions,
      ..._customCategoryOptions,
      SelectionOption(
        value: '__add__',
        label: 'Add Category',
        icon: LucideIcons.plusCircle,
      ),
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionModal(
        title: 'Select Category',
        options: allOptions,
        selectedValue: _selectedCategory,
        onSelectionChanged: (value) async {
          if (value == '__add__') {
            final newCategory = await _showAddCategoryDialog();
            if (newCategory != null) {
              setState(() {
                _customCategoryOptions.add(newCategory);
                _selectedCategory = newCategory.value;
                _selectedCategoryIcon = _getIconName(newCategory.icon);
              });
              Navigator.of(context).pop();
            }
          } else {
            setState(() {
              _selectedCategory = value;
              // Find the icon for the selected category
              final allOptions = [..._defaultCategoryOptions, ..._customCategoryOptions];
              final selectedOption = allOptions.firstWhere(
                (option) => option.value == value,
                orElse: () => SelectionOption(value: value, label: value, icon: LucideIcons.tag),
              );
              _selectedCategoryIcon = _getIconName(selectedOption.icon);
            });
          }
        },
      ),
    );
  }

  Future<SelectionOption?> _showAddCategoryDialog() async {
    final TextEditingController nameController = TextEditingController();
    final List<IconData> iconChoices = [
      LucideIcons.star,
      LucideIcons.smile,
      LucideIcons.sun,
      LucideIcons.moon,
      LucideIcons.heart,
      LucideIcons.book,
      LucideIcons.briefcase,
      LucideIcons.camera,
      LucideIcons.gift,
      LucideIcons.music,
      LucideIcons.pizza,
      LucideIcons.shoppingCart,
      LucideIcons.trophy,
      LucideIcons.zap,
    ];
    IconData selectedIcon = (iconChoices..shuffle()).first;
    return await showDialog<SelectionOption>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: iconChoices.map((icon) {
                  return ChoiceChip(
                    label: Icon(icon, size: 22),
                    selected: selectedIcon == icon,
                    onSelected: (_) {
                      selectedIcon = icon;
                      (context as Element).markNeedsBuild();
                    },
                  );
                }).toList(),
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
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(
                    SelectionOption(
                      value: name,
                      label: name,
                      icon: selectedIcon,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
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

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    
    try {
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
        
        final accountsData = context.read<AccountsData>();
        final fromAcc = accountsData.accounts.firstWhere(
          (a) => a.name == _selectedFromAccount,
          orElse: () => throw Exception('From account not found'),
        );
        final toAcc = accountsData.accounts.firstWhere(
          (a) => a.name == _selectedToAccount,
          orElse: () => throw Exception('To account not found'),
        );
        
        transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          fromAccountId: fromAcc.id,
          toAccountId: toAcc.id,
          fromAccount: fromAcc.name,
          toAccount: toAcc.name,
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
        
        final accountsData = context.read<AccountsData>();
        final acc = accountsData.accounts.firstWhere(
          (a) => a.name == _selectedAccount,
          orElse: () => throw Exception('Account not found'),
        );
        
        transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          accountId: acc.id,
          account: acc.name,
          category: _selectedCategory,
          categoryIcon: _selectedCategoryIcon,
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
      await context.read<TransactionProvider>().addTransaction(transaction, context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        ),
      );

      // Reset form
      setState(() {
        _amountText = '0';
        _selectedAccount = null;
        _selectedCategory = null;
        _selectedCategoryIcon = null;
        _selectedFromAccount = null;
        _selectedToAccount = null;
        _notesController.clear();
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
      });

      // Auto-close Add Page and navigate to Home after a short delay for snackbar
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.7), size: 18),
            SizedBox(width: gap),
            Expanded(
              child: Text(
                selectedValue ?? label,
                style: TextStyle(
                  color: selectedValue != null 
                      ? theme.colorScheme.onSurface 
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(LucideIcons.chevronDown, color: theme.colorScheme.onSurface.withOpacity(0.7), size: 18),
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
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(
                    LucideIcons.x,
                    color: Color.fromRGBO(255, 51, 0, 1),
                    size: 22,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
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
                                color: isSelected ? const Color.fromRGBO(255, 51, 0, 1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white 
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
                  onPressed: _isSaving ? null : () async {
                    await _saveTransaction();
                  },
                  icon: const Icon(
                    LucideIcons.check,
                    color: Color.fromRGBO(255, 51, 0, 1),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap + 2),
          // Amount display
          SizedBox(
            height: fieldHeight,
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '₹$_amountText',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: gap + 2),
          // Account and Category selectors side by side (for income/expense)
          SizedBox(
            height: fieldHeight,
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
            height: fieldHeight,
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
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _formatDate(_selectedDate),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              LucideIcons.calendar, 
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), 
                              size: 20
                            ),
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
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _formatTime(_selectedTime),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              LucideIcons.clock, 
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), 
                              size: 20
                            ),
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
            height: fieldHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _notesController,
                focusNode: _notesFocusNode,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Add notes...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    LucideIcons.fileText, 
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onTap: () {
                  _notesFocusNode.requestFocus();
                },
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
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return false;
        },
        child: SafeArea(
          child: MediaQuery.removeViewInsets(
            context: context,
            removeBottom: false,
            child: isKeyboardOpen
                ? SingleChildScrollView(child: mainContent)
                : mainContent,
          ),
        ),
      ),
      // FAB removed
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }
} 