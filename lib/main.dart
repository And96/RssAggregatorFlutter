import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/screens/home_page.dart';
//import 'package:rss_aggregator_flutter/utilities/sites_icon.dart';
// ignore: depend_on_referenced_packages
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'dart:async';
import 'package:flutter_phoenix/flutter_phoenix.dart';
// ignore: depend_on_referenced_packages
//import 'package:rss_aggregator_flutter/theme/theme_color.dart';

// ignore: depend_on_referenced_packages
import 'package:pref/pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final service = await PrefServiceShared.init(
    defaults: {
      'settings_ui_theme': 'light',
      'settings_ui_color': ThemeColor.primaryColorLight,
      'settings_timeout': 8,
      'settings_days_limit': 90,
      'settings_feeds_limit': 20,
      'settings_load_images': true,
    },
  );

  runApp(
    Phoenix(
      child: MyApp(service),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp(this.service, {Key? key}) : super(key: key);
  final BasePrefService service;
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Color? _themePrimaryColor = ThemeColor.primaryColorLight;
  ThemeMode? _themeBrightness;
  StreamSubscription<String>? _streamThemeBrightness;
  StreamSubscription<int?>? _streamThemePrimaryColor;

  @override
  void dispose() {
    _streamThemeBrightness?.cancel();
    _streamThemePrimaryColor?.cancel();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _streamThemeBrightness ??=
        widget.service.stream<String>('settings_ui_theme').listen((event) {
      setState(() {
        switch (event) {
          case 'system':
            _themeBrightness = ThemeMode.system;
            break;
          case 'light':
            _themeBrightness = ThemeMode.light;
            break;
          case 'dark':
            _themeBrightness = ThemeMode.dark;
            break;
        }
      });
    });

    _streamThemePrimaryColor ??=
        widget.service.stream<int?>('settings_ui_color').listen((event) {
      setState(() {
        _themePrimaryColor = event == null ? null : Color(event);
      });
    });

    return PrefService(
      service: widget.service,
      child: MaterialApp(
        title: 'Aggregator',
        themeMode: _themeBrightness,
        /*theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _themePrimaryColor!,
            brightness: Brightness.light,
          ),
        ),*/
        theme: ThemeData(
          primarySwatch:
              ThemeColor().createMaterialColor(ThemeColor.primaryColorLight),
        ),
        darkTheme: ThemeData.dark().copyWith(
          drawerTheme: DrawerThemeData(
            backgroundColor: Color.fromARGB(255, 16, 16, 16),
          ),
          cardColor: Color.fromARGB(255, 16, 16, 16),
          dialogBackgroundColor: Color.fromARGB(255, 16, 16, 16),
          backgroundColor: Color.fromARGB(255, 16, 16, 16),
          scaffoldBackgroundColor: Color.fromARGB(255, 16, 16, 16),
          colorScheme: ColorScheme.fromSeed(
              seedColor: _themePrimaryColor!, brightness: Brightness.dark),
          brightness: Brightness.dark,
          listTileTheme:
              ListTileThemeData(tileColor: Color.fromARGB(255, 16, 16, 16)),
          dividerTheme: DividerThemeData(
            color: Color.fromARGB(255, 30, 30, 30),
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
