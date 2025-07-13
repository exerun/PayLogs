import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  
  // Minimum mobile screen size (iPhone SE dimensions)
  static const double minWidth = 375.0;
  static const double minHeight = 667.0;

  const ResponsiveLayout({
    super.key,
    required this.child,
  });

  @override
    Widget build(BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 375,
              minHeight: 667,
            ),
            child: Scaffold(
              body: SafeArea(
                child: child,
              ),
            ),
          );
        },
      );
    }

} 