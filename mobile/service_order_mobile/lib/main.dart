import 'package:flutter/material.dart';

import 'pages/service_orders_page.dart';

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
