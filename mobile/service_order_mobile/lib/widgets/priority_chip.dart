import 'package:flutter/material.dart';

import 'label_chip.dart';

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final String label;
    final IconData icon;
    final Color backgroundColor;
    final Color foregroundColor;

    switch (priority) {
      case 'low':
        label = 'Baixa';
        icon = Icons.keyboard_arrow_down;
        backgroundColor = colorScheme.surfaceContainerHighest;
        foregroundColor = colorScheme.onSurfaceVariant;
        break;
      case 'medium':
        label = 'Média';
        icon = Icons.flag_outlined;
        backgroundColor = Colors.amber.shade100;
        foregroundColor = Colors.amber.shade900;
        break;
      case 'high':
        label = 'Alta';
        icon = Icons.priority_high;
        backgroundColor = Colors.deepOrange.shade100;
        foregroundColor = Colors.deepOrange.shade900;
        break;
      default:
        label = priority;
        icon = Icons.flag_outlined;
        backgroundColor = colorScheme.surfaceContainerHighest;
        foregroundColor = colorScheme.onSurfaceVariant;
    }

    return LabelChip(
      icon: icon,
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}
