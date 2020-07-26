import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curator/Utilities/ThemeChanger.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  void initState() {
    ThemeChanger.getDarkModePlainBool().then((value) {
      _darkMode = value;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return ListView(
      children: <Widget>[
        Card(
          child: Row(
            children: <Widget>[
              Text("Dark Mode"),
              Switch(
                onChanged: (val) {
                  setState(() {
                    _darkMode = val;
                    _themeChanger.setDarkMode(_darkMode);
                  });
                },
                value: _darkMode,
              )
            ],
          ),
        ),
        Card(
          child: GestureDetector(
            onTap: () {
              openPrivacyPolicy();
            },
            child: Text("Privacy Policy"),
          ),
        ),
        Card(
          child: GestureDetector(
            onTap: () {
              openPrivacyPolicy();
            },
            child: Text("Request Features"),
          ),
        ),
        Card(
          child: GestureDetector(
            onTap: () {
              openPrivacyPolicy();
            },
            child: Text("Rate App"),
          ),
        ),
        Card(
          child: GestureDetector(
            onTap: () {
              openPrivacyPolicy();
            },
            child: Text("Biometric"),
          ),
        ),
      ],
    );
  }

  openPrivacyPolicy() {}
}

class Provier {}
