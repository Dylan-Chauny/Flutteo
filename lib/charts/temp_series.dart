import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';

class tempSeries {
  final String houre;
  final int temp;
  final charts.Color barColor;

  tempSeries({
    @required this.houre,
    @required this.temp,
    @required this.barColor});
}