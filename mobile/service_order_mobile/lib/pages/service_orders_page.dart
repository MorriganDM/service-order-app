import 'package:flutter/material.dart';

import '../models/service_order.dart';
import '../services/service_orders_api.dart';
import '../widgets/create_service_order_dialog.dart';
import '../widgets/edit_service_order_dialog.dart';
import '../widgets/service_order_card.dart';
import '../widgets/service_order_details_dialog.dart';

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
