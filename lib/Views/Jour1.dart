import 'package:flutteo/main.dart';
import 'package:flutter/material.dart';

class Jour1 extends StatelessWidget{
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
                            Text(fcst0.dayShort.toString()),
                            Text(fcst0.dayLong.toString()),
                            Text(cond.date.toString() + " | " + cond.hour.toString()),
                            Text("Temp min: " + fcst0.tmin.toString()+"°"),
                            Text("Temp max: " + fcst0.tmax.toString()+"°"),
                            Text("Vent mesuré à "+ cond.windSpeed.toString() + " km/h"),
                            Text("Pression " + cond.pressure.toString()),
                            Text("Humidité " + cond.humidity.toString()),
                            Text(cond.tmp.toString()+"°", style:TextStyle(fontSize: 80.00),),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Image.network(cond.iconBig.toString()),
                            Text(cond.condition.toString()),
                            Text(ci.country),
                            Text("Sunrise: " + ci.sunrise),
                            Text("Sunset: " + ci.sunset),
                            Text("Elevation: " + ci.elevation),
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