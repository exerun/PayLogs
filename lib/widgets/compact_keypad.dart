import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onBack;
  const NumericKeypad({super.key, required this.onTap, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final keys = ['1','2','3','4','5','6','7','8','9','.','0','⌫'];
    return LayoutBuilder(
      builder: (ctx, constraints) {
        const gap = 6.0;
        final keyWidth = (constraints.maxWidth - gap * 2) / 3;
        final keyHeight = (constraints.maxHeight - gap * 3) / 4;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: keys.map((k) {
            final isBack = k == '⌫';
            return SizedBox(
              width: keyWidth,
              height: keyHeight,
              child: Material(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => isBack ? onBack() : onTap(k),
                  child: Center(
                    child: isBack
                        ? const Icon(Icons.backspace_outlined)
                        : Text(k, style: Theme.of(context).textTheme.titleLarge),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
} 