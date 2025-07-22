import 'package:flutter/material.dart';

class WildcardButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const WildcardButton({super.key, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.blue : Colors.grey,
        minimumSize: const Size(60, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: const Text('50-50'),
    );
  }
}
