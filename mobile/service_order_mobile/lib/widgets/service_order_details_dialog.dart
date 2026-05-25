import 'package:flutter/material.dart';

import '../models/service_order.dart';
import 'detail_row.dart';
import 'priority_chip.dart';
import 'status_chip.dart';

class ServiceOrderDetailsDialog extends StatelessWidget {
  final ServiceOrder order;

  const ServiceOrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text('Ordem #${order.id}')),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                order.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusChip(status: order.status),
                  PriorityChip(priority: order.priority),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 12),
              DetailRow(
                icon: Icons.business,
                label: 'Cliente',
                value: order.customerName,
              ),
              const SizedBox(height: 10),
              DetailRow(
                icon: Icons.schedule,
                label: 'Criada em',
                value: order.createdAtLabel,
              ),
              const SizedBox(height: 10),
              DetailRow(
                icon: Icons.update,
                label: 'Última edição',
                value: order.updatedAtLabel,
              ),
              const SizedBox(height: 10),
              DetailRow(
                icon: Icons.numbers,
                label: 'Identificador',
                value: '#${order.id}',
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
