import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:circle_flags/circle_flags.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});

  // 貨幣代碼對應國家旗幟（ISO 3166-1 alpha-2 國家代碼）
  static final Map<String, String> currencyToCountry = {
    'USD': 'us', // 美國
    'KRW': 'kr', // 韓國
    'RUB': 'ru', // 俄羅斯
    'EUR': 'eu', // 歐盟
    'JPY': 'jp', // 日本
    'CNY': 'cn', // 中國
    'TWD': 'tw', // 台灣
  };

  @override
  Widget build(BuildContext context) {
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    List<String> currencies = currencyProvider.rates.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("選擇幣種")),
      body: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          String currency = currencies[index];
          String countryCode = currencyToCountry[currency] ?? 'us'; // 預設 US

          return ListTile(
            leading: CircleFlag(countryCode, size: 32), // 顯示國旗
            title: Text(currency),
            trailing:
                currencyProvider.selectedCurrency == currency
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
            onTap: () {
              currencyProvider.updateCurrency(currency);
              Navigator.pop(context); // 回到計算機頁面
            },
          );
        },
      ),
    );
  }
}
