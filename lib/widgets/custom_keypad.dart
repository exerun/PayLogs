import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String digit) onDigitPressed;
  final VoidCallback onBackspace;

  const CustomKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9F9F9),
      elevation: 6,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final buttonSpacing = 14.0;
            final buttonHeight = (constraints.maxHeight - buttonSpacing * 3) / 4;
            final buttonWidth = (constraints.maxWidth - buttonSpacing * 2) / 3;

            Widget buildKey(String digit) {
              return SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: Material(
                  color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    onTap: () => onDigitPressed(digit),
                    borderRadius: BorderRadius.circular(22),
                    child: Center(
                      child: Text(
                        digit,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'JetBrains Mono',
                          color: isDark ? Colors.white : const Color(0xFF444444),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            Widget buildBackspaceKey() {
              return SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: Material(
                  color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    onTap: onBackspace,
                    borderRadius: BorderRadius.circular(22),
                    child: Icon(
                      LucideIcons.delete,
                      size: 28,
                      color: isDark ? Colors.white : const Color(0xFF444444),
                    ),
                  ),
                ),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [buildKey('1'), buildKey('2'), buildKey('3')],
                ),
                SizedBox(height: buttonSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [buildKey('4'), buildKey('5'), buildKey('6')],
                ),
                SizedBox(height: buttonSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [buildKey('7'), buildKey('8'), buildKey('9')],
                ),
                SizedBox(height: buttonSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: buildKey('0'),
                    ),
                    SizedBox(width: buttonSpacing),
                    Expanded(
                      flex: 1,
                      child: buildBackspaceKey(),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 