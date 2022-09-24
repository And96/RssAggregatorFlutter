import 'package:flutter/material.dart';
import 'package:pref/pref.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const PrefPage(
        children: [
          PrefTitle(
              title: Text('Configuration'),
              subtitle: Text('Customize parameters'),
              padding: EdgeInsets.only(top: 22.0)),
          PrefDropdown<int>(
            title: Text('Timeout'),
            pref: 'settings_timeout',
            subtitle: Text('Customize parameters'),
            fullWidth: false,
            items: [
              DropdownMenuItem(value: 1, child: Text('1 second')),
              DropdownMenuItem(value: 2, child: Text('2 seconds')),
              DropdownMenuItem(value: 4, child: Text('4 seconds')),
              DropdownMenuItem(value: 8, child: Text('8 seconds')),
              DropdownMenuItem(value: 8, child: Text('16 seconds')),
            ],
          ),
          PrefDropdown<int>(
            title: Text('Days limit'),
            pref: 'settings_days_limit',
            subtitle: Text('Customize parameters'),
            fullWidth: false,
            items: [
              DropdownMenuItem(value: 1, child: Text('1 day')),
              DropdownMenuItem(value: 2, child: Text('2 days')),
              DropdownMenuItem(value: 3, child: Text('3 days')),
              DropdownMenuItem(value: 7, child: Text('7 days')),
              DropdownMenuItem(value: 30, child: Text('30 days')),
              DropdownMenuItem(value: 90, child: Text('90 days')),
              DropdownMenuItem(value: 365, child: Text('365 days')),
            ],
          ),
          PrefDropdown<int>(
            title: Text('Feed limit'),
            pref: 'settings_feeds_limit',
            subtitle: Text('Max number of feed to fetch per each site'),
            fullWidth: false,
            items: [
              DropdownMenuItem(value: 1, child: Text('1 feed')),
              DropdownMenuItem(value: 2, child: Text('2 feeds')),
              DropdownMenuItem(value: 3, child: Text('3 feeds')),
              DropdownMenuItem(value: 5, child: Text('5 feeds')),
              DropdownMenuItem(value: 10, child: Text('10 feeds')),
              DropdownMenuItem(value: 20, child: Text('20 feeds')),
              DropdownMenuItem(value: 0, child: Text('All')),
            ],
          ),
          PrefTitle(
            title: Text('Personalization'),
            subtitle: Text('Customize colors'),
            padding: EdgeInsets.only(top: 22.0),
          ),
          PrefDropdown<int>(
            title: Text('Color'),
            pref: 'settings_ui_color',
            subtitle: Text('Customize parameters'),
            fullWidth: false,
            items: [
              DropdownMenuItem(value: (0x004d40), child: Text('Green')),
              DropdownMenuItem(value: (0x1055AA), child: Text('Blue')),
              DropdownMenuItem(value: (0xB71C1C), child: Text('Red')),
              DropdownMenuItem(value: (0XFFAB00), child: Text('Brown')),
              DropdownMenuItem(value: (0x252270), child: Text('Violet')),
            ],
          ),
          PrefDropdown<String>(
            title: Text('Theme'),
            pref: 'settings_ui_theme',
            subtitle: Text('Customize parameters'),
            fullWidth: false,
            items: [
              DropdownMenuItem(value: 'system', child: Text('System')),
              DropdownMenuItem(value: 'light', child: Text('Light')),
              DropdownMenuItem(value: 'dark', child: Text('Dark')),
            ],
          ),
        ],
      ),
    );
  }
}
