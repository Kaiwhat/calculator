import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TripDetailPage extends StatefulWidget {
  final Map<String, dynamic> trip;
  final int tripIndex; // 用來回存 SharedPreferences

  const TripDetailPage({
    super.key,
    required this.trip,
    required this.tripIndex,
  });

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late Map<String, dynamic> trip;
  double totalExpense = 0;
  double todayExpense = 0;

  @override
  void initState() {
    super.initState();
    trip = Map<String, dynamic>.from(widget.trip);
    calculateExpenses();
  }

  void calculateExpenses() {
    totalExpense = 0;
    todayExpense = 0;
    String today = DateTime.now().toString().split(' ')[0];

    Map<String, dynamic> expenses = Map<String, dynamic>.from(
      trip['expenses'] ?? {},
    );

    expenses.forEach((date, expenseList) {
      for (var e in List<Map<String, dynamic>>.from(expenseList)) {
        totalExpense += e['amount'];
        if (date == today) {
          todayExpense += e['amount'];
        }
      }
    });
    setState(() {});
  }

  Future<void> saveTrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tripsJson = prefs.getString('trips');
    if (tripsJson != null) {
      List trips = json.decode(tripsJson);
      trips[widget.tripIndex] = trip;
      await prefs.setString('trips', json.encode(trips));
    }
  }

  void addExpense(
    String date,
    String label,
    String description,
    double amount,
  ) {
    Map<String, dynamic> expenses = Map<String, dynamic>.from(
      trip['expenses'] ?? {},
    );

    if (!expenses.containsKey(date)) {
      expenses[date] = [];
    }
    expenses[date].add({
      'label': label,
      'description': description,
      'amount': amount,
    });

    trip['expenses'] = expenses;
    saveTrip();
    calculateExpenses();
  }

  void showAddExpenseDialog(String date) {
    final labelController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$date 新增消費'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: '標籤 (飲食/交通/住宿等)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '簡單描述'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '金額 (目的地幣種)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (labelController.text.isNotEmpty &&
                      amountController.text.isNotEmpty) {
                    addExpense(
                      date,
                      labelController.text,
                      descriptionController.text,
                      double.tryParse(amountController.text) ?? 0,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('新增'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double budget = trip['budget'] ?? 0;
    double progress =
        (budget == 0) ? 0 : (totalExpense / budget).clamp(0.0, 1.0);

    Map<String, dynamic> expenses = Map<String, dynamic>.from(
      trip['expenses'] ?? {},
    );

    List<String> sortedDates = expenses.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text(trip['country'] ?? "旅遊記帳本")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 預算進度條
            const Text("預算使用進度", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            const SizedBox(height: 16),

            // 今日支出 + 總支出
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("今日支出"),
                          const SizedBox(height: 8),
                          Text(
                            "${todayExpense.toStringAsFixed(2)} ${trip['destinationCurrency']}",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("總支出"),
                          const SizedBox(height: 8),
                          Text(
                            "${totalExpense.toStringAsFixed(2)} ${trip['destinationCurrency']}",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 每日記帳
            const Text("每日記帳", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            expenses.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "還沒有任何消費，快來新增吧！",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    String date = sortedDates[index];
                    List<dynamic> expensesForDay = expenses[date] ?? [];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ExpansionTile(
                        title: Text(date),
                        children: [
                          // 判斷今天有沒有支出
                          if (expensesForDay.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text("這天還沒有任何消費"),
                            )
                          else
                            ...expensesForDay.map<Widget>((expense) {
                              return ListTile(
                                title: Text(
                                  "${expense['label']} - ${expense['description']}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      expensesForDay.remove(expense); // 移除該筆支出
                                      if (expensesForDay.isEmpty) {
                                        trip['expenses'].remove(
                                          date,
                                        ); // 該日無支出，刪除日期
                                      }
                                      saveTrip();
                                      calculateExpenses();
                                    });
                                  },
                                ),
                              );
                            }).toList(),

                          // 新增消費按鈕
                          TextButton.icon(
                            onPressed: () {
                              showAddExpenseDialog(date);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("新增消費"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('確認刪除'),
                        content: const Text('確定要刪除這個旅遊行程嗎？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('取消'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('刪除'),
                          ),
                        ],
                      ),
                );

                if (confirm) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? tripsJson = prefs.getString('trips');
                  if (tripsJson != null) {
                    List trips = json.decode(tripsJson);
                    trips.removeAt(widget.tripIndex); // 🔥 刪除該行程
                    await prefs.setString('trips', json.encode(trips));
                  }
                  if (context.mounted) {
                    Navigator.pop(context); // 返回行程列表
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('刪除此行程'),
            ),
          ],
        ),
      ),
    );
  }
}
