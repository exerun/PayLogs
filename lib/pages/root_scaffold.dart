import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'home_page.dart';
import 'manage_page.dart';
import 'accounts_page.dart';
import 'screenshots_page.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Under Construction',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    ManagePage(),
    GroupsPage(),
    AccountsPage(),
    ScreenshotsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withOpacity(theme.brightness == Brightness.dark ? 0.92 : 0.98),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.amber.withOpacity(0.18)
                    : Colors.amber.withOpacity(0.22),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < 5; i++)
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: _currentIndex == i
                            ? BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.amber[700]?.withOpacity(0.18)
                                    : Colors.amber[200]?.withOpacity(0.38),
                                borderRadius: BorderRadius.circular(50),
                              )
                            : null,
                        child: Icon(
                          [
                            LucideIcons.home,
                            LucideIcons.settings,
                            LucideIcons.users,
                            LucideIcons.wallet,
                            LucideIcons.image,
                          ][i],
                          color: _currentIndex == i
                              ? (theme.brightness == Brightness.dark
                                  ? Colors.amber[200]
                                  : Colors.amber[800])
                              : theme.iconTheme.color,
                          size: 26,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 