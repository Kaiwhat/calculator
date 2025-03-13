import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculator/pages/cal.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrencyProvider(),
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
  Map<String, double> rates = {
    'USD': 0.03,
    'KRW': 44.15,
    'RUB': 2.62,
    'EUR': 0.027,
    'JPY': 4.48,
    'CNY': 0.21,
  };

  String selectedCurrency = 'USD'; // 預設幣種

  void updateCurrency(String newCurrency) {
    selectedCurrency = newCurrency;
    notifyListeners(); // 通知 UI 更新
  }
}
