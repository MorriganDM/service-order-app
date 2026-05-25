import 'package:flutter/material.dart';

import '../models/service_order.dart';
import '../services/service_orders_api.dart';

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
