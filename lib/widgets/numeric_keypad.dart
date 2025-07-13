import 'package:flutter/material.dart';
import 'dart:math';

class NumericKeypad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onBack;
  const NumericKeypad({super.key, required this.onTap, required this.onBack});

  @override
  Widget build(BuildContext context) {
    // 4 rows x 3 columns
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate key size based on available width/height
        final gridCols = 3;
        final gridRows = 4;
        final gap = 8.0;
        final totalGapWidth = gap * (gridCols - 1);
        final totalGapHeight = gap * (gridRows - 1);
        final keyWidth = (constraints.maxWidth - totalGapWidth) / gridCols;
        final keyHeight = (constraints.maxHeight - totalGapHeight) / gridRows;
        final keySize = min(keyWidth, keyHeight);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final buttonColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
        final textColor = isDark ? Colors.white : Colors.black;
        return Center(
          child: SizedBox(
            width: keyWidth * gridCols + totalGapWidth,
            height: keyHeight * gridRows + totalGapHeight,
            child: Column(
              children: [
                for (var row in keys)
                  Expanded(
                    child: Row(
                      children: [
                        for (var k in row)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: k != row.last ? gap : 0,
                                bottom: row != keys.last ? gap : 0,
                              ),
                              child: Material(
                                color: buttonColor,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () => k == '⌫' ? onBack() : onTap(k),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: k == '⌫'
                                          ? Icon(Icons.backspace_outlined, size: keySize * 0.6, color: textColor)
                                          : Text(
                                              k,
                                              style: TextStyle(
                                                fontFamily: 'JetBrainsMono',
                                                fontWeight: FontWeight.w600,
                                                fontSize: keySize * 0.45,
                                                color: textColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 