//Créer une liste des heurezs
//Parcouris pour chaque heure les infos ci dessous
class hourly {
  var ICON, CONDITION, WNDDIRCARD10, TMP2m, DPT2m, WNDCHILL2m, RH2m, PRMSL, APCPsfc, WNDGUST10m, WNDDIR10m, WNDSPD10m, ISSNOW, KINDEX;

  hourly.fromJson(Map<String, dynamic> json):
        ICON = json['ICON'],
        CONDITION = json['CONDITION'],
        WNDDIRCARD10 = json['WNDDIRCARD10'],
        WNDSPD10m = json['WNDSPD10m'],
        TMP2m = json['TMP2m'],
        DPT2m = json['DPT2m'],
        WNDCHILL2m = json['WNDCHILL2m'],
        RH2m = json['RH2m'],
        PRMSL = json['PRMSL'],
        APCPsfc = json['APCPsfc'],
        WNDGUST10m = json['WNDGUST10m'],
        WNDDIR10m = json['WNDDIR10m'],
        ISSNOW = json['ISSNOW'],
        KINDEX = json['KINDEX'];
}