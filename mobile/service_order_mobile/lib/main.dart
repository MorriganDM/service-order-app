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
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
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

  ServiceOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.customerName,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  factory ServiceOrder.fromJson(Map<String, dynamic> json) {
    return ServiceOrder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      customerName: json['customer_name'],
      status: json['status'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['created_at']),
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
        headers: {
          'Content-Type': 'application/json',
        },
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

  Future<void> updateServiceOrderStatus({
  required int id,
  required String status,
  }) async {
    final uri = Uri.parse('$baseUrl/service-orders/$id');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar status da ordem de serviço.');
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

  Future<void> openCreateOrderDialog() async {
  final wasCreated = await showDialog<bool>(
    context: context,
    builder: (context) {
      return CreateServiceOrderDialog(api: api);
    },
  );

  if (wasCreated == true) {
    reloadServiceOrders();
  }
}

Future<void> updateOrderStatus(ServiceOrder order, String status) async {
  try {
    await api.updateServiceOrderStatus(
      id: order.id,
      status: status,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status atualizado com sucesso.'),
      ),
    );

    reloadServiceOrders();
  } catch (error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao atualizar status: $error'),
      ),
    );
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
            return const Center(
              child: CircularProgressIndicator(),
            );
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

          if (serviceOrders.isEmpty) {
            return const Center(
              child: Text('Nenhuma ordem de serviço cadastrada.'),
            );
          }

          return RefreshIndicator(
            onRefresh: reloadServiceOrders,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: serviceOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = serviceOrders[index];

                return ServiceOrderCard(
                  order: order,
                  onStatusChanged: updateOrderStatus,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ServiceOrderCard extends StatelessWidget {
  final ServiceOrder order;
  final Future<void> Function(ServiceOrder order, String status) onStatusChanged;

  const ServiceOrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(order.description),
            const SizedBox(height: 12),
            Text(
              'Cliente: ${order.customerName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(status: order.status),
                PriorityChip(priority: order.priority),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (order.status == 'open')
                  OutlinedButton.icon(
                    onPressed: () async {
                      await onStatusChanged(order, 'in_progress');
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                  ),
                if (order.status == 'open' || order.status == 'in_progress')
                  FilledButton.icon(
                    onPressed: () async {
                      await onStatusChanged(order, 'done');
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Concluir'),
                  ),
                if (order.status != 'done' && order.status != 'cancelled')
                  TextButton.icon(
                    onPressed: () async {
                      await onStatusChanged(order, 'cancelled');
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'open' => 'Aberta',
      'in_progress' => 'Em andamento',
      'done' => 'Concluída',
      'cancelled' => 'Cancelada',
      _ => status,
    };

    return Chip(
      avatar: const Icon(Icons.assignment, size: 18),
      label: Text(label),
    );
  }
}

class PriorityChip extends StatelessWidget {
  final String priority;

  const PriorityChip({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (priority) {
      'low' => 'Baixa',
      'medium' => 'Média',
      'high' => 'Alta',
      _ => priority,
    };

    return Chip(
      avatar: const Icon(Icons.flag, size: 18),
      label: Text(label),
    );
  }
}

class CreateServiceOrderDialog extends StatefulWidget {
  final ServiceOrdersApi api;

  const CreateServiceOrderDialog({
    super.key,
    required this.api,
  });

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
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'low',
                      child: Text('Baixa'),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text('Média'),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Text('Alta'),
                    ),
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