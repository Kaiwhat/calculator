import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'input_page.dart';

class TripDetailPage extends StatefulWidget {
  final Map<String, dynamic> trip;
  final int tripIndex;

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
  late String country;
  late String destinationCurrency;
  double totalExpense = 0;
  double todayExpense = 0;

  @override
  void initState() {
    super.initState();
    trip = Map<String, dynamic>.from(widget.trip);
    country = trip['country'] ?? '';
    destinationCurrency = trip['destinationCurrency'] ?? '';
    calculateExpenses();
  }

  void calculateExpenses() {
    totalExpense = 0;
    todayExpense = 0;
    String today = DateTime.now().toIso8601String().split('T')[0];

    Map<String, dynamic> expenses = Map<String, dynamic>.from(
      trip['expenses'] ?? {},
    );
    expenses.forEach((date, list) {
      for (var e in List<Map<String, dynamic>>.from(list)) {
        totalExpense += e['amount'];
        if (date == today) todayExpense += e['amount'];
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

  void addExpense(String date, String label, String desc, double amount) {
    final expenses = Map<String, dynamic>.from(trip['expenses'] ?? {});
    if (!expenses.containsKey(date)) expenses[date] = [];
    expenses[date].add({'label': label, 'description': desc, 'amount': amount});
    trip['expenses'] = expenses;
    saveTrip();
    calculateExpenses();
  }

  @override
  Widget build(BuildContext context) {
    double budget = trip['budget'] ?? 0;
    double progress = budget == 0 ? 0 : (totalExpense / budget).clamp(0.0, 1.0);
    final expenses = Map<String, dynamic>.from(trip['expenses'] ?? {});
    final sortedDates = expenses.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text(country.isNotEmpty ? country : "旅遊記帳")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("預算進度", style: TextStyle(fontSize: 18)),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text("今日支出"),
                          Text("$todayExpense $destinationCurrency"),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text("總支出"),
                          Text("$totalExpense $destinationCurrency"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.add_circle),
              label: Text("新增消費"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => InputPage(
                          onSubmit: (date, label, desc, amount) {
                            addExpense(date, label, desc, amount);
                          },
                        ),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child:
                  expenses.isEmpty
                      ? Center(child: Text("尚無支出"))
                      : ListView.builder(
                        itemCount: sortedDates.length,
                        itemBuilder: (context, index) {
                          String date = sortedDates[index];
                          List list = expenses[date];
                          return Card(
                            child: ExpansionTile(
                              title: Text(date),
                              initiallyExpanded: index == 0,
                              children: [
                                ...list
                                    .map(
                                      (e) => ListTile(
                                        title: Text(
                                          "${e['label']} - ${e['description'] ?? ''}",
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "${e['amount']}",
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  list.remove(e);
                                                  if (list.isEmpty) {
                                                    trip['expenses'].remove(
                                                      date,
                                                    );
                                                  }
                                                  saveTrip();
                                                  calculateExpenses();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                                TextButton.icon(
                                  icon: Icon(Icons.add),
                                  label: Text("新增消費"),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => InputPage(
                                              onSubmit: (
                                                date,
                                                label,
                                                desc,
                                                amount,
                                              ) {
                                                addExpense(
                                                  date,
                                                  label,
                                                  desc,
                                                  amount,
                                                );
                                              },
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            ElevatedButton(
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text("確認刪除"),
                        content: Text("確定要刪除這個行程嗎？"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("取消"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("刪除"),
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
                    trips.removeAt(widget.tripIndex);
                    await prefs.setString('trips', json.encode(trips));
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("刪除此行程"),
            ),
          ],
        ),
      ),
    );
  }
}
