import 'package:flutter/material.dart';
import '../widgets/analysis_section.dart';
import '../widgets/budget_section.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedIndex = 0;
  final List<String> _tabs = ['Analysis', 'Budget'];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: ToggleButtons(
              isSelected: List.generate(_tabs.length, (i) => i == _selectedIndex),
              onPressed: (index) {
                setState(() => _selectedIndex = index);
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: Colors.indigo,
              color: Colors.indigo,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
              children: _tabs.map((tab) => Text(tab)).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                AnalysisSection(),
                BudgetSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 