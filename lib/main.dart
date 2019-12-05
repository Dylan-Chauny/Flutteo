import 'package:flutteo/serializer/currentConditions.dart';
import 'package:flutteo/serializer/fcst_day.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'Views/allViews.dart';
import 'layout.dart';

import 'serializer/cityInfo.dart';

Map jsonData;

var count = 0;
var cond;
var ci;
var fcst0;
var fcst1;
var fcst2;

bool getData = false;
String iconsTest = "https://www.prevision-meteo.ch/style/images/icon/ensoleille.png";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluteo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.indigo,
        appBarTheme: AppBarTheme(brightness: Brightness.dark)
      ),
      home: MyHomePage(title: 'Flutteo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage = 0;
  final _pageOptions = [
    Jour1(),
    Jour2(),
    Jour3(),
  ];

  Future<http.Response> _loadJsonAsset() async {
    print("Debut requête");
    return await(http.get("https://www.prevision-meteo.ch/services/json/limoges"));
  }

  Future loadJson() async {
    count++;
    try {
      var data = await _loadJsonAsset();
      print("Fin requête");
      final jsonData = json.decode(data.body);

      cond = CurrentCondition.fromJson(jsonData['current_condition']);
      ci = CityInfo.fromJson(jsonData['city_info']);
      fcst0 = fcstDay.fromJson(jsonData['fcst_day_0']);
      fcst1 = fcstDay.fromJson(jsonData['fcst_day_1']);
      fcst2 = fcstDay.fromJson(jsonData['fcst_day_2']);

      //Liste complète des heures : fcst.hourlyData.toString();

      print("Valeur récupérées");
      print("Appel: $count");
      getData = true;
    }
    catch (e)
    {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    loadJson();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
        body : _pageOptions[_selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPage,
          onTap: (int index) {
            setState(() {
              _selectedPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.wb_cloudy),
                title: Text("Jour 1")
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.wb_sunny),
                title: Text("Jour 2")
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.brightness_2),
                title: Text("Jour 3"),
            ),
          ],
        ),
      );
  }
}
