import 'session_store_stub.dart'
    if (dart.library.html) 'session_store_web.dart'
    if (dart.library.io) 'session_store_io.dart';

class SessionStore {
  static Future<bool> isLoggedIn() => SessionStorePlatform.isLoggedIn();

  static Future<void> setLoggedIn(bool value) {
    return SessionStorePlatform.setLoggedIn(value);
  }
}
