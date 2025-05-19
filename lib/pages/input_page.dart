import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  final String? initialDate;
  final void Function(
    String selectedDate,
    String label,
    String desc,
    double amount,
  )
  onSubmit;

  const InputPage({super.key, this.initialDate, required this.onSubmit});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final labelController = TextEditingController();
  final descController = TextEditingController();
  final amountController = TextEditingController();
  late String selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate =
        widget.initialDate ?? DateTime.now().toIso8601String().split('T')[0];
  }

  @override
  void dispose() {
    labelController.dispose();
    descController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final label = labelController.text.trim();
      final desc = descController.text.trim();
      final amount = double.tryParse(amountController.text.trim()) ?? 0;
      widget.onSubmit(selectedDate, label, desc, amount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("新增消費")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  const Text('日期：', style: TextStyle(fontSize: 16)),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(selectedDate),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(selectedDate),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked.toIso8601String().split('T')[0];
                        });
                      }
                    },
                  ),
                ],
              ),

              TextFormField(
                controller: labelController,
                decoration: const InputDecoration(labelText: '標籤'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty ? '請輸入標籤' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: '描述'),
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: '金額'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  return (amount == null || amount <= 0) ? '請輸入正確金額' : null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: handleSubmit,
                icon: const Icon(Icons.check),
                label: const Text('確認新增'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
