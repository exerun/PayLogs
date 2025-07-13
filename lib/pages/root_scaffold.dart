import 'package:flutter/material.dart';
import 'home_page.dart';
import 'manage_page.dart';
import 'add_page.dart';
import 'groups_page.dart';
import 'accounts_page.dart';
import 'screenshots_page.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  final _pages = [
    const HomePage(),
    const ManagePage(),
    GroupsPage(),
    const AccountsPage(),
    const ScreenshotsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Manage'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Groups'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Accounts'),
          NavigationDestination(icon: Icon(Icons.image), label: 'Screenshots'),
        ],
      ),
    );
  }
} 