import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart';
import 'currency.dart';

class CalculatorApplication extends StatefulWidget {
  const CalculatorApplication({super.key});

  @override
  State<CalculatorApplication> createState() => _CalculatorApplicationState();
}

class Record {
  final String mainCategory;
  final String subCategory;
  final double amount;
  final bool income; // true = 收入
  final bool cash; // true = 現金
  final DateTime time;

  Record({
    required this.mainCategory,
    required this.subCategory,
    required this.amount,
    required this.income,
    required this.cash,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'mainCategory': mainCategory,
    'subCategory': subCategory,
    'amount': amount,
    'income': income,
    'cash': cash,
    'time': time.toIso8601String(),
  };

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    mainCategory: json['mainCategory'],
    subCategory: json['subCategory'],
    amount: json['amount'],
    income: json['income'],
    cash: json['cash'],
    time: DateTime.parse(json['time']),
  );
}

class _CalculatorApplicationState extends State<CalculatorApplication> {
  String inputUser = '';
  String result = '0';
  bool switchCoin = false;
  bool income = false;
  bool cash = true;
  dynamic selectedMainCategory;
  dynamic selectedSubCategory;

  String getConverted(double rate) {
    double base = double.tryParse(result) ?? 0;
    return switchCoin
        ? (base / rate).toStringAsFixed(2)
        : (base * rate).toStringAsFixed(2);
  }

  void onOperatorPressed(String value) {
    setState(() {
      if (value == 'AC') {
        inputUser = '';
        result = '0';
      } else if (value == '<-') {
        if (inputUser.isNotEmpty) {
          inputUser = inputUser.substring(0, inputUser.length - 1);
        }
      } else if (value == 'S') {
        switchCoin = !switchCoin;
        try {
          Parser p = Parser();
          Expression exp = p.parse(inputUser);
          double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
          result = eval.toString();
        } catch (_) {
          result = '錯誤';
        }
      } else if (value == '=') {
        try {
          Parser p = Parser();
          Expression exp = p.parse(inputUser);
          double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
          result = eval.toString();
        } catch (_) {
          result = '錯誤';
        }
      } else {
        inputUser += value;
      }
    });
  }

  void onFinancePressed(String value) {
    setState(() {
      if (value == '支出') {
        income = false;
      } else if (value == '收入') {
        income = true;
      } else if (value == '刷卡') {
        cash = false;
      } else if (value == '現金') {
        cash = true;
      } else if (value == '分類') {
        showCategorySelector();
      } else if (value == 'Add') {
        onAddPressed();
      }
    });
  }

  void onAddPressed() {
    if (selectedMainCategory == null ||
        selectedSubCategory == null ||
        result.isEmpty)
      return;

    final record = Record(
      mainCategory: selectedMainCategory!,
      subCategory: selectedSubCategory!,
      amount: double.tryParse(result) ?? 0,
      income: income,
      cash: cash,
      time: DateTime.now(),
    );

    saveToLocal(record);
  }

