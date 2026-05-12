import 'package:shared_preferences/shared_preferences.dart';

class WaterStorageService {
  static const String waterKey = 'total_water_ml';
  static const String waterDateKey = 'water_date';

  // LOAD WATER
  static Future<int> loadWater() async {
    final prefs = await SharedPreferences.getInstance();

    final savedWater = prefs.getInt(waterKey) ?? 0;

    final savedDateString = prefs.getString(waterDateKey);

    if (savedDateString != null) {
      final savedDate = DateTime.parse(savedDateString);

      final now = DateTime.now();

      final isSameDay =
          savedDate.year == now.year &&
          savedDate.month == now.month &&
          savedDate.day == now.day;

      if (isSameDay) {
        return savedWater;
      } else {
        // RESET FOR NEW DAY
        await prefs.setInt(waterKey, 0);

        await prefs.setString(waterDateKey, now.toIso8601String());

        return 0;
      }
    }

    return 0;
  }

  // SAVE WATER
  static Future<void> saveWater(int totalMl) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(waterKey, totalMl);

    await prefs.setString(waterDateKey, DateTime.now().toIso8601String());
  }
}
