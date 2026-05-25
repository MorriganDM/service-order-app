import 'package:flutter/material.dart';

import 'label_chip.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final String label;
    final IconData icon;
    final Color backgroundColor;
    final Color foregroundColor;

    switch (status) {
      case 'open':
        label = 'Aberta';
        icon = Icons.radio_button_unchecked;
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        break;
      case 'in_progress':
        label = 'Em andamento';
        icon = Icons.sync;
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        break;
      case 'done':
        label = 'Concluída';
        icon = Icons.check_circle_outline;
        backgroundColor = Colors.green.shade100;
        foregroundColor = Colors.green.shade900;
        break;
      case 'cancelled':
        label = 'Cancelada';
        icon = Icons.cancel_outlined;
        backgroundColor = Colors.red.shade100;
        foregroundColor = Colors.red.shade900;
        break;
      default:
        label = status;
        icon = Icons.help_outline;
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
