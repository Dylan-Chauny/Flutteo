List<hourlyData> hourlyDataList = new List();

class fscDay {
  var date, dayShort, dayLong, tmin, tmax, condition, conditionKey, icon, iconBig;

  fscDay.fromJson(Map<String, dynamic> json):
        date = json['date'],
        dayShort = json['dayShort'],
        dayLong = json['dayLong'],
        tmin = json['wnd_gust'],
        tmax = json['wnd_dir'],
        condition = json['pressure'],
        conditionKey = json['humidity'],
        icon = json['condition'],
        iconBig = json['icon_big'];

}

class hourlyData {
  var ICON, CONDITION, WNDDIRCARD10, TMP2m, data;


  hourlyData.fromJson(Map<String, dynamic> json):
        ICON = json['ICON'],
        CONDITION = json['CONDITION'],
        WNDDIRCARD10 = json['WNDDIRCARD10'],
        TMP2m = json['TMP2m'];

  
}