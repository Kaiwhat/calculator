import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:calculator/pages/trip_detail_page.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  final TextEditingController countryController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  String? userCurrency;
  String? destinationCurrency;
  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    loadTrips();
  }

  Future<void> loadTrips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tripsJson = prefs.getString('trips');
    if (tripsJson != null) {
      setState(() {
        trips = List<Map<String, dynamic>>.from(json.decode(tripsJson));
      });
    }
  }

  Future<void> saveTrips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('trips', json.encode(trips));
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void addTrip() {
    if (countryController.text.isEmpty ||
        startDate == null ||
        endDate == null ||
        budgetController.text.isEmpty ||
        userCurrency == null ||
        destinationCurrency == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請完整填寫所有資訊')));
      return;
    }

    Map<String, dynamic> newTrip = {
      'country': countryController.text,
      'startDate': startDate!.toIso8601String(),
      'endDate': endDate!.toIso8601String(),
      'budget': double.tryParse(budgetController.text) ?? 0,
      'userCurrency': userCurrency,
      'destinationCurrency': destinationCurrency,
      'expenses': {}, // 🔥 新增 expenses 欄位，初始為空
    };

    setState(() {
      trips.add(newTrip);
      countryController.clear();
      budgetController.clear();
      userCurrency = null;
      destinationCurrency = null;
      startDate = null;
      endDate = null;
    });

    saveTrips();
  }

  void cancelInput() {
    setState(() {
      countryController.clear();
      budgetController.clear();
      userCurrency = null;
      destinationCurrency = null;
      startDate = null;
      endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('旅遊記帳本')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 建立旅遊行程表單
            const Text(
              "新增行程",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: '旅行國家',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickDate(context, true),
                    child: Text(
                      startDate == null
                          ? '選擇開始日期'
                          : '開始: ${startDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickDate(context, false),
                    child: Text(
                      endDate == null
                          ? '選擇結束日期'
                          : '結束: ${endDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '預算',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: userCurrency,
              decoration: const InputDecoration(labelText: '使用者幣種'),
              items:
                  ['TWD', 'USD', 'JPY', 'EUR', 'KRW', 'CNY'].map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  userCurrency = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: destinationCurrency,
              decoration: const InputDecoration(labelText: '目的地幣種'),
              items:
                  ['TWD', 'USD', 'JPY', 'EUR', 'KRW', 'CNY'].map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  destinationCurrency = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: addTrip,
                    child: const Text('建立'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: cancelInput,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('取消'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 已建立的行程列表
            const Text(
              "已建立行程",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                var trip = trips[index];
                return Card(
                  child: ListTile(
                    title: Text("${trip['country']} 旅行"),
                    subtitle: Text(
                      "${trip['startDate'].toString().split('T')[0]} ➔ ${trip['endDate'].toString().split('T')[0]}\n預算: ${trip['budget']} ${trip['userCurrency']}",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  TripDetailPage(trip: trip, tripIndex: index),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
