import 'package:flutter/material.dart';
import 'package:rss_aggregator_flutter/screens/home_page.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';
import 'package:rss_aggregator_flutter/theme/brightness_notifier.dart';
import 'dart:async';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pref/pref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final service = await PrefServiceShared.init(
    defaults: {
      'settings_ui_theme': 'light',
      'settings_ui_color': ThemeColor.primaryColorLight,
      'settings_network_timeout': 8,
      'settings_network_delay': 50,
      'settings_network_simultaneous': 10,
      'settings_days_limit': 90,
      'settings_feeds_limit': 20,
      'settings_refresh_after': 60,
      'settings_load_images': true,
      'settings_blacklist_parental': true,
      'settings_blacklist_custom': '',
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
      child: BrightnessNotifier(
        onBrightnessChanged: () {
          setState(() {});
          Phoenix.rebirth(context);
        },
        child: MaterialApp(
          title: 'Aggregator',
          themeMode: _themeBrightness,
          theme: ThemeData(
            useMaterial3: false,
            listTileTheme: const ListTileThemeData(iconColor: Colors.black54),
            primarySwatch:
                ThemeColor().createMaterialColor(ThemeColor.primaryColorLight),
          ),
          darkTheme: ThemeData.dark().copyWith(
            useMaterial3: false,
            drawerTheme: DrawerThemeData(
              backgroundColor: ThemeColor.dark2,
            ),
            cardColor: ThemeColor.dark2,
            dialogBackgroundColor: ThemeColor.dark2,
            backgroundColor: ThemeColor.dark2,
            scaffoldBackgroundColor: ThemeColor.dark2,
            colorScheme: ColorScheme.fromSeed(
                seedColor: _themePrimaryColor!, brightness: Brightness.dark),
            brightness: Brightness.dark,
            listTileTheme: ListTileThemeData(tileColor: ThemeColor.dark2),
            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateColor.resolveWith(
                (states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blueGrey;
                  }
                  return Colors.white;
                },
              ),
            ),
            dividerTheme: DividerThemeData(
              color: ThemeColor.dark3,
            ),
          ),
          home: const MyHomePage(),
        ),
      ),
    );
  }
}
