import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_expressions/math_expressions.dart';
import '../main.dart';
import 'currency.dart';

class CalculatorApplication extends StatefulWidget {
  const CalculatorApplication({super.key});

  @override
  State<CalculatorApplication> createState() => _CalculatorApplicationState();
}

class _CalculatorApplicationState extends State<CalculatorApplication> {
  String inputUser = '';
  String result = '0';
  bool switchCoin = false;

  void onButtonPressed(String value) {
    setState(() {
      inputUser += value;
    });
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

  Widget buildButton(String label, {Color? color, double fontSize = 30}) {
    return RawMaterialButton(
      onPressed: () => onOperatorPressed(label),
      fillColor: getButtonColor(label),
      padding: const EdgeInsets.all(20),
      shape: const CircleBorder(),
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

  Color getButtonColor(String label) {
    if (label == 'S') return const Color(0xff2f00ff);
    if (['AC', '<-', '%'].contains(label)) return const Color(0xFFB7B7B7);
    if (label == '=') return const Color(0xFFf7921e);
    return const Color(0xFF414141);
  }

  Color getTextColor(String label) {
    if (['AC', '<-', '%'].contains(label)) return Colors.black;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    String selectedCurrency = currencyProvider.selectedCurrency;
    double rate = currencyProvider.rates[selectedCurrency] ?? 1.0;

    String converted =
        switchCoin
            ? (double.tryParse(result) ?? 0 / rate).toStringAsFixed(2)
            : (rate * (double.tryParse(result) ?? 0)).toStringAsFixed(2);

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
                switchCoin ? '\$' : '$selectedCurrency \$',
                converted,
                fontSize: 50,
              ),
              buildDisplayRow(
                switchCoin ? '$selectedCurrency \$' : '\$',
                result,
                fontSize: 60,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
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
                    buildButtonRow(['AC', '<-', '%', '/']),
                    buildButtonRow(['1', '2', '3', '*']),
                    buildButtonRow(['4', '5', '6', '-']),
                    buildButtonRow(['7', '8', '9', '+']),
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
          labels
              .map(
                (label) => buildButton(label, fontSize: label == '=' ? 40 : 30),
              )
              .toList(),
    );
  }
}
