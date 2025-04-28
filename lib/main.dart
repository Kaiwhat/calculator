import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculator/pages/cal.dart';
import 'package:calculator/pages/trip_page.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainPage());
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

// 主畫面帶 BottomNavigationBar
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // 定義四個分頁
  final List<Widget> _pages = [
    CalculatorApplication(), // 計算機 (cal.dart, currency.dart)
    TripPage(), // 記帳本 Placeholder
    PlaceholderPage(title: "歷史檔案"), // 歷史檔案 Placeholder
    PlaceholderPage(title: "設定"), // 設定 Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x00000000),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 超過三個 item 要加這行
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: '計算機'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '記帳本'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '歷史檔案'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}

// 簡單的 Placeholder 頁面
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text("$title 頁面尚未完成", style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
