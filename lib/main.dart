import 'package:flutteo/serializer/currentConditions.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;

import 'serializer/cityInfo.dart';

Map jsonData;

var cond;
var ci;

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

  Future<http.Response> _loadJsonAsset() async {
    print("Debut requête");
    return await(http.get("https://www.prevision-meteo.ch/services/json/limoges"));
  }


  Future loadJson() async {
    var data = await _loadJsonAsset();
    print("Fin requête");
    final jsonData = json.decode(data.body);
    try {
      cond = CurrentCondition.fromJson(jsonData['current_condition']);
      ci = CityInfo.fromJson(jsonData['city_info']);

      print("Valeur récupérées");
    }
    catch (e)
    {
      print(e);
    }

    return ci;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 10.0),
        child: FutureBuilder(
          future: loadJson(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text("Loading..."), //Splash Screen à mettre
                ),
              );
            } else {
              return Container (
                child: ListView(
                  children: <Widget>[
                    Text("Data city info"),
                    Text("- " + ci.name.toString() + " (ville)"),
                    Text("- " + ci.country.toString() + " (pays)"),
                    Text("- " + ci.latitude.toString() + " (latitude)"),
                    Text("- " + ci.longitude.toString() + " (longitude)"),
                    Text("- " + ci.elevation.toString() + " (elevation)"),
                    Text("- " + ci.sunrise.toString() + " (sunrise)"),
                    Text("- "+ ci.sunset.toString() + " (sunset)"),
                    Text(" -------------- "),
                    Text("Data conditions"),
                    Text("- "+ cond.date.toString() + " (date)"),
                    Text("- "+ cond.hour.toString() + " (hour)"),
                    Text("- "+ cond.tmp.toString() + " (température)"),
                    Text("- "+ cond.windSpeed.toString() + " (wnd_spd)"),
                    Text("- "+ cond.windGust.toString() + " (wnd_gust)"),
                    Text("- "+ cond.windDir.toString() + " (wnd_dir)"),
                    Text("- "+ cond.pressure.toString() + " (pressure)"),
                    Text("- "+ cond.humidity.toString() + " (humidity)"),
                    Text("- "+ cond.condition.toString() + " (condition)"),
                    Text("- "+ cond.conditionKey.toString() + " (condition key)"),
                    Text("- "+ cond.icon.toString() + " (icon)"),
                    Text("- "+ cond.iconBig.toString() + " (icon Big)"),
                    Text(" -------------- "),
                  ],
                ),
              );
            }
          },
        ),
        ),
      );
  }
}
