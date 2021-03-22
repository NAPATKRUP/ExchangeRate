import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:http/http.dart' as http;
import 'ExchangeRate.dart';
import 'RateBox.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    return MaterialApp(
      title: "ExchangeRate",
      home: HomePage(),
      theme: ThemeData(primaryColor: Colors.white),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ExchangeRate dataFromAPI;
  int amount = 1;

  @override
  void initState() {
    super.initState();
    getExchangeRate();
  }

  Future<ExchangeRate> getExchangeRate() async {
    var url = Uri.https('api.exchangeratesapi.io', '/latest', {'q': '{https}'});
    var response = await http.get(url);
    dataFromAPI = exchangeRateFromJson(response.body);
    return dataFromAPI;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Exchange Rate")),
        body: FutureBuilder(
            future: getExchangeRate(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var result = snapshot.data;

                var currency = [];
                result.rates.keys.forEach((k) => currency.add(k));

                List<Widget> allBox = [];
                allBox.add(TextField(
                  onSubmitted: (text) {
                    setState(() {
                      amount = int.parse(text);
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    hintText: "Enter number",
                  ),
                ));
                allBox.add(SizedBox(height: 15));
                allBox.add(ListTile(
                    title: Text(
                  "$amount ${result.base}",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                )));
                allBox.add(ListTile(
                    title: Text(
                  "Last Update: " + result.date.toString(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                )));
                currency.forEach((c) => allBox.add(
                    RateBox(c, result.rates[c] * amount, Colors.black, 70)));

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: allBox,
                  ),
                );
              }

              return LinearProgressIndicator();
            }));
  }
}
