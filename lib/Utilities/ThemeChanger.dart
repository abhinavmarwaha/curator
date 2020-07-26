import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;
  bool _darkMode;

  ThemeChanger() {
    _themeData = ThemeData.light();
    getDarkModePlain().then((value) {
      _themeData = value;
    });
  }

  ThemeData getTheme() => _themeData;
  bool getDarkModeVar() => _darkMode;
  setTheme(ThemeData theme) {
    _themeData = theme;

    notifyListeners();
  }

  getDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('darkMode'))
      _darkMode = prefs.getBool('darkMode');
    else {
      await prefs.setBool('darkMode', false);
      _darkMode = false;
    }

    getThemeFromBool();
    notifyListeners();
    return _themeData;
  }

  setDarkMode(bool inp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', inp);
    _darkMode = inp;
    getThemeFromBool();
    notifyListeners();
  }

  getThemeFromBool() {
    if (_darkMode) {
      _themeData = ThemeData.dark();
    } else {
      _themeData = ThemeData.light();
    }
  }

  Future<ThemeData> getDarkModePlain() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool darkMode;
    if (prefs.containsKey('darkMode'))
      darkMode = prefs.getBool('darkMode');
    else {
      await prefs.setBool('darkMode', false);
      darkMode = false;
    }
    ThemeData themeData;
    if (darkMode) {
      themeData = ThemeData.dark();
    } else {
      themeData = ThemeData.light();
    }
    return themeData;
  }

  static Future<bool> getDarkModePlainBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool darkMode;
    if (prefs.containsKey('darkMode'))
      darkMode = prefs.getBool('darkMode');
    else {
      await prefs.setBool('darkMode', false);
      darkMode = false;
    }
    return darkMode;
  }
}
