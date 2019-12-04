class CurrentCondition {
  final String date, hour, windSpeed, windGust, windDir, pressure, humidity, condition, conditionKey, icon, iconBig;
  final int tmp;


  CurrentCondition.fromJson(Map<String, dynamic> json):
      //Int
      tmp = json['tmp'],
      //String
      date = json['date'],
      hour = json['hour'],
      windSpeed = json['wnd_spd'],
      windGust = json['wnd_gust'],
      windDir = json['wnd_dir'],
      pressure = json['pressure'],
      humidity = json['humidity'],
      condition = json['condition'],
      conditionKey = json['condition_key'],
      icon = json['icon'],
      iconBig = json['icon_big'];
}