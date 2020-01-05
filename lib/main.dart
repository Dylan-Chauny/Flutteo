import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutteo/serializer/currentConditions.dart';
import 'package:flutteo/serializer/fcst_day.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'serializer/cityInfo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


var cond;
var ci;
var forecast;
var fcst0;
var fcst1;
var fcst2;
var fcst3;
var currentTime;
var sunrise;
var sunset;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        iconTheme: new IconThemeData(
            color: Colors.white,
            opacity: 1.0,
            size: 50.0
        ),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var loading = false;

  Future _loadJsonAsset() async {
    print("Debut requête");
    return await(http.get("https://www.prevision-meteo.ch/services/json/limoges"));
  }

  void loadJson() async {
    try {
      var data = await _loadJsonAsset();
      print("Fin requête");
      final jsonData = await json.decode(data.body);

      cond = CurrentCondition.fromJson(jsonData['current_condition']);
      //ci = CityInfo.fromJson(jsonData['city_info']);
      ci = CityInfo.fromJson(jsonData['city_info']);
      fcst0 = fcstDay.fromJson(jsonData['fcst_day_0']);
      fcst1 = fcstDay.fromJson(jsonData['fcst_day_1']);
      fcst2 = fcstDay.fromJson(jsonData['fcst_day_2']);
      fcst3 = fcstDay.fromJson(jsonData['fcst_day_3']);
      print("Valeur récupérées");
      //print(fcst0.hourlyData.toString());

      Timer(Duration(seconds: 2 ), () {
        setState(() {
          loading = true;
          //currentTime 17:52
          //sunset = ci.sunset.toString(); //18:43
        });
      });
    }
    catch (e)
    {
      print(e);
    }
  }

  @override
  void initState() {

    var current = new DateTime.now();

    var min = current.minute.toString();
    var hour = current.hour.toString();

    if(int.parse(min) < 10)
    {
        min = "0"+ min;
    }
    currentTime = hour + ":" + min;

    loadJson();
  }

  void test() {
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text('My Page')),
          body: Center(
            child: FlatButton(
              child: Text('POP'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    ));
  }

  List<Widget> containers() {
    List<Widget> l = new List();
    var hourStart;
    var hour;
    var indice = 0;

    for (int i = 0; i < 24; i++) {
      // UPDATE A remplacer avec heure du tableau

      if(i == 0)
      {
          hourStart = cond.hour.toString().replaceAll(":", "").substring(0, 2);
          hour = hourStart + ":00";

      }
      else {
          hour = (int.parse(hourStart) + i).toString() + ":00";
          if(int.parse(hourStart) + i > 24)
          {
            //Changement de jours pour les données à récupérer

                indice+= 1;
                if(indice < 10)
                    hour = "0"+indice.toString() + ":00";
                else
                    hour = indice.toString() + ":00";
          }
      }

      // Aller chercher les données sur hour dans le json
      // Remplacer les : par H pour le json

      int temperature = Random().nextInt(36);
      var icon = temperature < 10 ? Icon(FontAwesomeIcons.thermometerEmpty, size: 16, color: Colors.lightBlueAccent,) :
                 temperature < 15 ? Icon(FontAwesomeIcons.thermometerQuarter, size: 16, color: Colors.yellowAccent):
                 temperature < 25 ? Icon(FontAwesomeIcons.thermometerHalf, size: 16, color: Colors.orangeAccent):
                 Icon(FontAwesomeIcons.thermometerThreeQuarters, size: 16, color: Colors.redAccent);

      l.add(Container(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
        width: 47.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(hour, style: TextStyle(fontWeight: FontWeight.bold)),
            Container(height: 5, child: Text(' ')),
            Icon(Icons.wb_sunny, size: 50.0, color: Colors.amberAccent),
            Container(height: 5, child: Text(' ')),
            Text("💧 22%", style: TextStyle(fontWeight: FontWeight.w300)),
            Container(height: 5, child: Text(' ')),
            Row(
              children: <Widget>[
                icon,
                Text(" ${temperature}°", style: TextStyle(fontWeight: FontWeight.w300))
              ],
            )
          ],
        ),
      ));
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !loading ? Container(
        height: 1000,
        color: Colors.white,
        child: Image.network('https://cdn.discordapp.com/attachments/418499901215735808/663047823813640193/Logo.png'),
      ) :
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/662867597108183054/2Q.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(ci.name.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0)),
                      Text(currentTime.toString(), style: TextStyle(fontWeight: FontWeight.w300))
                    ],
                  ),
                ),
                Container(height: 20, child: Text('')),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(cond.condition.toString(), style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20)),
                          Row(children: <Widget>[
                            Text('5°', style: TextStyle(fontSize: 100.0, fontWeight: FontWeight.w300)),
                            Text('C', style: TextStyle(fontSize: 30.0))
                          ],),
                          Row(children: <Widget>[
                            Icon(FontAwesomeIcons.arrowUp, size: 15, color: Colors.red,),
                            Text(fcst0.tmax.toString() + '°', style: TextStyle(color: Colors.red),),
                            Icon(FontAwesomeIcons.arrowDown, size: 15, color: Colors.lightBlueAccent,),
                            Text(fcst0.tmin.toString()+'°', style: TextStyle(color: Colors.lightBlueAccent),),
                            Row(
                              children: <Widget>[
                                Text(' On a la sensation de : ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
                                Text('2°', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200)),

                              ],
                            )
                          ],)
                          //UPDATE sensation : WindChill dans l'heure current
                        ],
                      ),
                      Image.network(cond.iconBig.toString())
                    ],
                  ),
                ),
                Container(height: 20, child: Text(''), //new Color.fromRGBO(255, 0, 0, 0.0),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    height: 130,
                    decoration: new BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.1), //new Color.fromRGBO(255, 0, 0, 0.0),
                        borderRadius: BorderRadius.only(
                            topLeft:  Radius.circular(5.0),
                            topRight: Radius.circular(5.0),
                            bottomLeft: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0))
                    ),
                    padding: EdgeInsets.all(5),
                    child:  ListView(
                      // This next line does the trick.
                      scrollDirection: Axis.horizontal,
                      children: containers(),
                    )
                ),
                Container(height: 20, child: Text('')),
                Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('📅 PRÉVISIONS QUOTIDIENNES', style: TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        padding: EdgeInsets.all(10),
                        decoration: new BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.1), //new Color.fromRGBO(255, 0, 0, 0.0),
                            borderRadius: BorderRadius.only(
                                topLeft:  Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                                bottomLeft: Radius.circular(5.0),
                                bottomRight: Radius.circular(5.0))
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(cond.condition.toString() + " de " + fcst0.dayLong.toString() +" jusqu'à " + fcst1.dayLong.toString() +" matin", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w200), textAlign: TextAlign.center),
                            Container(height: 5, child: Text('')),
                            Container(
                              height: 1,
                              width: 400,
                              color: Colors.white30,
                            ),
                            Container(height: 5, child: Text('')),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(fcst0.dayShort.toString()),
                                    Text(fcst0.dateCalendar.toString())
                                  ],
                                ),
                                Image.network(fcst0.icon.toString()),
                                Text(fcst0.condition.toString()),
                                Row(
                                  children: <Widget>[
                                    Text(fcst0.tmin.toString()+'°', style: TextStyle(color: Colors.lightBlueAccent)),
                                    Text('| '),
                                    Text(fcst0.tmax.toString()+'°', style: TextStyle(color: Colors.redAccent)),
                                  ],
                                ),
                                IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: null)
                              ],
                            ),
                            Container(
                              height: 0.25,
                              width: 400,
                              color: Colors.white30,
                              margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(fcst1.dayShort.toString()),
                                    Text(fcst1.dateCalendar.toString())
                                  ],
                                ),
                                Image.network(fcst1.icon.toString()),
                                Text(fcst1.condition.toString()),
                                Row(
                                  children: <Widget>[
                                    Text(fcst1.tmin.toString()+'°', style: TextStyle(color: Colors.lightBlueAccent)),
                                    Text('| '),
                                    Text(fcst1.tmax.toString()+'°', style: TextStyle(color: Colors.redAccent)),
                                  ],
                                ),
                                IconButton(icon: Icon(Icons.arrow_forward_ios),  onPressed: null)
                              ],
                            ),
                            Container(
                              height: 0.25,
                              width: 400,
                              color: Colors.white30,
                              margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(fcst2.dayShort.toString()),
                                    Text(fcst2.dateCalendar.toString())
                                  ],
                                ),
                                Image.network(fcst2.icon.toString()),
                                Text(fcst2.condition.toString()),
                                Row(
                                  children: <Widget>[
                                    Text(fcst2.tmin.toString()+'°', style: TextStyle(color: Colors.lightBlueAccent)),
                                    Text('| '),
                                    Text(fcst2.tmax.toString()+'°', style: TextStyle(color: Colors.redAccent)),
                                  ],
                                ),
                                IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: null),
                              ],
                            ),
                            Container(
                              height: 0.25,
                              width: 400,
                              color: Colors.white30,
                              margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(fcst3.dayShort.toString()),
                                    Text(fcst3.dateCalendar.toString())
                                  ],
                                ),
                                Image.network(fcst3.icon.toString()),
                                Text(fcst3.condition.toString()),
                                Row(
                                  children: <Widget>[
                                    Text(fcst3.tmin.toString()+'°', style: TextStyle(color: Colors.lightBlueAccent)),
                                    Text('| '),
                                    Text(fcst3.tmax.toString()+'°', style: TextStyle(color: Colors.redAccent)),
                                  ],
                                ),
                                IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: null)
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(height: 20, child: Text('')),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('🔎 DÉTAILS ACTUELS', style: TextStyle(fontWeight: FontWeight.w500)),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              padding: EdgeInsets.all(10),
                              decoration: new BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.1), //new Color.fromRGBO(255, 0, 0, 0.0),
                                  borderRadius: BorderRadius.only(
                                      topLeft:  Radius.circular(5.0),
                                      topRight: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0))
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Humidité"),
                                      Container(height: 5, child: Text(' ')),
                                      Icon(FontAwesomeIcons.umbrella, size: 35, color: Colors.black,),
                                      Container(height: 10, child: Text(' ')),
                                      Text(cond.humidity.toString()+"%", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))
                                    ],
                                  ),
                                  Container(
                                    height: 100.0,
                                    width: 0.5,
                                    color: Colors.white30,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Précipitation"),
                                      //UPDATE Vérifier si ISSNOW dans fcst0 renvoie 1 alors mettre icone de neige (☃)
                                      Container(height: 5, child: Text(' ')),
                                      Text("💧", style: TextStyle(fontSize: 30)),
                                      //Icon(Icons.ac_unit, size: 30, color: Colors.white,),
                                      Container(height: 10, child: Text(' ')),
                                      Text("0.3mm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))
                                      //UPDATE heure courante + APCPsfc
                                    ],
                                  ),
                                  Container(
                                    height: 100.0,
                                    width: 0.5,
                                    color: Colors.white30,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text("Elevation"),
                                      Container(height: 5, child: Text(' ')),
                                      Text("⛰️", style: TextStyle(fontSize: 30)),
                                      Container(height: 10, child: Text(' ')),
                                      Text(ci.elevation.toString()+"m", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))
                                    ],
                                  ),
                                  Container(
                                    height: 100.0,
                                    width: 0.5,
                                    color: Colors.white30,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text("Orage"),
                                      Container(height: 5, child: Text(' ')),
                                      Text('🌩', style: TextStyle(fontSize: 30)),
                                      Container(height: 10, child: Text(' ')),
                                      Text("100%", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))
                                      //UPDATE heure courante + KINDEX
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(height: 20, child: Text('')),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('🍃 VENT & PRESSION EN CE MOMENT', style: TextStyle(fontWeight: FontWeight.w500)),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              padding: EdgeInsets.all(10),
                              decoration: new BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.1), //new Color.fromRGBO(255, 0, 0, 0.0),
                                  borderRadius: BorderRadius.only(
                                      topLeft:  Radius.circular(5.0),
                                      topRight: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0))
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text("🌬", style: TextStyle(fontSize: 100 )),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(FontAwesomeIcons.compass, size: 17, color: Colors.yellow),
                                          Text("  " + cond.windDir.toString()),
                                          //UPDATE - Prendre celui de l'heure courante PRMSL (passer par hour pour les données du tableau)
                                        ],
                                      ),
                                      Container(height: 5, child: Text(' ')),
                                      Text("(Orientation du vent)", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10)),
                                      Container(height: 10, child: Text(' ')),
                                      Row(
                                        children: <Widget>[
                                          Icon(FontAwesomeIcons.locationArrow, size: 15, color: Colors.red),
                                          Text("  209°"), // UPDATE windDir10m
                                        ],
                                      ),
                                      Container(height: 5, child: Text(' ')),
                                      Text("(Direction du vent)", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10)),
                                      Container(height: 10, child: Text(' ')),
                                      Row(
                                        children: <Widget>[
                                          Icon(FontAwesomeIcons.exclamationCircle, size: 15, color: Colors.orangeAccent),
                                          Text('  30%', style: TextStyle(fontWeight: FontWeight.bold))
                                          //UPDATE WNDSPD10m
                                        ],
                                      ),
                                      Container(height: 5, child: Text(' ')),
                                      Text("(Vent +10km/h)", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10)),
                                      Container(height: 10, child: Text(' ')),
                                      Row(
                                        children: <Widget>[
                                          Text("🚩", style: TextStyle(fontSize: 15)),
                                          Text(" "+ cond.windGust.toString() + ' km/h', style: TextStyle(fontWeight: FontWeight.bold)),
                                          //UPDATE WNDGUST10m
                                        ],
                                      ),
                                      Container(height: 5, child: Text(' ')),
                                      Text("(Vitesse du vent)", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10)),
                                      Container(height: 10, child: Text(' ')),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text('Pression'),
                                      Container(height: 5, child: Text(' ')),
                                      Icon(FontAwesomeIcons.tachometerAlt, color: Colors.lightGreen,),
                                      Container(height: 5, child: Text(' ')),
                                      Text('1000 mbar', style: TextStyle(fontWeight: FontWeight.bold))
                                      //UPDATE heure courante + PRMSL
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(height: 20, child: Text('')),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('☀ SOLEIL', style: TextStyle(fontWeight: FontWeight.w500)),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              padding: EdgeInsets.all(10),
                              decoration: new BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.1), //new Color.fromRGBO(255, 0, 0, 0.0),
                                  borderRadius: BorderRadius.only(
                                      topLeft:  Radius.circular(5.0),
                                      topRight: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0))
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text("🌅 "+ ci.sunrise.toString(), style: TextStyle(fontWeight: FontWeight.bold)), //windDir10m
                                        ],
                                      ),
                                      Container(height: 5, child: Text(' ')),
                                      Text("(Heure du levé)", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10)),
                                      Container(height: 10, child: Text(' ')),
                                      Row(
                                        children: <Widget>[
                                          Text("🌇 "+ ci.sunset.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Container(height: 5, child: Text(' ')),
                                      Text("(Heure du couché)", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10)),
                                      Container(height: 10, child: Text(' ')),
                                      Row(
                                        children: <Widget>[
                                          Text("⌛ 3:20", style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Container(height: 5, child: Text(' ')),
                                      Text("(Temps restant)", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10)),
                                    ]
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    height: 100.0,
                                    width: 0.5,
                                    color: Colors.white30,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        width: 230,
                                        height:100,
                                        decoration: new BoxDecoration(
                                            color: Color.fromRGBO(255, 200, 0, 0.6), //new Color.fromRGBO(255, 0, 0, 0.0),,
                                            borderRadius: BorderRadius.only(
                                                topLeft:  Radius.circular(100.0),
                                                topRight: Radius.circular(100.0),
                                                bottomLeft: Radius.circular(0.0),
                                                bottomRight: Radius.circular(0.0))
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 20, child: Text('')),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
