import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  const LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  Future<void> remove(String key) {
    return _prefs.remove(key);
  }

  List<Map<String, Object?>> getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, Object?>.from(item))
        .toList();
  }

  Future<void> setJsonList(String key, List<Map<String, Object?>> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  Map<String, Object?>? getJsonMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Map<String, Object?>.from(decoded);
  }

  Future<void> setJsonMap(String key, Map<String, Object?> value) {
    return _prefs.setString(key, jsonEncode(value));
  }
}
