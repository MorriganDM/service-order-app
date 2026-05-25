import 'package:flutter/material.dart';

import '../models/service_order.dart';
import 'info_text.dart';
import 'priority_chip.dart';
import 'status_chip.dart';

class ServiceOrderCard extends StatelessWidget {
  final ServiceOrder order;
  final Future<void> Function(ServiceOrder order, String status)
  onStatusChanged;
  final Future<void> Function(ServiceOrder order) onDelete;
  final Future<void> Function(ServiceOrder order) onViewDetails;
  final Future<void> Function(ServiceOrder order) onEdit;

  const ServiceOrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
    required this.onDelete,
    required this.onViewDetails,
    required this.onEdit,
  });

  bool get canStart => order.status == 'open';

  bool get canFinish => order.status == 'in_progress';

  bool get canCancel => order.status == 'open' || order.status == 'in_progress';

  bool get canDelete => order.status == 'done' || order.status == 'cancelled';

  bool get canEdit => order.status == 'open' || order.status == 'in_progress';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    order.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '#${order.id}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final leftInfo = Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    InfoText(
                      icon: Icons.business,
                      label: 'Cliente',
                      value: order.customerName,
                    ),
                    InfoText(
                      icon: Icons.schedule,
                      label: 'Criada em',
                      value: order.createdAtLabel,
                    ),
                  ],
                );

                final rightInfo = InfoText(
                  icon: Icons.update,
                  label: 'Última edição',
                  value: order.updatedAtLabel,
                );

                if (constraints.maxWidth < 760) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [leftInfo, rightInfo],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: leftInfo),
                    const SizedBox(width: 12),
                    rightInfo,
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(status: order.status),
                PriorityChip(priority: order.priority),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await onViewDetails(order);
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Detalhes'),
                  ),
                  if (canEdit)
                    OutlinedButton.icon(
                      onPressed: () async {
                        await onEdit(order);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  if (canStart)
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await onStatusChanged(order, 'in_progress');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar'),
                    ),
                  if (canFinish)
                    FilledButton.icon(
                      onPressed: () async {
                        await onStatusChanged(order, 'done');
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Concluir'),
                    ),
                  if (canCancel)
                    TextButton.icon(
                      onPressed: () async {
                        await onStatusChanged(order, 'cancelled');
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
                    ),
                  if (canDelete)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                      onPressed: () async {
                        await onDelete(order);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Excluir'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
