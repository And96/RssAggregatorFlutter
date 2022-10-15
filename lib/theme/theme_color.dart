import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeColor {
  //alterntive color: 0xFF 283593

  static MaterialColor primaryColorLight = const MaterialColor(0xFF233238, {
    50: Color(0xFF233238),
    100: Color(0xFF233238),
    200: Color(0xFF233238),
    300: Color(0xFF233238),
    400: Color(0xFF233238),
    500: Color(0xFF233238),
    600: Color(0xFF233238),
    700: Color(0xFF233238),
    800: Color(0xFF233238),
    900: Color(0xFF233238)
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

  int defaultCategoryColor = Colors.blueGrey[600]!.value;

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
