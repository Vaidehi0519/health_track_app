import 'dart:io';

class SessionStorePlatform {
  static final File _file = File(
    '${Directory.systemTemp.path}/health_track_app_session.txt',
  );

  static Future<bool> isLoggedIn() async {
    if (!_file.existsSync()) return false;
    return _file.readAsStringSync().trim() == 'true';
  }

  static Future<void> setLoggedIn(bool value) async {
    if (value) {
      _file.writeAsStringSync('true');
    } else if (_file.existsSync()) {
      _file.deleteSync();
    }
  }
}
