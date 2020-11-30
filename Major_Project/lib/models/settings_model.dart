import 'package:flutter/material.dart';
import 'package:major_project/data/themes/blue_theme.dart';
import 'package:major_project/data/themes/dark_theme.dart';
import 'package:major_project/data/themes/sunset_theme.dart';

class Settings with ChangeNotifier {
  String theme;
  ThemeData _themeData;
  //todo: more settings
  Settings(this.theme);

  Settings.fromMap(Map<String, dynamic> map) {
    this.theme = map['theme'];
    setTheme(parseTheme(theme));
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': this.theme,
    };
  }

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }

  ThemeData parseTheme(String theme){
    switch (theme) {
      case "blueTheme": return blueTheme;
        break;
      case "darkTheme": return darkTheme;
        break;
      case "sunsetTheme":return sunsetTheme;
        break;
      default: return blueTheme;
    }
  }
}