  Future<void> showCategorySelector() async {
    String? selectedMain;
    String? selectedSub;

    final categories = {
      '飲食': ['早餐', '午餐', '晚餐', '點心'],
      '交通': ['公車', '捷運', '計程車'],
      '住宿': ['租金', '水電'],
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: Text("選擇主分類"),
                    value: selectedMain,
                    items:
                        categories.keys
                            .map(
                              (k) => DropdownMenuItem(child: Text(k), value: k),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedMain = val;
                        selectedSub = null;
                      });
                    },
                  ),
                  if (selectedMain != null)
                    DropdownButton<String>(
                      hint: Text("選擇子分類"),
                      value: selectedSub,
                      items:
                          categories[selectedMain]!
                              .map(
                                (s) =>
                                    DropdownMenuItem(child: Text(s), value: s),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => selectedSub = val),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedMain != null && selectedSub != null) {
                        Navigator.pop(context, [selectedMain, selectedSub]);
                      }
                    },
                    child: Text("確定"),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          selectedMainCategory = result[0];
          selectedSubCategory = result[1];
        });
      }
    });
  }

  Future<void> saveToLocal(Record record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = prefs.getStringList('records') ?? [];

    records.add(jsonEncode(record.toJson()));
    await prefs.setStringList('records', records);
  }

  Widget buildButton(String label, {Color? color, double fontSize = 20}) {
    return RawMaterialButton(
      onPressed: () => onOperatorPressed(label),
      fillColor: getButtonColor(label),
      padding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: getTextColor(label),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildButtonForFinance(
    String label, {
    Color? color,
    double fontSize = 15,
  }) {
    return RawMaterialButton(
      onPressed: () => onFinancePressed(label),
      fillColor: getButtonColor(label),
      padding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: getTextColor(label),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildDisplayRow(String label, String value, {double fontSize = 50}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFB7B7B7),
              fontSize: fontSize,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: fontSize + 10),
          ),
        ],
      ),
    );
  }

  Widget buildButtonRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          labels.map((label) => buildButton(label, fontSize: 25)).toList(),
    );
  }

  Color getButtonColor(String label) {
    const defaultColor = Color(0xFF414141);
    const primaryActionColor = Color(0xff2f00ff);
    const secondaryActionColor = Color(0xFFB7B7B7);
    const operatorColor = Color(0xFFf7921e);

    if (label == 'S') return primaryActionColor;

    if (['AC', '<-', '%'].contains(label)) return secondaryActionColor;

    if (['=', '+', '-', '*', '/'].contains(label)) return operatorColor;

    final isSelectedIncome = {'收入': income, '支出': !income};

    final isSelectedCash = {'現金': cash, '刷卡': !cash};

    if (isSelectedIncome.containsKey(label)) {
      return isSelectedIncome[label]! ? primaryActionColor : defaultColor;
    }

    if (isSelectedCash.containsKey(label)) {
      return isSelectedCash[label]! ? primaryActionColor : defaultColor;
    }

    return defaultColor;
  }

  Color getTextColor(String label) {
    if (['AC', '<-', '%'].contains(label)) return Colors.black;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    String selectedCurrency = 'TWD';
    String selectedCurrency2 = currencyProvider.selectedCurrency;
    double rate = currencyProvider.rates[selectedCurrency2] ?? 1.0;

    String converted = getConverted(rate);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CurrencyPage(),
                      ),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "選擇幣種",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              buildDisplayRow(
                switchCoin ? '$selectedCurrency \$' : '$selectedCurrency2 \$',
                converted,
                fontSize: 35,
              ),
              switchCoin
                  ? Text(
                    "$selectedCurrency2 To $selectedCurrency is ${(1 / rate).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      color: const Color(0xFFB7B7B7),
                    ),
                  )
                  : Text(
                    "$selectedCurrency To $selectedCurrency2 is ${rate.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      color: const Color(0xFFB7B7B7),
                    ),
                  ),
              buildDisplayRow(
                switchCoin ? '$selectedCurrency2 \$' : '$selectedCurrency \$',
                result,
                fontSize: 35,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    inputUser,
                    style: const TextStyle(
                      color: Color(0xFFB7B7B7),
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildButtonForFinance("支出"),
                        buildButtonForFinance("收入"),
                        buildButtonForFinance("刷卡"),
                        buildButtonForFinance("現金"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildButtonForFinance("分類"),
                        Container(
                          width: MediaQuery.of(context).size.width / 2.2,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              hintText: '簡單敘述',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.border_color,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        buildButtonForFinance("Add"),
                      ],
                    ),
                    buildButtonRow(['AC', '<-', '%', '/']),
                    buildButtonRow(['7', '8', '9', '*']),
                    buildButtonRow(['4', '5', '6', '-']),
                    buildButtonRow(['1', '2', '3', '+']),
                    buildButtonRow(['S', '0', '.', '=']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
