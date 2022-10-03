import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  int settingsFeedsLimit = 0;
  int settingsDaysLimit = 0;
  bool settingsLoadImages = true;
  int settingsTimeout = 0;

  Settings();

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settingsFeedsLimit = (prefs.getInt('settings_feeds_limit'))!;
    settingsDaysLimit = (prefs.getInt('settings_days_limit'))!;
    settingsLoadImages = (prefs.getBool('settings_load_images'))!;
    settingsTimeout = (prefs.getInt('settings_timeout'))!;
  }
}
