import 'package:flutteo/main.dart';
import 'package:flutter/material.dart';

class Jour3 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(!getData) {
            return Container(
              child: Center(
                child: Text("Loading..."), //Splash Screen à mettre
              ),
            );
          } else {
            return Container (
              child: Column(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(fcst2.dayShort.toString()),
                      Text(fcst2.dayLong.toString()),
                      Text(fcst2.date.toString() + " | " + cond.hour.toString()),
                      Text("Temp min: " + fcst2.tmin.toString()+"°"),
                      Text("Temp max: " + fcst2.tmax.toString()+"°"),
                      Text("Vent mesuré à -- km/h"),
                      Text("Pression --"),
                      Text("Humidité --"),
                      Text(" -- °", style:TextStyle(fontSize: 80.00),),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Image.network(cond.iconBig.toString()),
                      Text(cond.condition.toString()),
                      Text(ci.country),
                      Text("Sunrise: --"),
                      Text("Sunset: --"),
                      Text("Elevation: --"),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Image.network(iconsTest),
                              Text("15°"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Image.network(iconsTest),
                              Text('18°')
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Image.network(iconsTest),
                              Text('14°')
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Image.network(iconsTest),
                              Text('11°')
                            ],
                          ),
                        ),Expanded(
                          child: Column(
                            children: <Widget>[
                              Image.network(iconsTest),
                              Text('19°')
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Image.network(iconsTest),
                              Text('12°')
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}