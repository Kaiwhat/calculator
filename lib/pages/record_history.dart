import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordHistoryPage extends StatefulWidget {
  const RecordHistoryPage({super.key});

  @override
  State<RecordHistoryPage> createState() => _RecordHistoryPageState();
}

class _RecordHistoryPageState extends State<RecordHistoryPage> {
  List<Record> records = [];

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('records') ?? [];
    setState(() {
      records = saved.map((e) => Record.fromJson(jsonDecode(e))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('記帳紀錄')),
      body:
          records.isEmpty
              ? Center(child: Text('尚無記錄'))
              : ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final r = records[index];
                  return ListTile(
                    leading: Icon(
                      r.income ? Icons.arrow_downward : Icons.arrow_upward,
                      color: r.income ? Colors.green : Colors.red,
                    ),
                    title: Text('${r.mainCategory} > ${r.subCategory}'),
                    subtitle: Text(
                      '金額: \$${r.amount.toStringAsFixed(2)} | ${r.cash ? '現金' : '刷卡'}',
                    ),
                    trailing: Text(
                      r.time.toLocal().toString().split(".")[0],
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
    );
  }
}

class Record {
  final String mainCategory;
  final String subCategory;
  final double amount;
  final bool income;
  final bool cash;
  final DateTime time;

  Record({
    required this.mainCategory,
    required this.subCategory,
    required this.amount,
    required this.income,
    required this.cash,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'mainCategory': mainCategory,
    'subCategory': subCategory,
    'amount': amount,
    'income': income,
    'cash': cash,
    'time': time.toIso8601String(),
  };

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    mainCategory: json['mainCategory'],
    subCategory: json['subCategory'],
    amount: json['amount'],
    income: json['income'],
    cash: json['cash'],
    time: DateTime.parse(json['time']),
  );
}
