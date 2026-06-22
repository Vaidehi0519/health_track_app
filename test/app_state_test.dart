import 'package:flutter_test/flutter_test.dart';
import 'package:health_track_app/core/session_store.dart';
import 'package:health_track_app/core/state/app_state.dart';
import 'package:health_track_app/domain/models/health_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionStore.setLoggedIn(false);
  });

  test('stores water as dated entries instead of legacy daily total', () async {
    final appState = await AppState.load();

    await appState.addWater(250);

    final prefs = await SharedPreferences.getInstance();
    expect(appState.metrics.waterMl, 250);
    expect(appState.waterEntries, hasLength(1));
    expect(prefs.containsKey('water_entries'), isTrue);
    expect(prefs.containsKey('total_water_ml'), isFalse);
  });

  test('ignores legacy water total when no water entries exist', () async {
    SharedPreferences.setMockInitialValues({
      'total_water_ml': 1500,
      'water_date': DateTime.now().toIso8601String(),
    });

    final appState = await AppState.load();

    expect(appState.metrics.waterMl, 0);
    expect(appState.waterEntries, isEmpty);
  });

  test(
    'signOut clears user health data from memory and local storage',
    () async {
      final appState = await AppState.load();
      await appState.addWater(250);
      await appState.addMeal(
        name: 'Breakfast',
        type: MealType.breakfast,
        calories: 400,
        carbs: 40,
        fat: 12,
        protein: 24,
      );
      await appState.addWeight(58);

      await appState.signOut();

      final prefs = await SharedPreferences.getInstance();
      expect(appState.meals, isEmpty);
      expect(appState.waterEntries, isEmpty);
      expect(appState.weightEntries, isEmpty);
      expect(appState.metrics.waterMl, 0);
      expect(prefs.containsKey('meals'), isFalse);
      expect(prefs.containsKey('water_entries'), isFalse);
      expect(prefs.containsKey('weight_entries'), isFalse);
      expect(await SessionStore.isLoggedIn(), isFalse);
    },
  );

  test('rejects unrealistic health values at the state boundary', () async {
    final appState = await AppState.load();

    expect(() => appState.addWater(0), throwsArgumentError);
    expect(() => appState.addWeight(5), throwsArgumentError);
    expect(
      () => appState.addWorkout(
        name: 'Long workout',
        type: WorkoutType.cardio,
        minutes: 2000,
        caloriesBurned: 100,
      ),
      throwsArgumentError,
    );
  });

  test('deleteWorkout removes workout from memory and local storage', () async {
    final appState = await AppState.load();
    await appState.addWorkout(
      name: 'Morning walk',
      type: WorkoutType.walk,
      minutes: 30,
      caloriesBurned: 120,
    );

    final workoutId = appState.workouts.single.id;
    await appState.deleteWorkout(workoutId);

    final prefs = await SharedPreferences.getInstance();
    expect(appState.workouts, isEmpty);
    expect(appState.dailyWorkoutMinutes, 0);
    expect(prefs.getString('workouts'), '[]');
  });
}
