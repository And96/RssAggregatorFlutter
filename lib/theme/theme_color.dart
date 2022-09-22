import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/scheduler.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/scheduler.dart';

class ThemeColor {
  //alterntive color: 0xFF 283593

  static MaterialColor primaryColorLight = const MaterialColor(0xFF004d40, {
    50: Color(0xFF004d40),
    100: Color(0xFF004d40),
    200: Color(0xFF004d40),
    300: Color(0xFF004d40),
    400: Color(0xFF004d40),
    500: Color(0xFF004d40),
    600: Color(0xFF004d40),
    700: Color(0xFF004d40),
    800: Color(0xFF004d40),
    900: Color(0xFF004d40)
  });

  static MaterialColor primaryColorDark = const MaterialColor(0xFFaaaaaa, {
    50: Color(0xFFaaaaaa),
    100: Color(0xFFaaaaaa),
    200: Color(0xFFaaaaaa),
    300: Color(0xFFaaaaaa),
    400: Color(0xFFaaaaaa),
    500: Color(0xFFaaaaaa),
    600: Color(0xFFaaaaaa),
    700: Color(0xFFaaaaaa),
    800: Color(0xFFaaaaaa),
    900: Color(0xFFaaaaaa)
  });

  static Future<bool> isDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsUiTheme = prefs.getString('settings_ui_theme');
      if (settingsUiTheme == 'dark') {
        return true;
      }
      if (settingsUiTheme == 'system') {
        var brightness = SchedulerBinding.instance.window.platformBrightness;
        bool dark = brightness == Brightness.dark;
        return dark;
      }
      /*
      var brightness = MediaQuery.of(context).platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;*/
/*
//QUESTO RESTITUISCE LA MODALITA DI SISTEMA NON LA MODALITA ATTUALE
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;*/
      // return isDarkMode;

    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

//NOONE REFRESH WHEN SYSTEM THEME IS CHANGED
  /*static bool isDarkMode(BuildContext context) {
    try {
       var brightness = MediaQuery.of(context).platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
     /* var brightness = SchedulerBinding.instance.window.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;*/
      return isDarkMode;
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }*/

}
