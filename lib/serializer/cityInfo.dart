class CityInfo {
  final String name, country, latitude, longitude, elevation, sunrise, sunset;

  CityInfo.fromJson(Map<String, dynamic> json):
        name = json['name'],
        country = json['country'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        elevation = json['elevation'],
        sunrise = json['sunrise'],
        sunset = json['sunset'];
}
