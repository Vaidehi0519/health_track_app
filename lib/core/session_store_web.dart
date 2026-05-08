// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

class SessionStorePlatform {
  static const _key = 'health_track_app_logged_in';

  static Future<bool> isLoggedIn() async {
    return html.window.localStorage[_key] == 'true';
  }

  static Future<void> setLoggedIn(bool value) async {
    if (value) {
      html.window.localStorage[_key] = 'true';
    } else {
      html.window.localStorage.remove(_key);
    }
  }
}
