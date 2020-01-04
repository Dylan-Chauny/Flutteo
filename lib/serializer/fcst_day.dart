List<hourly> hourlyDataList = new List();

//Créer une liste des heurezs
//Parcouris pour chaque heure les infos ci dessous
class hourly {
  var ICON, CONDITION, WNDDIRCARD10, TMP2m, DPT2m, WNDCHILL2m, RH2m, PRMSL, APCPsfc, WNDGUST10m, WNDDIR10m, ISSNOW, KINDEX;

  hourly.fromJson(Map<String, dynamic> json):
        ICON = json['ICON'],
        CONDITION = json['CONDITION'],
        WNDDIRCARD10 = json['WNDDIRCARD10'],
        TMP2m = json['TMP2m'],
        DPT2m = json['DPTM2m'],
        WNDCHILL2m = json['WNDCHILL2m'],
        RH2m = json['RH2m'],
        PRMSL = json['PRMSL'],
        APCPsfc = json['APCPsfc'],
        WNDGUST10m = json['WNDGUST10m'],
        WNDDIR10m = json['WNDDIR10m'],
        ISSNOW = json['ISSNOW'],
        KINDEX = json['KINDEX'];
}

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
        hourlyData = json['hourly_data'],
        dateCalendar = json['date'].toString().substring(1,5).replaceAll(".", "/");
}