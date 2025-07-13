                                        import 'package:flutter/material.dart';

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
    return Column(
      children: [
        // First row: 1, 2, 3
        Row(
          children: [
            Expanded(child: _buildKey('1')),
            const SizedBox(width: 8),
            Expanded(child: _buildKey('2')),
            const SizedBox(width: 8),
            Expanded(child: _buildKey('3')),
          ],
        ),
        const SizedBox(height: 8),
        
        // Second row: 4, 5, 6
        Row(
          children: [
            Expanded(child: _buildKey('4')),
            const SizedBox(width: 8),
            Expanded(child: _buildKey('5')),
            const SizedBox(width: 8),
            Expanded(child: _buildKey('6')),
          ],
        ),
        const SizedBox(height: 8),
        
        // Third row: 7, 8, 9
        Row(
          children: [
            Expanded(child: _buildKey('7')),
            const SizedBox(width: 8),
            Expanded(child: _buildKey('8')),
            const SizedBox(width: 8),
            Expanded(child: _buildKey('9')),
          ],
        ),
        const SizedBox(height: 8),
        
        // Fourth row: 0, backspace
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildKey('0'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBackspaceKey(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String digit) {
    return SizedBox(
      height: 55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDigitPressed(digit),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // Pale yellow
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                digit,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return SizedBox(
      height: 55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onBackspace,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // Pale yellow
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Icon(
                Icons.backspace,
                size: 24,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 