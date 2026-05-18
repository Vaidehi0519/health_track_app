import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';

class MealStorageService {
  static const String mealsKey = 'saved_meals';

  /// Save meal
  static Future<void> saveMeal(MealModel meal) async {
    final prefs = await SharedPreferences.getInstance();

    final existingMeals = prefs.getStringList(mealsKey) ?? [];

    existingMeals.add(meal.toJson());

    await prefs.setStringList(mealsKey, existingMeals);
  }

  /// Get all meals
  static Future<List<MealModel>> getMeals() async {
    final prefs = await SharedPreferences.getInstance();

    final meals = prefs.getStringList(mealsKey) ?? [];

    return meals.map((meal) => MealModel.fromJson(meal)).toList();
  }

  /// Delete meal
  static Future<void> deleteMeal(int index) async {
    final prefs = await SharedPreferences.getInstance();

    final meals = prefs.getStringList(mealsKey) ?? [];

    meals.removeAt(index);

    await prefs.setStringList(mealsKey, meals);
  }
}
