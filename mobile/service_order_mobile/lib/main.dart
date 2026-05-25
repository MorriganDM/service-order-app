import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ServiceOrdersApp());
}

class ServiceOrdersApp extends StatelessWidget {
  const ServiceOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Orders',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ServiceOrdersPage(),
    );
  }
}

class ServiceOrder {
  final int id;
  final String title;
  final String description;
  final String customerName;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServiceOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.customerName,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  String get createdAtLabel {
    return formatDate(createdAt);
  }

  String get updatedAtLabel {
    if (updatedAt == null) {
      return '—';
    }

    return formatDate(updatedAt!);
  }

  static String formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  factory ServiceOrder.fromJson(Map<String, dynamic> json) {
    return ServiceOrder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      customerName: json['customer_name'],
      status: json['status'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at']),
    );
  }
}

class ServiceOrdersApi {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<ServiceOrder>> getServiceOrders() async {
    final uri = Uri.parse('$baseUrl/service-orders');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar ordens de serviço.');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => ServiceOrder.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createServiceOrder({
    required String title,
    required String description,
    required String customerName,
    required String priority,
  }) async {
    final uri = Uri.parse('$baseUrl/service-orders');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'customer_name': customerName,
        'status': 'open',
        'priority': priority,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar ordem de serviço.');
    }
  }

  Future<void> updateServiceOrder({
    required int id,
    required String title,
    required String description,
    required String customerName,
    required String priority,
  }) async {
    final uri = Uri.parse('$baseUrl/service-orders/$id');

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'customer_name': customerName,
        'priority': priority,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar ordem de serviço.');
    }
  }

  Future<void> updateServiceOrderStatus({
    required int id,
    required String status,
  }) async {
    final uri = Uri.parse('$baseUrl/service-orders/$id');

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar status da ordem de serviço.');
    }
  }

  Future<void> deleteServiceOrder({required int id}) async {
    final uri = Uri.parse('$baseUrl/service-orders/$id');

    final response = await http.delete(uri);

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir ordem de serviço.');
    }
  }
}

class ServiceOrdersPage extends StatefulWidget {
  const ServiceOrdersPage({super.key});

  @override
  State<ServiceOrdersPage> createState() => _ServiceOrdersPageState();
}

class _ServiceOrdersPageState extends State<ServiceOrdersPage> {
  final ServiceOrdersApi api = ServiceOrdersApi();

  late Future<List<ServiceOrder>> serviceOrdersFuture;

  String selectedStatusFilter = 'all';

  static const Map<String, String> statusFilterLabels = {
    'all': 'Todas',
    'open': 'Abertas',
    'in_progress': 'Em andamento',
    'done': 'Concluídas',
    'cancelled': 'Canceladas',
  };

  @override
  void initState() {
    super.initState();
    serviceOrdersFuture = api.getServiceOrders();
  }

  Future<void> reloadServiceOrders() async {
    setState(() {
      serviceOrdersFuture = api.getServiceOrders();
    });

    await serviceOrdersFuture;
  }

  List<ServiceOrder> filterServiceOrders(List<ServiceOrder> orders) {
    if (selectedStatusFilter == 'all') {
      return orders;
    }

    return orders
        .where((order) => order.status == selectedStatusFilter)
        .toList();
  }

