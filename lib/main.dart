import 'dart:ffi';
import 'dart:math';
import 'package:flutteo/serializer/hourly_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutteo/serializer/currentConditions.dart';
import 'package:flutteo/serializer/fcst_day.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'serializer/cityInfo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

var cond;
var ci;
var forecast;
var fcst0;
var fcst1;
var fcst2;
var fcst3;
var currentHourlyData;
var currentTime;
var sunrise;
var sunset;
var diff;
var diffHour;

var hourConcerned;
var jsonData;
var precipitationIcon;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutteo',
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
      home: MyHomePage(title: 'Flutteo'),
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
    return await(http.get(
        "https://www.prevision-meteo.ch/services/json/limoges"));
  }

  void loadJson() async {
    try {
      var data = await _loadJsonAsset();
      jsonData = await json.decode(data.body);

      cond = CurrentCondition.fromJson(jsonData['current_condition']);
      //ci = CityInfo.fromJson(jsonData['city_info']);
      ci = CityInfo.fromJson(jsonData['city_info']);
      fcst0 = fcstDay.fromJson(jsonData['fcst_day_0']);
      fcst1 = fcstDay.fromJson(jsonData['fcst_day_1']);
      fcst2 = fcstDay.fromJson(jsonData['fcst_day_2']);
      fcst3 = fcstDay.fromJson(jsonData['fcst_day_3']);

      hourConcerned = cond.hour.toString().replaceAll(":", "H");

      if (hourConcerned.toString().substring(0, 1) == "0")
        hourConcerned = hourConcerned.toString().substring(1);


      currentHourlyData = hourly.fromJson(jsonData['fcst_day_0']['hourly_data'][hourConcerned]);

      var isSnow = currentHourlyData.ISSNOW;

      precipitationIcon = isSnow == 1 ? Text("🌨", style: TextStyle(fontSize: 30)) : Text("🌧", style: TextStyle(fontSize: 30));

      var sunsetSplit = ci.sunset.toString().split(":");
      var sunriseSplit = ci.sunrise.toString().split(":");
      var timeNow = new TimeOfDay.now();
      var sunriseTime = new TimeOfDay(hour: int.parse(sunriseSplit[0]), minute: int.parse(sunriseSplit[1]));
      var sunsetTime = new TimeOfDay(hour: int.parse(sunsetSplit[0]), minute: int.parse(sunsetSplit[1]));

      var now = new DateTime.now();
      var dateTimeNow = new DateTime(
          now.year, now.month, now.day, timeNow.hour, timeNow.minute);
      var dateTimeSunset = new DateTime(
          now.year, now.month, now.day, sunsetTime.hour, sunsetTime.minute);
      var sunriseDateTime = new DateTime(
          now.year, now.month, now.day, sunriseTime.hour, sunriseTime.minute);
      diff = dateTimeSunset.difference(dateTimeNow).toString().substring(0, 4);

      var diffToNowToSunrise = dateTimeNow.difference(sunriseDateTime).toString().substring(0,1);

      var checkHour = diff.split(':');
      diffHour = int.parse(checkHour[0]);
      var diffMin = int.parse(checkHour[1]);

      var checkNegativeValue = diff.toString().substring(0, 1);

      // Display 08H00 into 8H00
      if (diffHour < 10)
        diff = "0" + diff.toString();

      // Display no minutes
      if (checkNegativeValue == "-" || diffToNowToSunrise == "-")
        diff = "Aucune minutes";

      // Case where only Minutes remains
      if(diffHour == 0)
        {
          // Display in good format
          diff = diff.toString().replaceFirst("00:", "")+" min";
          if (diffMin < 10)
            diff = diff.toString().replaceFirst('0', "");
        }

      // Display 08:02 into 08:2
      if(checkHour[1].toString().length < 2 && checkNegativeValue != "-")
          diff = diff.toString().replaceFirst(':', ':0');

      Timer(Duration(seconds: 2), () {
        setState(() {
          loading = true;
        });
      });

    }
    catch (e) {
      print(e);
    }
  }

  giveMeHeight(temp)
  {
    var height = 20;

    if(temp.toString().substring(0,1) != "-")
      height = (temp*10) + 30;

    return height.toDouble();
  }

  @override
  void initState() {
    var current = new DateTime.now();

    var min = current.minute.toString();
    var hour = current.hour.toString();

    // Display in good format 18:34
    if (int.parse(min) < 10)
      min = "0" + min;

    if (int.parse(hour) < 10)
      hour = "0" + hour;

    currentTime = hour + ":" + min;
    loadJson();
  }

  void popup0() {
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Données pour le '+fcst0.dayShort.toString()+ ' ' + fcst0.date.toString().replaceAll(".", "/"), style: TextStyle(color: Colors.amber)),
            elevation: 0.0,
            flexibleSpace: Image(
              //https://cdn.discordapp.com/attachments/418499901215735808/665582664866070634/2Q3.png
              image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/665579632862691348/2Q2.png"),
              fit: BoxFit.cover,
            ),
            iconTheme: new IconThemeData(
              color: Colors.white,
              opacity: 1.0,
            ),
          ),
          body: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/662867597108183054/2Q.png"),
                    fit: BoxFit.cover,
                  ) ,
                ),
                child: FlatButton(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      // This next line does the trick.
                      children: containers_hour(0),
                    ),
                    onPressed:() {
                      Navigator.pop(context);
                    }
                ),
              ),
            ],
          )
        );
      },
    ));
  }

  void popup1() {
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Données pour le '+fcst1.dayShort.toString()+ ' ' + fcst1.date.toString().replaceAll(".", "/"), style: TextStyle(color: Colors.amber)),
              elevation: 0.0,
              flexibleSpace: Image(
                //https://cdn.discordapp.com/attachments/418499901215735808/665579632862691348/2Q2.png
                image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/665579632862691348/2Q2.png"),
                fit: BoxFit.cover,
              ),
              iconTheme: new IconThemeData(
                color: Colors.white,
                opacity: 1.0,
              ),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/662867597108183054/2Q.png"),
                      fit: BoxFit.cover,
                    ) ,
                  ),
                  child: FlatButton(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        // This next line does the trick.
                        children: containers_hour(1),
                      ),
                      onPressed:() {
                        Navigator.pop(context);
                      }
                  ),
                ),
              ],
            )
        );
      },
    ));
  }

  void popup2() {
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Données pour le '+fcst2.dayShort.toString()+ ' ' + fcst2.date.toString().replaceAll(".", "/"), style: TextStyle(color: Colors.amber)),
              elevation: 0.0,
              flexibleSpace: Image(
                //https://cdn.discordapp.com/attachments/418499901215735808/665579632862691348/2Q2.png
                image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/665579632862691348/2Q2.png"),
                fit: BoxFit.cover,
              ),
              iconTheme: new IconThemeData(
                color: Colors.white,
                opacity: 1.0,
              ),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/662867597108183054/2Q.png"),
                      fit: BoxFit.cover,
                    ) ,
                  ),
                  child: FlatButton(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        // This next line does the trick.
                        children: containers_hour(2),
                      ),
                      onPressed:() {
                        Navigator.pop(context);
                      }
                  ),
                ),
              ],
            )
        );
      },
    ));
  }

  void popup3() {
    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Données pour le '+fcst3.dayShort.toString()+ ' ' + fcst3.date.toString().replaceAll(".", "/"), style: TextStyle(color: Colors.amber)),
              elevation: 0.0,
              flexibleSpace: Image(
                //https://cdn.discordapp.com/attachments/418499901215735808/665579632862691348/2Q2.png
                //https://cdn.discordapp.com/attachments/418499901215735808/665582664866070634/2Q3.png
                image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/665579632862691348/2Q2.png"),
                fit: BoxFit.cover,
              ),
              iconTheme: new IconThemeData(
                color: Colors.white,
                opacity: 1.0,
              ),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://cdn.discordapp.com/attachments/418499901215735808/662867597108183054/2Q.png"),
                      fit: BoxFit.cover,
                    ) ,
                  ),
                  child: FlatButton(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        // This next line does the trick.
                        children: containers_hour(3),
                      ),
                      onPressed:() {
                        Navigator.pop(context);
                      }
                  ),
                ),
              ],
            )
        );
      },
    ));
  }

  List<Widget> containers() {
    List<Widget> l = new List();
    var hourStart;
    var hour;
    var index = 0;

    for (int i = 0; i < 24; i++) {
      var hourlyData;
      var hourForData;
      var temperature;


      if (i == 0) {
        {
          hourStart = cond.hour.toString().replaceAll(":", "").substring(0, 2);
          hour = hourStart + ":00";
        }


        var hourData = hour.toString().replaceAll("00:", "0:");

        if (hourData.substring(0, 1) == "0" && hourData.substring(0,2) != "0:")
          hourData = hourData.substring(1);

        hourlyData = hourly.fromJson(jsonData['fcst_day_0']['hourly_data'][hourData.toString().replaceAll(":", "H")]);
        temperature = hourlyData.TMP2m;
      }
      else {
        hour = (int.parse(hourStart) + i).toString() + ":00";
        if (int.parse(hourStart) + i > 24) {
          index += 1; // Continue la liste pour le jour suivant à 1H00 du matin

          //Display format
          if (index < 10) {
            hour = "0" + index.toString() + ":00";
            hourForData = index.toString() + "H00";
          }
          else {
            hour = index.toString() + ":00";
            hourForData = index.toString() + "H00";
          }
          hourlyData = hourly.fromJson(
              jsonData['fcst_day_1']['hourly_data'][hourForData.toString().replaceAll(":", "H")]);
        }
        else {
          hourForData = hour.toString().replaceAll(":", "H").replaceFirst("24", "0");
          hourlyData = hourly.fromJson(jsonData['fcst_day_0']['hourly_data'][hourForData.toString()]);
        }
      }

      // Interactiv color on thermometer based on temperatures
      temperature = hourlyData.TMP2m;
      var icon = temperature < 10 ? Icon(FontAwesomeIcons.thermometerEmpty, size: 17, color: Colors.lightBlueAccent,) :
      temperature < 15 ? Icon(FontAwesomeIcons.thermometerQuarter, size: 17, color: Colors.amberAccent) :
      temperature < 25 ? Icon(FontAwesomeIcons.thermometerHalf, size: 17, color: Colors.orangeAccent) :
      Icon(FontAwesomeIcons.thermometerThreeQuarters, size: 17, color: Colors.redAccent);

      // Add Each element for each houre on the listView
      l.add(Container(
        margin: EdgeInsets.fromLTRB(7, 0, 8, 0),
        width: 60.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(hour, style: TextStyle(fontWeight: FontWeight.bold)),
            Image.network(hourlyData.ICON.toString(), height: 60.0),
            Text("💧 " + hourlyData.RH2m.toString() + "%",
                style: TextStyle(fontWeight: FontWeight.w300)),
            Container(height: 5, child: Text(' ')),
            Container(
              height: 0.20,
              width: 100,
              color: Colors.white,
            ),
            Container(height: 3, child: Text(' ')),
            Row(
              children: <Widget>[
                Text("  "),
                icon,
                Text(" ${temperature.toString()}°",
                    style: TextStyle(fontWeight: FontWeight.w300)),
              ],
            ),
          ],
        ),
      ));
    }
    return l;
  }

  List<Widget> containers_hour(day) {
    List<Widget> l = new List();

    l.add(Container(margin: EdgeInsets.fromLTRB(0, 10, 0, 0)),);

    for (int i = 0; i < 24; i++) {
      var hourStart = i.toString() + "H00";
      var displayHourStart = hourStart.toString().replaceFirst("H", ":");
      var hourlyData;

      hourlyData = hourly.fromJson(jsonData['fcst_day_'+day.toString()]['hourly_data'][hourStart]);

      var isSnow = hourlyData.ISSNOW;
      precipitationIcon = isSnow == 1 ? Text("🌨", style: TextStyle(fontSize: 30)) : Text("🌧", style: TextStyle(fontSize: 30));

      l.add(
        Container(
          height: 210,
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(0, 10, 5, 10),
          decoration: new BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.20),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column (
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        width: 160,
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Image.network(hourlyData.ICON.toString(), height: 30),
                            ),
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(hourlyData.CONDITION.toString(), style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white))
                            ),
                          ],
                        ),
                      )

                    ],
                  ),
                  Container(height: 5, child: Text('')),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 160,
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: <Widget>[
                            Text(hourlyData.TMP2m.toString()+"°", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400, color: Colors.amber)),
                            Text("C", style: TextStyle(fontSize: 25, color: Colors.amber))
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: 160,
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    alignment: Alignment.bottomLeft,
                    child: Row (
                      children: <Widget>[
                        Text("Ressentie: "+hourlyData.WNDCHILL2m.toString()+"°C", style: TextStyle(fontWeight: FontWeight.w200, color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(height: 5, child: Text('')),
                  Container(
                    width: 160,
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: <Widget>[
                        Text("Point de rosée: "+hourlyData.DPT2m.toString()+"°C", style: TextStyle(fontWeight: FontWeight.w200, color: Colors.white),)
                      ],
                    )
                  ),
                  Container(height: 30, child: Text('')),
                  Container(
                    width: 160,
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: <Widget>[
                        Text(displayHourStart.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.lightBlueAccent))
                      ],
                    )
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Row (
                    children: <Widget>[
                      Container(
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.35),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0),
                            bottomLeft: Radius.circular(25.0),
                            bottomRight: Radius.circular(25.0))
                        ),
                        width: 100,
                        height: 90,
                        child: Column (
                          children: <Widget>[
                            Container(height: 8),
                            Text('Précipitation', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: Colors.white)),
                            Container(height: 5),
                            precipitationIcon,
                            Container(height: 5),
                            Text(hourlyData.APCPsfc.toString()+"mm", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 12, color: Colors.white)),
                          ],
                        ),
                      ),
                      Container(width: 10, child: Text('')),
                      Container(
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.35),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0))
                        ),
                        width: 80,
                        height: 90,
                        child: Column (
                          children: <Widget>[
                            Container(height: 8),
                            Text('Humidité', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: Colors.white)),
                            Container(height: 5),
                            Text("☔", style: TextStyle(fontSize: 30)),
                            Container(height: 5),
                            Text(hourlyData.RH2m.toString()+"%", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 12, color: Colors.white)), //Humidité
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(height: 10, child: Text('')),
                  Row (
                    children: <Widget>[
                      Container(
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.35),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0))
                        ),
                        width: 100,
                        height: 90,
                        child: Column (
                            children: <Widget>[
                              Container(height: 8),
                              Text('Vitesse vent', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: Colors.white)),
                              Container(height: 5),
                              Icon(FontAwesomeIcons
                                  .wind, size: 30,
                                  color: Colors.lightGreen),
                              //Text("🚩", style: TextStyle(fontSize: 30)),
                              Container(height: 5),
                              Text(hourlyData.WNDSPD10m.toString()+" km/h", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 12, color: Colors.white)),
                            ],
                          ),
                      ),
                      Container(width: 10, child: Text('')),
                      Container(
                        decoration: new BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.35),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0))
                        ),
                        width: 80,
                        height: 90,
                        child: Column (
                            children: <Widget>[ //
                              Container(height: 8),
                              Text('Orage', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, color: Colors.white)),
                              Container(height: 5),
                              Text("🌩", style: TextStyle(fontSize: 30)),
                              Container(height: 5),
                              Text(hourlyData.KINDEX.toString()+"%", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 12, color: Colors.white)),
                            ],
                          ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

    }
    return l;
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: !loading ? Container(
          height: 5000,
          width: 5000,
          color: Colors.white,
          child: Image.network(
              'https://cdn.discordapp.com/attachments/418499901215735808/663047823813640193/Logo.png'),
        ) :
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "https://cdn.discordapp.com/attachments/418499901215735808/662867597108183054/2Q.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(ci.name.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 22.0)),
                        Text(currentTime.toString(),
                            style: TextStyle(fontWeight: FontWeight.w300))
                      ],
                    ),
                  ),
                  Container(height: 30, child: Text('')),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(cond.condition.toString(), style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 20)),
                            Row(children: <Widget>[
                              Text(cond.tmp.toString() + '°', style: TextStyle(
                                  fontSize: 100.0,
                                  fontWeight: FontWeight.w300,
                              )),
                              Text('C', style: TextStyle(fontSize: 30.0))
                            ],),
                            Row(children: <Widget>[
                              Icon(FontAwesomeIcons.arrowUp, size: 15,
                                color: Colors.red,),
                              Text(fcst0.tmax.toString() + '°',
                                style: TextStyle(color: Colors.red),),
                              Icon(FontAwesomeIcons.arrowDown, size: 15,
                                color: Colors.lightBlueAccent,),
                              Text(fcst0.tmin.toString() + '°',
                                style: TextStyle(
                                    color: Colors.lightBlueAccent),),
                              Row(
                                children: <Widget>[
                                  Text('  '),
                                  Text('ressentie comme : ',
                                      style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.w300)),
                                  Text(currentHourlyData.WNDCHILL2m.toString() +
                                      '°', style: TextStyle(fontSize: 15,
                                      fontWeight: FontWeight.w300)),
                                ],
                              ),
                            ],)
                          ],
                        ),
                        Image.network(cond.iconBig.toString())
                      ],
                    ),
                  ),
                  Container(height: 20, child: Text('')),
                  Container(
                    height: 20,
                    width: 120,
                    decoration: new BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                        //new Color.fromRGBO(255, 0, 0, 0.0),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Prochaines 24h", style: TextStyle(color: Colors.amberAccent))
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      height: 130,
                      decoration: new BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          //new Color.fromRGBO(255, 0, 0, 0.0),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0))
                      ),
                      padding: EdgeInsets.all(5),
                      child: ListView(
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
                        Text('📅 PRÉVISIONS QUOTIDIENNES',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          padding: EdgeInsets.all(10),
                          decoration: new BoxDecoration(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              //new Color.fromRGBO(255, 0, 0, 0.0),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0))
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(fcst0.condition.toString() + " de " +
                                  fcst0.dayLong.toString() + " jusqu'à " +
                                  fcst1.dayLong.toString() + " matin",
                                  style: TextStyle(fontSize: 17,
                                      fontWeight: FontWeight.w200),
                                  textAlign: TextAlign.center),
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
                                      Container(
                                        width: 40,
                                        child: Column(
                                          children: <Widget>[
                                            Text("Ajd."),
                                            Text(fcst0.dateCalendar.toString())
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(width: 25),
                                  Container(
                                    width: 50,
                                    child: Image.network(fcst0.icon.toString())
                                  ),
                                  Container(width: 20),
                                  Container(
                                    width: 115,
                                    child: Text(fcst0.condition.toString())
                                  ),
                                  Container(width: 10),
                                  Row(
                                    children: <Widget>[
                                      Text(fcst0.tmin.toString() + '°',
                                          style: TextStyle(
                                              color: Colors.lightBlueAccent)),
                                      Text('| '),
                                      Text(fcst0.tmax.toString() + '°',
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                    ],
                                  ),
                                  IconButton(icon: Icon(Icons.arrow_forward_ios, color: Colors.white70), onPressed: popup0),
                                ],
                              ),
                              Container(height: 5),
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
                                      Container(
                                        width: 40,
                                        child: Column(
                                          children: <Widget>[
                                            Text(fcst1.dayShort.toString()),
                                            Text(fcst1.dateCalendar.toString())
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(width: 25),
                                  Container(
                                      width: 50,
                                      child: Image.network(fcst1.icon.toString())
                                  ),
                                  Container(width: 20),
                                  Container(
                                      width: 115,
                                      child: Text(fcst1.condition.toString())
                                  ),
                                  Container(width: 10),
                                  Row(
                                    children: <Widget>[
                                      Text(fcst1.tmin.toString() + '°',
                                          style: TextStyle(
                                              color: Colors.lightBlueAccent)),
                                      Text('| '),
                                      Text(fcst1.tmax.toString() + '°',
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                    ],
                                  ),
                                  IconButton(icon: Icon(Icons.arrow_forward_ios,
                                      color: Colors.white70), onPressed: popup1)
                                ],
                              ),
                              Container(height: 5),
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
                                      Container(
                                        width: 40,
                                        child: Column(
                                          children: <Widget>[
                                            Text(fcst2.dayShort.toString()),
                                            Text(fcst2.dateCalendar.toString())
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(width: 25),
                                  Container(
                                      width: 50,
                                      child: Image.network(fcst2.icon.toString())
                                  ),
                                  Container(width: 20),
                                  Container(
                                      width: 115,
                                      child: Text(fcst2.condition.toString())
                                  ),
                                  Container(width: 10),
                                  Row(
                                    children: <Widget>[
                                      Text(fcst2.tmin.toString() + '°',
                                          style: TextStyle(
                                              color: Colors.lightBlueAccent)),
                                      Text('| '),
                                      Text(fcst2.tmax.toString() + '°',
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                    ],
                                  ),
                                  IconButton(icon: Icon(Icons.arrow_forward_ios,
                                      color: Colors.white70), onPressed: popup2)
                                ],
                              ),
                              Container(height: 5),
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
                                      Container(
                                        width: 40,
                                        child: Column(
                                          children: <Widget>[
                                            Text(fcst3.dayShort.toString()),
                                            Text(fcst3.dateCalendar.toString())
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(width: 25),
                                  Container(
                                      width: 50,
                                      child: Image.network(fcst3.icon.toString())
                                  ),
                                  Container(width: 20),
                                  Container(
                                      width: 115,
                                      child: Text(fcst3.condition.toString())
                                  ),
                                  Container(width: 10),
                                  Row(
                                    children: <Widget>[
                                      Text(fcst3.tmin.toString() + '°',
                                          style: TextStyle(
                                              color: Colors.lightBlueAccent)),
                                      Text('| '),
                                      Text(fcst3.tmax.toString() + '°',
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                    ],
                                  ),
                                  IconButton(icon: Icon(Icons.arrow_forward_ios,
                                      color: Colors.white70), onPressed: popup3)
                                ],
                              ),
                              Container(
                                height: 0.25,
                                width: 400,
                                color: Colors.white30,
                                margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                              ),
                              Container(height: 30),
                              Container(
                                child: Text("Comparatif des températures",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w200),
                                        textAlign: TextAlign.center),
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    decoration: new BoxDecoration(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        //new Color.fromRGBO(255, 0, 0, 0.0),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                        )
                                    ),
                                    child: Container(
                                      width: 5000,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Column(children: <Widget>[
                                            Container(
                                              height: giveMeHeight(fcst0.tmin),
                                              width: 35,
                                              decoration: new BoxDecoration(
                                                  color: Color.fromRGBO(0, 200, 255, 0.40),
                                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)
                                                  )
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(fcst0.tmin.toString()+"°c"),
                                              ),
                                            ),
                                            Container(height: 5),
                                            Container(child: Text("Min", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10)))
                                          ]),
                                          Column(children: <Widget>[Container(width: 5)]),
                                          Column(children: <Widget>[
                                            Container(
                                              height: giveMeHeight(fcst0.tmax),
                                              width: 35,
                                              decoration: new BoxDecoration(
                                                  color: Color.fromRGBO(255, 0, 0, 0.35),
                                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)
                                                  )
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(fcst0.tmax.toString()+"°c"),
                                              ),
                                            ),
                                            Container(height: 5),
                                            Container(child: Text("Max", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10)))
                                          ]),
                                          Column(children: <Widget>[Container(width: 10)]),


                                          Column(children: <Widget>[
                                            Container(
                                              height: giveMeHeight(fcst1.tmin),
                                              width: 35,
                                              decoration: new BoxDecoration(
                                                  color: Color.fromRGBO(0, 200, 255, 0.40),
                                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)
                                                  )
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(fcst1.tmin.toString()+"°c"),
                                              ),
                                            ),
                                            Container(height: 5),
                                            Container(child: Text("Min", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10)))
                                          ]),
                                          Column(children: <Widget>[Container(width: 5)]),
                                          Column(children: <Widget>[
                                            Container(
                                              height: giveMeHeight(fcst1.tmax),
                                              width: 35,
                                              decoration: new BoxDecoration(
                                                  color: Color.fromRGBO(255, 0, 0, 0.35),
                                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)
                                                  )
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(fcst1.tmax.toString()+"°c"),
                                              ),
                                            ),
                                            Container(height: 5),
                                            Container(child: Text("Max", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10)))
                                          ]),
                                          Column(children: <Widget>[Container(width: 10)]),

                                          Column(children: <Widget>[
                                            Container(
                                              height: giveMeHeight(fcst2.tmin),
                                              width: 35,
                                              decoration: new BoxDecoration(
                                                  color: Color.fromRGBO(0, 200, 255, 0.40),
                                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)
                                                  )
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(fcst2.tmin.toString()+"°c"),
                                              ),
                                            ),
                                            Container(height: 5),
                                            Container(child: Text("Min", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10)))
                                          ]),
                                          Column(children: <Widget>[Container(width: 5)]),
                                          Column(children: <Widget>[
                                            Container(
                                              height: giveMeHeight(fcst2.tmax),
                                              width: 35,
                                              decoration: new BoxDecoration(
                                                  color: Color.fromRGBO(255, 0, 0, 0.35),
                                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)
                                                  )
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(fcst2.tmax.toString()+"°c"),
                                              ),
                                            ),
                                            Container(height: 5),
                                            Container(child: Text("Max", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10)))
                                          ]),
                                          Column(children: <Widget>[Container(width: 10)]),

                                          Column(children: <Widget>[
                                            Container(
                                              height: giveMeHeight(fcst3.tmin),
                                              width: 35,
                                              decoration: new BoxDecoration(
                                                  color: Color.fromRGBO(0, 200, 255, 0.40),
                                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)
                                                  )
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(fcst3.tmin.toString()+"°c"),
                                              ),
                                            ),
                                            Container(height: 5),
                                            Container(child: Text("Min", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10)))
                                          ]),
                                          Column(children: <Widget>[Container(width: 5)]),
                                          Column(children: <Widget>[
                                            Container(
                                              height: giveMeHeight(fcst3.tmax),
                                              width: 35,
                                              decoration: new BoxDecoration(
                                                  color: Color.fromRGBO(255, 0, 0, 0.35),
                                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0)
                                                  )
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(fcst3.tmax.toString()+"°c"),
                                              ),
                                            ),
                                            Container(height: 5),
                                            Container(child: Text("Max", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10)))
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: new BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.1),
                                    //new Color.fromRGBO(255, 0, 0, 0.0),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          decoration: new BoxDecoration(
                                              color: Color.fromRGBO(0, 0, 0, 0.30),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25.0),
                                                  topRight: Radius.circular(25.0),
                                                  bottomLeft: Radius.circular(25.0),
                                                  bottomRight: Radius.circular(25.0))
                                          ),
                                          alignment: Alignment.center,
                                          width: 70,
                                          height: 30,
                                          padding: EdgeInsets.all(5),
                                          child: Text(fcst0.dayShort.toString()),
                                        )
                                      ],
                                    ),
                                    Container(width: 15),
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          decoration: new BoxDecoration(
                                              color: Color.fromRGBO(0, 0, 0, 0.30),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25.0),
                                                  topRight: Radius.circular(25.0),
                                                  bottomLeft: Radius.circular(25.0),
                                                  bottomRight: Radius.circular(25.0))
                                          ),
                                          alignment: Alignment.center,
                                          width: 70,
                                          height: 30,
                                          padding: EdgeInsets.all(5),
                                          child: Text(fcst1.dayShort.toString()),
                                        )
                                      ],
                                    ),
                                    Container(width: 15),
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          decoration: new BoxDecoration(
                                              color: Color.fromRGBO(0, 0, 0, 0.30),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25.0),
                                                  topRight: Radius.circular(25.0),
                                                  bottomLeft: Radius.circular(25.0),
                                                  bottomRight: Radius.circular(25.0))
                                          ),
                                          alignment: Alignment.center,
                                          width: 70,
                                          height: 30,
                                          padding: EdgeInsets.all(5),
                                          child: Text(fcst2.dayShort.toString()),
                                        )
                                      ],
                                    ),
                                    Container(width: 15),
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          decoration: new BoxDecoration(
                                              color: Color.fromRGBO(0, 0, 0, 0.30),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25.0),
                                                  topRight: Radius.circular(25.0),
                                                  bottomLeft: Radius.circular(25.0),
                                                  bottomRight: Radius.circular(25.0))
                                          ),
                                          alignment: Alignment.center,
                                          width: 70,
                                          height: 30,
                                          padding: EdgeInsets.all(5),
                                          child: Text(fcst3.dayShort.toString()),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(height: 5)
                            ],
                          ),
                        ),
                        Container(height: 20, child: Text('')),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('🔎 DONNÉES ACTUELLES', style: TextStyle(
                                  fontWeight: FontWeight.w500)),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.all(10),
                                decoration: new BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.15),
                                    //new Color.fromRGBO(255, 0, 0, 0.0),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Text("Précipitation"),
                                        Container(height: 5, child: Text(' ')),
                                        precipitationIcon,
                                        Container(height: 10, child: Text(' ')),
                                        Text(currentHourlyData.APCPsfc
                                            .toString() + "mm",
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.w200))
                                      ],
                                    ),
                                    Container(
                                      height: 100.0,
                                      width: 0.5,
                                      color: Colors.white30,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text("Humidité"),
                                        Container(height: 5, child: Text(' ')),
                                        Text("☔ ", style: TextStyle(fontWeight: FontWeight.w300,fontSize: 30)),
                                        Container(height: 10, child: Text(' ')),
                                        Text(cond.humidity.toString() + "%",
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.w200))
                                      ],
                                    ),
                                    Container(
                                      height: 100.0,
                                      width: 0.5,
                                      color: Colors.white30,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text("Altitude"),
                                        Container(height: 5, child: Text(' ')),
                                        Text("⛰️",
                                            style: TextStyle(fontSize: 30)),
                                        Container(height: 10, child: Text(' ')),
                                        Text(ci.elevation.toString() + "m",
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.w200))
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
                                        Text('🌩',
                                            style: TextStyle(fontSize: 30)),
                                        Container(height: 10, child: Text(' ')),
                                        Text(currentHourlyData.KINDEX
                                            .toString() + "%", style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w200))
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
                              Text('💨 VENT & PRESSION EN CE MOMENT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.all(10),
                                decoration: new BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.15),
                                    //new Color.fromRGBO(255, 0, 0, 0.0),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    Text("🌬", style: TextStyle(fontSize: 100)),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[

                                        Row(
                                          children: <Widget>[
                                            Icon(FontAwesomeIcons.compass,
                                                size: 17, color: Colors.amber),
                                            Text("  " + cond.windDir.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight
                                                        .bold)),
                                          ],
                                        ),
                                        Container(height: 5, child: Text(' ')),
                                        Text("(Orientation du vent)",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w200,
                                                fontSize: 10)),
                                        Container(height: 10, child: Text(' ')),


                                        Row(
                                          children: <Widget>[
                                            Icon(FontAwesomeIcons.locationArrow,
                                                size: 15,
                                                color: Colors.lightBlueAccent),
                                            Text("  " +
                                                currentHourlyData.WNDDIR10m
                                                    .toString() + "°",
                                                style: TextStyle(
                                                    fontWeight: FontWeight
                                                        .bold)),
                                            // UPDATE windDir10m
                                          ],
                                        ),
                                        Container(height: 5, child: Text(' ')),
                                        Text("(Direction du vent)",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w200, fontSize: 10)),
                                        Container(height: 10, child: Text(' ')),

                                        Row(
                                          children: <Widget>[
                                            Text("🚩",
                                                style: TextStyle(fontSize: 15)),
                                            Text(
                                                " " + cond.windSpeed.toString() +
                                                    ' km/h', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Container(height: 5, child: Text(' ')),
                                        Text("(Vitesse du vent)",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w200, fontSize: 10)),
                                        Container(height: 10, child: Text(' ')),

                                        Row(
                                          children: <Widget>[
                                            Icon(FontAwesomeIcons
                                                .wind, size: 15,
                                                color: Colors.lightGreen),
                                            Text('  ' +
                                                cond.windGust.toString() + ' km/h',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold))
                                          ],
                                        ),
                                        Container(height: 5, child: Text(' ')),
                                        Text("(Vent en rafale)", style: TextStyle(
                                            fontWeight: FontWeight.w200, fontSize: 10)),
                                        Container(height: 10, child: Text(' ')),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text('Pression'),
                                        Container(height: 5, child: Text(' ')),
                                        Icon(FontAwesomeIcons.tachometerAlt,
                                          color: Colors.white,),
                                        Container(height: 5, child: Text(' ')),
                                        Text(cond.pressure.toString() + ' hPA',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w200)),
                                        Text('(' + (cond.pressure * 1.013)
                                            .floor()
                                            .toString() + ' Bar)',
                                            style: TextStyle(fontWeight: FontWeight.w200, fontSize: 12))
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('☀ SOLEIL', style: TextStyle(
                                  fontWeight: FontWeight.w500)),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.all(10),
                                decoration: new BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.15),
                                    //new Color.fromRGBO(255, 0, 0, 0.0),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Text("Sunrise"),
                                        Text("(levé du soleil)", style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w200)),
                                        Container(height: 5, child: Text(' ')),
                                        Text("🌅️",
                                            style: TextStyle(fontSize: 30)),
                                        Container(height: 10, child: Text(' ')),
                                        Text(ci.sunrise.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300)),
                                      ],
                                    ),
                                    Container(
                                      height: 100.0,
                                      width: 0.5,
                                      color: Colors.white30,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text("Sunset"),
                                        Text("(couché du soleil)", style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight
                                                .w200)),
                                        Container(height: 5, child: Text(' ')),
                                        Text("🌇️",
                                            style: TextStyle(fontSize: 30)),
                                        Container(height: 10, child: Text(' ')),
                                        Text(ci.sunset.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300)),
                                      ],
                                    ),
                                    Container(
                                      height: 100.0,
                                      width: 0.5,
                                      color: Colors.white30,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text("Temps restant"),
                                        Container(height: 5, child: Text(' ')),
                                        Text("⌛️",
                                            style: TextStyle(fontSize: 30)),
                                        Container(height: 10, child: Text(' ')),
                                        Text(diff,
                                            style: TextStyle(
                                                fontWeight: FontWeight
                                                    .w300)),
                                        Text("(de soleil pour aujourd'hui)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w200))
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(height: 40, child: Text('')),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text("(Développé par Braud Nicolas - Chauny Dylan - Clément Fouret)",
                                  style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14.0),
                                  textAlign: TextAlign.center
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