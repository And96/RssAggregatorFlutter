import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
// ignore: depend_on_referenced_packages

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController mycontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Common'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: const Text('English'),
                  ),
                  SettingsTile.switchTile(
                    onToggle: (value) {},
                    initialValue: true,
                    leading: const Icon(Icons.format_paint),
                    title: const Text('Enable custom theme'),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Common'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: const Text('English'),
                  ),
                  SettingsTile.switchTile(
                    onToggle: (value) {},
                    initialValue: true,
                    leading: const Icon(Icons.format_paint),
                    title: const Text('Enable custom theme'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text('Save'),
        onPressed: () {
          Navigator.pop(context, '');
        },
      ),
    );
  }
}
