import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/service_order.dart';

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
