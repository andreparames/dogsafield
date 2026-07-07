import 'package:flutter/material.dart';

class FoundingPackBadge extends StatelessWidget {
  const FoundingPackBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 16, color: Colors.amber.shade800),
          const SizedBox(width: 4),
          Text(
            'Founding Pack',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.amber.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
