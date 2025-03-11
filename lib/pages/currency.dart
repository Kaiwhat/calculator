import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});

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
          return ListTile(
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