  Widget buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statusFilterLabels.entries.map((entry) {
          final status = entry.key;
          final label = entry.value;
          final isSelected = selectedStatusFilter == status;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedStatusFilter = status;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> openCreateOrderDialog() async {
    final wasCreated = await showDialog<bool>(
      context: context,
      builder: (context) {
        return CreateServiceOrderDialog(api: api);
      },
    );

    if (wasCreated == true) {
      await reloadServiceOrders();
    }
  }

  Future<void> openOrderDetails(ServiceOrder order) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return ServiceOrderDetailsDialog(order: order);
      },
    );
  }

  Future<void> openEditOrderDialog(ServiceOrder order) async {
    final wasUpdated = await showDialog<bool>(
      context: context,
      builder: (context) {
        return EditServiceOrderDialog(api: api, order: order);
      },
    );

    if (wasUpdated == true) {
      await reloadServiceOrders();
    }
  }

  Future<void> updateOrderStatus(ServiceOrder order, String status) async {
    try {
      await api.updateServiceOrderStatus(id: order.id, status: status);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status atualizado com sucesso.')),
      );

      await reloadServiceOrders();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $error')),
      );
    }
  }

  Future<void> deleteOrder(ServiceOrder order) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir ordem de serviço?'),
          content: Text(
            'Tem certeza que deseja excluir a ordem "${order.title}"?\n\n'
            'Essa ação não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete),
              label: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await api.deleteServiceOrder(id: order.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ordem excluída com sucesso.')),
      );

      await reloadServiceOrders();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir ordem: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(
            onPressed: reloadServiceOrders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openCreateOrderDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova ordem'),
      ),
      body: FutureBuilder<List<ServiceOrder>>(
        future: serviceOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar as ordens.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final serviceOrders = snapshot.data ?? [];
          final filteredServiceOrders = filterServiceOrders(serviceOrders);

          final emptyMessage = serviceOrders.isEmpty
              ? 'Nenhuma ordem de serviço cadastrada.'
              : 'Nenhuma ordem encontrada para este filtro.';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: buildStatusFilters(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredServiceOrders.isEmpty
                    ? Center(child: Text(emptyMessage))
                    : RefreshIndicator(
                        onRefresh: reloadServiceOrders,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredServiceOrders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = filteredServiceOrders[index];

                            return ServiceOrderCard(
                              order: order,
                              onStatusChanged: updateOrderStatus,
                              onDelete: deleteOrder,
                              onViewDetails: openOrderDetails,
                              onEdit: openEditOrderDialog,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
                    _InfoText(
                      icon: Icons.business,
                      label: 'Cliente',
                      value: order.customerName,
                    ),
                    _InfoText(
                      icon: Icons.schedule,
                      label: 'Criada em',
                      value: order.createdAtLabel,
                    ),
                  ],
                );

                final rightInfo = _InfoText(
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

class _InfoText extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoText({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

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
              _DetailRow(
                icon: Icons.business,
                label: 'Cliente',
                value: order.customerName,
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.schedule,
                label: 'Criada em',
                value: order.createdAtLabel,
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.update,
                label: 'Última edição',
                value: order.updatedAtLabel,
              ),
              const SizedBox(height: 10),
              _DetailRow(
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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

    return _LabelChip(
      icon: icon,
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

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

    return _LabelChip(
      icon: icon,
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class _LabelChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _LabelChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class CreateServiceOrderDialog extends StatefulWidget {
  final ServiceOrdersApi api;

  const CreateServiceOrderDialog({super.key, required this.api});

  @override
  State<CreateServiceOrderDialog> createState() =>
      _CreateServiceOrderDialogState();
}

class _CreateServiceOrderDialogState extends State<CreateServiceOrderDialog> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final customerNameController = TextEditingController();

  String priority = 'medium';
  bool isSaving = false;
  String? errorMessage;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    customerNameController.dispose();

    super.dispose();
  }

  Future<void> saveServiceOrder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      await widget.api.createServiceOrder(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        customerName: customerNameController.text.trim(),
        priority: priority,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova ordem de serviço'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Informe um título com pelo menos 3 caracteres.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Informe o nome do cliente.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Informe uma descrição com pelo menos 5 caracteres.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Baixa')),
                    DropdownMenuItem(value: 'medium', child: Text('Média')),
                    DropdownMenuItem(value: 'high', child: Text('Alta')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        priority = value;
                      });
                    }
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: isSaving ? null : saveServiceOrder,
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}

class EditServiceOrderDialog extends StatefulWidget {
  final ServiceOrdersApi api;
  final ServiceOrder order;

  const EditServiceOrderDialog({
    super.key,
    required this.api,
    required this.order,
  });

  @override
  State<EditServiceOrderDialog> createState() => _EditServiceOrderDialogState();
}

class _EditServiceOrderDialogState extends State<EditServiceOrderDialog> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController customerNameController;

  late String priority;

  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.order.title);
    descriptionController = TextEditingController(
      text: widget.order.description,
    );
    customerNameController = TextEditingController(
      text: widget.order.customerName,
    );

    priority = widget.order.priority;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    customerNameController.dispose();

    super.dispose();
  }

  Future<void> saveServiceOrder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      await widget.api.updateServiceOrder(
        id: widget.order.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        customerName: customerNameController.text.trim(),
        priority: priority,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ordem #${widget.order.id}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Informe um título com pelo menos 3 caracteres.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Informe o nome do cliente.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Informe uma descrição com pelo menos 5 caracteres.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Baixa')),
                    DropdownMenuItem(value: 'medium', child: Text('Média')),
                    DropdownMenuItem(value: 'high', child: Text('Alta')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        priority = value;
                      });
                    }
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: isSaving ? null : saveServiceOrder,
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: const Text('Salvar alterações'),
        ),
      ],
    );
  }
}
