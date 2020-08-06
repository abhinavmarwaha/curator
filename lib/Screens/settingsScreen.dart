import 'package:curator/Utilities/utilities.dart';
import 'package:curator/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curator/Utilities/ThemeChanger.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _zenReader = false;

  @override
  void initState() {
    ThemeChanger.getDarkModePlainBool().then((value) {
      setState(() {
        _darkMode = value;
      });
    });
    Utilities.getZenBool().then((value) => setState(() {
          _zenReader = value;
        }));
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
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Dark Mode"),
                Spacer(),
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
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Zen Reader (Experimental)"),
                Spacer(),
                Switch(
                  onChanged: (val) {
                    setState(() {
                      _zenReader = val;
                      Utilities.setZenBool(val);
                    });
                  },
                  value: _zenReader,
                )
              ],
            ),
          ),
        ),
        // Card(
        //   child: GestureDetector(
        //     onTap: () {
        //       openPrivacyPolicy();
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Text("Privacy Policy"),
        //     ),
        //   ),
        // ),
        Card(
          child: GestureDetector(
            onTap: () {
              openFeaturesForm();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Request Features"),
            ),
          ),
        ),
        Card(
          child: GestureDetector(
            onTap: () {
              // openRateApp();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Rate App"),
            ),
          ),
        ),
      ],
    );
  }

  openPrivacyPolicy() {
    Utilities.launchInWebViewOrVC(PRIVACYPOLICYURL);
  }

  openFeaturesForm() {
    Utilities.launchInWebViewOrVC(FEATUREFORMURL);
  }

  openRateApp() {
    Utilities.launchInWebViewOrVC(RATEAPPURL);
  }
}
