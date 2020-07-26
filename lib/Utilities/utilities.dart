import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class Utilities {
  static Future<void> launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static String trimText(String text) {
    return text.length < 57 ? text : text.substring(0, 15) + "...";
  }

  static void vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
  }
}
