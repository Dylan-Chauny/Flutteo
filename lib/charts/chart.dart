import 'package:flutteo/charts/temp_series.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Chart extends StatelessWidget{
  final List<tempSeries> data;
  Chart({@required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<tempSeries, String>> series = [
      charts.Series(
        id: "Test",
        data: data,
        domainFn: (tempSeries series, _) =>
            series.houre,
        measureFn: (tempSeries series, _) =>
            series.temp,
        colorFn: (tempSeries series, _) =>
            series.barColor)
    ];

    return charts.BarChart(series, animate: true);
  }
}