class fcstDay {
  var date, dayShort, dayLong, tmin, tmax, condition, conditionKey, icon, iconBig, hourlyData, dateCalendar;

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
        //hourlyData = hourly.fromJson(json['hourly_data']),
        dateCalendar = json['date'].toString().substring(1,5).replaceAll(".", "/");
}