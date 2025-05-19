import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:circle_flags/circle_flags.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  String searchQuery = '';
  // 搜尋字串
  Set<String> favoriteCurrencies = {};
  // 貨幣對應國旗的 Map
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
    'AFN': 'af',
    'ALL': 'al',
    'AMD': 'am',
    'AOA': 'ao',
    'AWG': 'aw',
    'AZN': 'az',
    'BAM': 'ba',
    'BBD': 'brb',
    'BDT': 'bd',
    'BGN': 'bg',
    'BHD': 'bh',
    'BIF': 'bi',
    'BMD': 'bmu',
    'BND': 'bn',
    'BOB': 'bo',
    'BSD': 'bs',
    'BTN': 'BT',
    'BWP': 'bw',
    'BYN': 'by',
    'BZD': 'bz',
    'CDF': 'cd',
    'CVE': 'cpv',
    'CRC': 'cr',
    'CUP': 'cu',
    'DJF': 'dj',
    'DOP': 'do',
    'DZD': 'dz',
    'ERN': 'eri',
    'ETB': 'et',
    'FJD': 'fj',
    'FKP': 'fk',
    'FOK': 'fro',
    'GEL': 'ge',
    'GHS': 'gh',
    'GNF': 'gn',
    'GTQ': 'gt',
    'GYD': 'gy',
    'HNL': 'hn',
    'HTG': 'ht',
    'IMP': 'gb',
    'IQD': 'iq',
    'IRR': 'ir',
    'JMD': 'jm',
    'JOD': 'jo',
    'KES': 'ke',
    'KGS': 'kg',
    'KHR': 'kh',
    'KMF': 'km',
    'KWD': 'kw',
    'KZT': 'kz',
    'LAK': 'la',
    'LBP': 'lb',
    'LKR': 'lk',
    'LRD': 'lr',
    'LSL': 'ls',
    'LYD': 'ly',
    'MAD': 'ma',
    'MDL': 'md',
    'MGA': 'mg',
    'MKD': 'mk',
    'MMK': 'mm',
    'MNT': 'mn',
    'MOP': 'mo',
    'MUR': 'mu',
    'MWK': 'mw',
    'MZN': 'mz',
    'NAD': 'na',
    'NGN': 'ng',
    'NPR': 'np',
    'OMR': 'om',
    'PAB': 'pa',
    'PEN': 'pe',
    'PGK': 'pg',
    'PKR': 'pk',
    'PYG': 'py',
    'QAR': 'qa',
    'RON': 'ro',
    'RSD': 'rs',
    'SCR': 'sc',
    'SDG': 'sd',
    'SOS': 'so',
    'SSP': 'ss',
    'SYP': 'sy',
    'TJS': 'TJK',
    'TZS': 'tz',
    'UAH': 'ua',
    'UGX': 'ug',
    'UYU': 'uy',
    'UZS': 'uz',
    'VES': 've',
    'XAF': 'cf',
    'XCD': 'ag',
    'XOF': 'sn',
    'XPF': 'pf',
    'YER': 'ye',
    'ZMW': 'zm',
  };

  @override
  void initState() {
    super.initState();
    _loadFavoriteCurrencies(); // 讀取儲存的常用貨幣
  }

  // 讀取本地存儲的常用貨幣
  Future<void> _loadFavoriteCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteCurrencies =
          prefs.getStringList('favoriteCurrencies')?.toSet() ?? {};
    });
  }

  // 更新本地存儲的常用貨幣
  Future<void> _saveFavoriteCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoriteCurrencies',
      favoriteCurrencies.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    List<String> currencies = currencyProvider.rates.keys.toList();

    // 依據搜尋篩選貨幣
    List<String> filteredCurrencies =
        currencies
            .where(
              (currency) =>
                  currency.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    // 讓常用貨幣置頂
    filteredCurrencies.sort((a, b) {
      if (favoriteCurrencies.contains(a) && !favoriteCurrencies.contains(b))
        return -1;
      if (!favoriteCurrencies.contains(a) && favoriteCurrencies.contains(b))
        return 1;
      return 0;
    });

    return Scaffold(
      appBar: AppBar(title: const Text("選擇幣種")),
      body: Column(
        children: [
          // 🔍 搜尋欄
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "搜尋貨幣...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 貨幣列表
          Expanded(
            child: ListView.builder(
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                String currency = filteredCurrencies[index];
                String countryCode = currencyToCountry[currency] ?? '';

                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 常用貨幣 Checkbox
                      IconButton(
                        icon: Icon(
                          favoriteCurrencies.contains(currency)
                              ? Icons
                                  .favorite // 選中的狀態
                              : Icons.favorite_border, // 未選中的狀態
                          color:
                              favoriteCurrencies.contains(currency)
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            if (favoriteCurrencies.contains(currency)) {
                              favoriteCurrencies.remove(currency);
                            } else {
                              favoriteCurrencies.add(currency);
                            }
                          });
                          _saveFavoriteCurrencies(); // 存儲變更
                        },
                      ),
                      CircleFlag(countryCode, size: 32), // 顯示國旗
                    ],
                  ),
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
          ),
        ],
      ),
    );
  }
}
