import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pref/pref.dart';
// ignore: depend_on_referenced_packages
import 'package:rss_aggregator_flutter/core/utility.dart';
import 'package:rss_aggregator_flutter/theme/theme_color.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;

  //Theme
  static bool darkMode = false;

  int linesCustomBlacklist = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setLinesCustomBlacklist(String? value) {
    value ??= PrefService.of(context).get('settings_blacklist_custom');
    setState(() {
      linesCustomBlacklist =
          value.toString().length > 10 && value.toString().contains(";")
              ? 10
              : 1;
    });
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setLinesCustomBlacklist(null);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColor().darken(ThemeColor.dark2, 20)
            : ThemeColor.light1.withAlpha(75),
        child: PrefPage(
          children: [
            if (_selectedIndex == 0)
              const PrefTitle(
                title: Text('Personalization'),
                subtitle: Text('Customize colors'),
                padding: EdgeInsets.only(right: 25, top: 15),
              ),
            //REMOVED BECAUSE COLOR IS NOW LINKED TO SELECTED CATEGORY
            /*const PrefDropdown<int>(
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
          ),*/
            if (_selectedIndex == 0)
              const PrefDropdown<String>(
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
            if (_selectedIndex == 0)
              const PrefTitle(
                title: Text('Configuration'),
                subtitle: Text('Customize parameters'),
                padding: EdgeInsets.only(right: 25, top: 15),
              ),

            if (_selectedIndex == 0)
              const PrefDropdown<int>(
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
                  DropdownMenuItem(value: 0, child: Text('All')),
                ],
              ),
            if (_selectedIndex == 0)
              const PrefDropdown<int>(
                title: Text('Feed limit'),
                pref: 'settings_feeds_limit',
                subtitle: Text('Max number of feed to fetch per each site'),
                fullWidth: false,
                items: [
                  DropdownMenuItem(value: 1, child: Text('1 feed')),
                  DropdownMenuItem(value: 2, child: Text('2 feeds')),
                  DropdownMenuItem(value: 5, child: Text('5 feeds')),
                  DropdownMenuItem(value: 10, child: Text('10 feeds')),
                  DropdownMenuItem(value: 20, child: Text('20 feeds')),
                  DropdownMenuItem(value: 100, child: Text('100 feeds')),
                  DropdownMenuItem(value: 0, child: Text('All')),
                ],
              ),
            if (_selectedIndex == 0)
              const PrefDropdown<int>(
                title: Text('Refresh on start'),
                pref: 'settings_refresh_after',
                subtitle: Text('Auto refresh on start after a specific time'),
                fullWidth: false,
                items: [
                  DropdownMenuItem(value: 0, child: Text('Always')),
                  DropdownMenuItem(value: 10, child: Text('10 min')),
                  DropdownMenuItem(value: 30, child: Text('30 min')),
                  DropdownMenuItem(value: 60, child: Text('1 hour')),
                  DropdownMenuItem(value: 240, child: Text('4 hours')),
                  DropdownMenuItem(value: 720, child: Text('12 hours')),
                  DropdownMenuItem(value: 1440, child: Text('24 hours')),
                  DropdownMenuItem(value: -1, child: Text('Never')),
                ],
              ),
            if (_selectedIndex == 1)
              const PrefTitle(
                title: Text('Network'),
                subtitle: Text('Customize parameters'),
                padding: EdgeInsets.only(right: 25, top: 15),
              ),
            if (_selectedIndex == 1)
              const PrefDropdown<int>(
                title: Text('Timeout'),
                pref: 'settings_network_timeout',
                subtitle: Text('Customize parameters'),
                fullWidth: false,
                items: [
                  DropdownMenuItem(value: 2, child: Text('2 seconds')),
                  DropdownMenuItem(value: 4, child: Text('4 seconds')),
                  DropdownMenuItem(value: 8, child: Text('8 seconds')),
                  DropdownMenuItem(value: 16, child: Text('16 seconds')),
                ],
              ),
            if (_selectedIndex == 1)
              const PrefDropdown<int>(
                title: Text('Connection delay'),
                pref: 'settings_network_delay',
                subtitle: Text('Customize parameters'),
                fullWidth: false,
                items: [
                  DropdownMenuItem(value: 10, child: Text('10 ms')),
                  DropdownMenuItem(value: 50, child: Text('50 ms')),
                  DropdownMenuItem(value: 100, child: Text('100 ms')),
                  DropdownMenuItem(value: 200, child: Text('200 ms')),
                  DropdownMenuItem(value: 500, child: Text('500 ms')),
                  DropdownMenuItem(value: 1000, child: Text('1000 ms')),
                ],
              ),
            if (_selectedIndex == 1)
              const PrefDropdown<int>(
                title: Text('Connections simultaneous'),
                pref: 'settings_network_simultaneous',
                subtitle: Text('Customize parameters'),
                fullWidth: false,
                items: [
                  DropdownMenuItem(value: 1, child: Text('1')),
                  DropdownMenuItem(value: 2, child: Text('2')),
                  DropdownMenuItem(value: 4, child: Text('4')),
                  DropdownMenuItem(value: 8, child: Text('8')),
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 20, child: Text('20')),
                ],
              ),
            if (_selectedIndex == 2)
              const PrefTitle(
                title: Text('Blacklist'),
                subtitle: Text('Customize parameters'),
                padding: EdgeInsets.only(right: 25, top: 15),
              ),
            if (_selectedIndex == 2)
              PrefCheckbox(
                title: const Text('Parental block'),
                subtitle: const Text('Block unwanted content'),
                pref: 'settings_blacklist_parental',
                onChange: (value) {
                  if (!value) {
                    PrefService.of(context)
                        .set('settings_blacklist_parental', false);
                  }
                },
              ),
            if (_selectedIndex == 2)
              PrefText(
                hintText: 'Enter keywords list. e.g: WORD1;WORD2;WORD3',
                label: 'Custom blocklist',
                pref: 'settings_blacklist_custom',
                keyboardType: TextInputType.multiline,
                onChange: (value) => setLinesCustomBlacklist(value),
                maxLines: linesCustomBlacklist,
                validator: (str) {
                  if (str != null && str.length > 10 && !str.contains(';')) {
                    return 'Enter keyword separated by ;';
                  }
                  return null;
                },
              ),
            if (_selectedIndex == 3)
              const PrefTitle(
                  title: Text('Storage'),
                  subtitle: Text('Customize parameters'),
                  padding: EdgeInsets.only(right: 25, top: 15)),
            if (_selectedIndex == 3)
              PrefCheckbox(
                title: const Text('Load images'),
                subtitle: const Text('Fetch image from network'),
                pref: 'settings_load_images',
                onChange: (value) {
                  setState(() {});
                  if (!value) {
                    PrefService.of(context).set('settings_load_images', false);
                  }
                },
              ),
            if (_selectedIndex == 3)
              PrefLabel(
                title: const Text(
                  'Clear cache',
                ),
                subtitle: const Text('Delete temp files'),
                onTap: () {
                  SnackBar snackBar;
                  Utility().clearCache().then((value) => {
                        snackBar = const SnackBar(
                          duration: Duration(milliseconds: 1000),
                          content: Text('Cache cleaned'),
                        ),
                        ScaffoldMessenger.of(context).showSnackBar(snackBar),
                      });
                },
              ),
            if (_selectedIndex == 3)
              PrefLabel(
                title: const Text(
                  'Reset default settings',
                ),
                subtitle: const Text('Delete all data. App will be closed.'),
                onTap: () {
                  SnackBar snackBar;
                  Utility().clearData().then((value) => {
                        snackBar = const SnackBar(
                          duration: Duration(milliseconds: 2500),
                          content: Text('Data cleaned. Chiusura in corso.'),
                        ),
                        ScaffoldMessenger.of(context).showSnackBar(snackBar),
                        Future.delayed(const Duration(seconds: 3)).then(
                            (value) => {
                                  SystemChannels.platform
                                      .invokeMethod('SystemNavigator.pop'),
                                  exit(0)
                                })
                      });
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 5, right: 5),
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColor.dark2
            : Colors.white,
        child: BottomNavigationBar(
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.network_cell),
              label: 'Network',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security),
              label: 'Security',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storage),
              label: 'Storage',
            ),
          ],
          //elevation: 8,
          currentIndex: _selectedIndex,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? ThemeColor.dark2
              : Colors.white,
          selectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[100]
              : Colors.blueGrey[800],
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.blueGrey[200]
              : Colors.blueGrey[600],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed, // Fixed
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
