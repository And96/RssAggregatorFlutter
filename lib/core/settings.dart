import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  String settingsUiTheme = '';
  int settingsNetworkTimeout = 0;
  int settingsNetworkDelay = 0;
  int settingsNetworkSimultaneous = 0;
  int settingsFeedsLimit = 0;
  int settingsDaysLimit = 0;
  bool settingsLoadImages = true;
  bool settingsBlacklistParental = true;
  String settingsBlacklistCustom = '';

  Settings();

  Future init() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      settingsUiTheme = (prefs.getString('settings_ui_theme'))!;
      settingsNetworkTimeout = (prefs.getInt('settings_network_timeout'))!;
      settingsNetworkDelay = (prefs.getInt('settings_network_delay'))!;
      settingsNetworkSimultaneous =
          (prefs.getInt('settings_network_simultaneous'))!;
      settingsFeedsLimit = (prefs.getInt('settings_feeds_limit'))!;
      settingsDaysLimit = (prefs.getInt('settings_days_limit'))!;
      settingsLoadImages = (prefs.getBool('settings_load_images'))!;
      settingsBlacklistParental =
          (prefs.getBool('settings_blacklist_parental'))!;
      settingsBlacklistCustom = (prefs.getString('settings_blacklist_custom'))!;
    } catch (err) {
      //print('Caught error: $err');
    }
  }
}
