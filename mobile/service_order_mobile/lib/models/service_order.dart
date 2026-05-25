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
