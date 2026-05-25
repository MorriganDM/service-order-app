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

                return ServiceOrderCard(order: order);
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

  const ServiceOrderCard({
    super.key,
    required this.order,
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