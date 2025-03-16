import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculator/pages/cal.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrencyProvider()..fetchExchangeRates(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CalculatorApplication(),
    );
  }
}

// 負責存取匯率的 Provider
class CurrencyProvider extends ChangeNotifier {
  Map<String, double> rates = {};
  Future<void> fetchExchangeRates() async {
    final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/TWD');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        rates = data['rates'].map<String, double>(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        );
        notifyListeners(); // 更新 UI
      }
    } catch (e) {
      print("API 請求失敗: $e");
    }
  }

  String selectedCurrency = 'USD'; // 預設幣種

  void updateCurrency(String newCurrency) {
    selectedCurrency = newCurrency;
    notifyListeners(); // 通知 UI 更新
  }
}
