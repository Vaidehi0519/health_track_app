class SessionStorePlatform {
  static bool _loggedIn = false;

  static Future<bool> isLoggedIn() async => _loggedIn;

  static Future<void> setLoggedIn(bool value) async {
    _loggedIn = value;
  }
}
