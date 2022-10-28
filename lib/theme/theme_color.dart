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

  static MaterialColor primaryColorDark = const MaterialColor(0xFFAAAAAA, {
    50: Color(0xFFAAAAAA),
    100: Color(0xFFAAAAAA),
    200: Color(0xFFAAAAAA),
    300: Color(0xFFAAAAAA),
    400: Color(0xFFAAAAAA),
    500: Color(0xFFAAAAAA),
    600: Color(0xFFAAAAAA),
    700: Color(0xFFAAAAAA),
    800: Color(0xFFAAAAAA),
    900: Color(0xFFAAAAAA)
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
    } catch (err) {
      // print('Caught error: $err');
    }
    return false;
  }

  int defaultCategoryColor = Colors.blueGrey[900]!.value;

  List<ColorSwatch<dynamic>> getColorPicker() {
    List<ColorSwatch<dynamic>> pickerColorSwatch = [];
    for (Color color in pickerColors) {
      pickerColorSwatch.add(ThemeColor().createMaterialColor(color));
    }
    return pickerColorSwatch;
  }

  static Color light1 = const Color.fromARGB(255, 238, 238, 238);
  static Color light2 = const Color.fromARGB(255, 205, 205, 205);
  static Color light3 = const Color.fromARGB(255, 160, 160, 160);
  static Color light4 = const Color.fromARGB(255, 140, 140, 140);

  static Color dark1 = const Color.fromARGB(255, 10, 10, 10);
  static Color dark2 = const Color.fromARGB(255, 25, 25, 25);
  static Color dark3 = const Color.fromARGB(255, 65, 65, 65);
  static Color dark4 = const Color.fromARGB(255, 130, 130, 130);

  List<Color> pickerColors = [
    Colors.green,
    Colors.green[700]!,
    Colors.teal[800]!,
    Colors.cyan[800]!,
    Colors.lightBlue[800]!,
    Colors.blue[900]!,
    Colors.indigo[900]!,
    Colors.deepPurple[900]!,
    Colors.purple[900]!,
    Colors.purple[700]!,
    Colors.pink[800]!,
    Colors.red[800]!,
    Colors.deepOrange[800]!,
    Colors.orange[800]!,
    Colors.amber[800]!,
    Colors.yellow[800]!,
    Colors.brown[800]!,
    Colors.blueGrey[900]!,
    Colors.blueGrey[700]!,
    Colors.blueGrey[500]!,
  ];

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
