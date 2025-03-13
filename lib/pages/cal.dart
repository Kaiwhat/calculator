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
  var result = '0';
  var inputUser = '';
  bool switchCoin = false;
  void buttonPressed(String text) {
    setState(() {
      inputUser = inputUser + text;
    });
  }

  Widget getRow(String text1, String text2, String text3, String text4) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RawMaterialButton(
          onPressed: () {
            if (text1 == 'AC') {
              setState(() {
                inputUser = '';
                result = '0';
              });
            } else if (text1 == 'S') {
              setState(() {
                switchCoin = !switchCoin; // ✅ 這樣 UI 會更新
              });
            } else {
              buttonPressed(text1);
            }
          },
          elevation: 2.0,
          fillColor: getBackgroundColor(text1),
          padding: EdgeInsets.all(20.0),
          shape: CircleBorder(),
          child: Text(
            text1,
            style: TextStyle(
              color: getTextColor(text1),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RawMaterialButton(
          onPressed: () {
            if (text2 == '<-') {
              setState(() {
                if (inputUser.isNotEmpty) {
                  inputUser = inputUser.substring(0, inputUser.length - 1);
                }
              });
            } else {
              buttonPressed(text2);
            }
          },
          elevation: 2.0,
          fillColor: getBackgroundColor(text2),
          padding: EdgeInsets.all(20.0),
          shape: CircleBorder(),
          child: Text(
            text2,
            style: TextStyle(
              color: getTextColor(text2),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RawMaterialButton(
          onPressed: () {
            buttonPressed(text3);
          },
          elevation: 2.0,
          fillColor: getBackgroundColor(text3),
          padding: EdgeInsets.all(20.0),
          shape: CircleBorder(),
          child: Text(
            text3,
            style: TextStyle(
              color: getTextColor(text3),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RawMaterialButton(
          onPressed: () {
            if (text4 == '=') {
              Parser parser = Parser();
              Expression expression = parser.parse(inputUser);
              ContextModel contextModel = ContextModel();
              double eval = expression.evaluate(
                EvaluationType.REAL,
                contextModel,
              );
              setState(() {
                result = eval.toString();
              });
            } else {
              buttonPressed(text4);
            }
          },
          elevation: 2.0,
          fillColor: Color(0xFFf7921e),
          padding: EdgeInsets.all(15.0),
          shape: CircleBorder(),
          child: Text(
            text4,
            style: TextStyle(
              fontSize: 40,
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var currencyProvider = Provider.of<CurrencyProvider>(context);
    String selectedCurrency = currencyProvider.selectedCurrency;
    double rate = currencyProvider.rates[selectedCurrency] ?? 1.0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0x00000000),
        body: SafeArea(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrencyPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 設定按鈕顏色
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
              Expanded(
                flex: 15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            switchCoin ? '\$' : '$selectedCurrency \$',
                            style: TextStyle(
                              color: Color(0xFFB7B7B7),
                              fontSize: 40,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              switchCoin
                                  ? (double.parse(result) / rate)
                                      .toStringAsFixed(2)
                                  : (rate * double.parse(result))
                                      .toStringAsFixed(2),
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            inputUser,
                            style: TextStyle(
                              color: Color(0xFFB7B7B7),
                              fontSize: 40,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            switchCoin ? '$selectedCurrency \$' : '\$',
                            style: TextStyle(
                              color: Color(0xFFB7B7B7),
                              fontSize: 50,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              result,
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(height: 5),
                    getRow('AC', '<-', '%', '/'),
                    getRow('1', '2', '3', '*'),
                    getRow('4', '5', '6', '-'),
                    getRow('7', '8', '9', '+'),
                    getRow('S', '0', '.', '='),
                    Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isOprator(String text) {
    var list = ['AC', '<-', '%'];

    for (var item in list) {
      if (text == item) {
        return true;
      }
    }
    return false;
  }

  Color getBackgroundColor(String text) {
    if (text == 'S') {
      return Color(0xff2f00ff);
    } else if (isOprator(text)) {
      return Color(0xFFB7B7B7);
    } else {
      return Color(0xFF414141);
    }
  }

  bool TextOprator(String text) {
    var list = ['AC', '<-', '%'];

    for (var item in list) {
      if (text == item) {
        return true;
      }
    }
    return false;
  }

  Color getTextColor(String text) {
    if (isOprator(text)) {
      return Colors.black;
    } else {
      return Color(0xFFFFFFFF);
    }
  }
}
