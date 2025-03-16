import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:circle_flags/circle_flags.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});

  // 貨幣代碼對應國家旗幟（ISO 3166-1 alpha-2 國家代碼）
  static final Map<String, String> currencyToCountry = {
    'USD': 'us',
    'KRW': 'kr',
    'RUB': 'ru',
    'EUR': 'eu',
    'JPY': 'jp',
    'CNY': 'cn',
    'TWD': 'tw',
    'GBP': 'gb',
    'AUD': 'au',
    'CAD': 'ca',
    'CHF': 'ch',
    'SGD': 'sg',
    'HKD': 'hk',
    'NZD': 'nz',
    'INR': 'in',
    'THB': 'th',
    'MYR': 'my',
    'PHP': 'ph',
    'IDR': 'id',
    'VND': 'vn',
    'BRL': 'br',
    'MXN': 'mx',
    'ZAR': 'za',
    'SEK': 'se',
    'NOK': 'no',
    'DKK': 'dk',
    'PLN': 'pl',
    'TRY': 'tr',
    'HUF': 'hu',
    'CZK': 'cz',
    'ILS': 'il',
    'AED': 'ae',
    'SAR': 'sa',
    'EGP': 'eg',
    'CLP': 'cl',
    'COP': 'co',
    'ARS': 'ar',
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
          String countryCode = currencyToCountry[currency] ?? ''; // 預設 US

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
