List<hourly> hourlyDataList = new List();

class hourly {
  var ICON, CONDITION, WNDDIRCARD10, TMP2m, data;

  hourly.fromJson(Map<String, dynamic> json):
        ICON = json['ICON'],
        CONDITION = json['CONDITION'],
        WNDDIRCARD10 = json['WNDDIRCARD10'],
        TMP2m = json['TMP2m'];
}

class fcstDay {
  var date, dayShort, dayLong, tmin, tmax, condition, conditionKey, icon, iconBig, hourlyData;

  fcstDay.fromJson(Map<String, dynamic> json):
        date = json['date'],
        dayShort = json['day_short'],
        dayLong = json['day_long'],
        tmin = json['tmin'],
        tmax = json['tmax'],
        condition = json['condition'],
        conditionKey = json['condition_key'],
        icon = json['icon'],
        iconBig = json['icon_big'],
        hourlyData = json['hourly_data'];
}