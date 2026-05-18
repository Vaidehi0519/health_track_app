import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:health_track_app/data/repositories/auth_repository.dart';
import 'package:health_track_app/data/repositories/health_data_repository.dart';
import 'package:health_track_app/data/services/local_storage_service.dart';
import 'package:health_track_app/data/services/notification_service.dart';
import 'package:health_track_app/domain/models/health_entry.dart';
import 'package:health_track_app/domain/models/user_profile.dart';
import 'package:health_track_app/core/state/health_metrics.dart';
import 'package:health_track_app/widgets/water_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  AppState._({
    required ThemeMode themeMode,
    required HealthMetrics metrics,
    required UserProfile profile,
    required List<MealEntry> meals,
    required List<WaterEntry> waterEntries,
    required List<WorkoutEntry> workouts,
    required List<WeightEntry> weightEntries,
    required ReminderPreference reminders,
    required LocalStorageService storage,
    required AuthRepository authRepository,
    required HealthDataRepository healthDataRepository,
    required NotificationService notificationService,
    required DateTime? lastSyncedAt,
  }) : _themeMode = themeMode,
       _metrics = metrics,
       _profile = profile,
       _meals = meals,
       _waterEntries = waterEntries,
       _workouts = workouts,
       _weightEntries = weightEntries,
       _reminders = reminders,
       _storage = storage,
       _authRepository = authRepository,
       _healthDataRepository = healthDataRepository,
       _notificationService = notificationService,
       _lastSyncedAt = lastSyncedAt;

  static const _themeModeKey = 'theme_mode';
  static const _profileKey = 'profile';
  static const _mealsKey = 'meals';
  static const _waterEntriesKey = 'water_entries';
  static const _workoutsKey = 'workouts';
  static const _weightEntriesKey = 'weight_entries';
  static const _remindersKey = 'reminders';
  static const _lastSyncedAtKey = 'last_synced_at';

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final authRepository = AuthRepository();
    final healthDataRepository = HealthDataRepository();
    final savedTheme = prefs.getString(_themeModeKey);
    final waterMl = await WaterStorageService.loadWater();
    final profile = storage.getJsonMap(_profileKey);
    final meals = storage
        .getJsonList(_mealsKey)
        .map(MealEntry.fromJson)
        .toList();
    final waterEntries = storage
        .getJsonList(_waterEntriesKey)
        .map(WaterEntry.fromJson)
        .toList();
    final workouts = storage
        .getJsonList(_workoutsKey)
        .map(WorkoutEntry.fromJson)
        .toList();
    final weightEntries = storage
        .getJsonList(_weightEntriesKey)
        .map(WeightEntry.fromJson)
        .toList();
    final reminders = storage.getJsonMap(_remindersKey);
    final lastSyncedAt = DateTime.tryParse(
      storage.getString(_lastSyncedAtKey) ?? '',
    );
    final localProfile = profile == null
        ? UserProfile.demo()
        : UserProfile.fromJson(profile);
    final userProfile =
        await authRepository.currentUserProfile() ?? localProfile;
    final cloudSnapshot = await healthDataRepository.loadAll();
    final syncedMeals = _mergeById(
      localItems: meals,
      cloudItems: cloudSnapshot.meals,
      idOf: (meal) => meal.id,
      createdAtOf: (meal) => meal.createdAt,
    );
    final syncedWaterEntries = _mergeById(
      localItems: waterEntries,
      cloudItems: cloudSnapshot.waterEntries,
      idOf: (entry) => entry.id,
      createdAtOf: (entry) => entry.createdAt,
    );
    final syncedWorkouts = _mergeById(
      localItems: workouts,
      cloudItems: cloudSnapshot.workouts,
      idOf: (workout) => workout.id,
      createdAtOf: (workout) => workout.createdAt,
    );
    final syncedWeightEntries = _mergeById(
      localItems: weightEntries,
      cloudItems: cloudSnapshot.weightEntries,
      idOf: (entry) => entry.id,
      createdAtOf: (entry) => entry.createdAt,
    );
    final todayWater = syncedWaterEntries.isEmpty
        ? waterMl
        : syncedWaterEntries
              .where((entry) => _isSameDay(entry.createdAt, DateTime.now()))
              .fold<int>(0, (total, entry) => total + entry.amountMl);

    return AppState._(
      themeMode: switch (savedTheme) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      },
      metrics: _buildMetrics(
        profile: userProfile,
        meals: syncedMeals,
        waterMl: todayWater,
        workouts: syncedWorkouts,
        weightEntries: syncedWeightEntries,
      ),
      profile: userProfile,
      meals: syncedMeals,
      waterEntries: syncedWaterEntries,
      workouts: syncedWorkouts,
      weightEntries: syncedWeightEntries,
      reminders: reminders == null
          ? ReminderPreference.defaults()
          : ReminderPreference.fromJson(reminders),
      storage: storage,
      authRepository: authRepository,
      healthDataRepository: healthDataRepository,
      notificationService: const NotificationService(),
      lastSyncedAt: cloudSnapshot.isEmpty ? lastSyncedAt : DateTime.now(),
    );
  }

  ThemeMode _themeMode;
  HealthMetrics _metrics;
  UserProfile _profile;
  List<MealEntry> _meals;
  List<WaterEntry> _waterEntries;
  List<WorkoutEntry> _workouts;
  List<WeightEntry> _weightEntries;
  ReminderPreference _reminders;
  final LocalStorageService _storage;
  final AuthRepository _authRepository;
  final HealthDataRepository _healthDataRepository;
  final NotificationService _notificationService;
  DateTime? _lastSyncedAt;
  bool _isSyncing = false;

  ThemeMode get themeMode => _themeMode;
  HealthMetrics get metrics => _metrics;
  UserProfile get profile => _profile;
  List<MealEntry> get meals => List.unmodifiable(_meals);
  List<WaterEntry> get waterEntries => List.unmodifiable(_waterEntries);
  List<WorkoutEntry> get workouts => List.unmodifiable(_workouts);
  List<WeightEntry> get weightEntries => List.unmodifiable(_weightEntries);
  ReminderPreference get reminders => _reminders;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  bool get isSyncing => _isSyncing;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  int get dailyCalories =>
      _mealsForDay().fold(0, (total, meal) => total + meal.calories);
  int get dailyProtein =>
      _mealsForDay().fold(0, (total, meal) => total + meal.protein);
  int get dailyWorkoutMinutes =>
      _workoutsForDay().fold(0, (total, workout) => total + workout.minutes);
  double get bmi => _profile.bmi;
  bool get isOfflineReady => true;
  bool get canCloudSync => _healthDataRepository.canSync;

  Future<void> setDarkMode(bool isEnabled) async {
    _themeMode = isEnabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, isEnabled ? 'dark' : 'light');
  }

  Future<void> refreshWater() async {
    final waterMl = _waterForDay();
    _metrics = _metrics.copyWith(waterMl: waterMl);
    notifyListeners();
  }

  Future<void> addWater(int amountMl) async {
    final entry = WaterEntry(
      id: _newId(),
      amountMl: amountMl,
      createdAt: DateTime.now(),
    );
    _waterEntries = [entry, ..._waterEntries];
    final nextTotal = _waterForDay().clamp(0, 5000);
    _metrics = _metrics.copyWith(waterMl: nextTotal);
    notifyListeners();
    await _storage.setJsonList(
      _waterEntriesKey,
      _waterEntries.map((entry) => entry.toJson()).toList(),
    );
    await WaterStorageService.saveWater(nextTotal);
    await _syncWrite(() => _healthDataRepository.saveWater(entry));
  }

  Future<void> addMeal({
    String name = 'Balanced meal',
    MealType type = MealType.snack,
    required int calories,
    required int carbs,
    required int fat,
    required int protein,
  }) async {
    final meal = MealEntry(
      id: _newId(),
      name: name,
      type: type,
      calories: calories,
      carbs: carbs,
      fat: fat,
      protein: protein,
      createdAt: DateTime.now(),
    );
    _meals = [meal, ..._meals];
    _recalculateMetrics();
    notifyListeners();
    await _persistMeals();
    await _syncWrite(() => _healthDataRepository.saveMeal(meal));
  }

  Future<void> updateMeal(MealEntry meal) async {
    _meals = _meals.map((entry) => entry.id == meal.id ? meal : entry).toList();
    _recalculateMetrics();
    notifyListeners();
    await _persistMeals();
    await _syncWrite(() => _healthDataRepository.saveMeal(meal));
  }

  Future<void> deleteMeal(String mealId) async {
    _meals = _meals.where((meal) => meal.id != mealId).toList();
    _recalculateMetrics();
    notifyListeners();
    await _persistMeals();
    await _syncWrite(() => _healthDataRepository.deleteMeal(mealId));
  }

  void addSteps([int amount = 1000]) {
    _metrics = _metrics.copyWith(steps: _metrics.steps + amount);
    notifyListeners();
  }

  void recordHeartSample() {
    _metrics = _metrics.copyWith(heartRate: 74 + math.Random().nextInt(10));
    notifyListeners();
  }

  void addSleepMinutes([int minutes = 30]) {
    _metrics = _metrics.copyWith(
      sleepMinutes: (_metrics.sleepMinutes + minutes).clamp(0, 720),
    );
    notifyListeners();
  }

  void addWeightSample([double amount = 0.1]) {
    final weight = double.parse((_metrics.weight + amount).toStringAsFixed(1));
    final entry = WeightEntry(
      id: _newId(),
      weightKg: weight,
      createdAt: DateTime.now(),
    );
    _weightEntries = [entry, ..._weightEntries];
    _profile = _profile.copyWith(weightKg: weight);
    _metrics = _metrics.copyWith(weight: weight);
    notifyListeners();
    _persistWeightEntries();
    _persistProfile();
    _syncWrite(() => _healthDataRepository.saveWeight(entry));
  }

  Future<void> addWeight(double weightKg) async {
    final entry = WeightEntry(
      id: _newId(),
      weightKg: weightKg,
      createdAt: DateTime.now(),
    );
    _weightEntries = [entry, ..._weightEntries];
    _profile = _profile.copyWith(weightKg: weightKg);
    _recalculateMetrics();
    notifyListeners();
    await _persistWeightEntries();
    await _persistProfile();
    await _syncWrite(() => _healthDataRepository.saveWeight(entry));
  }

  Future<void> addWorkout({
    required String name,
    required WorkoutType type,
    required int minutes,
    required int caloriesBurned,
  }) async {
    final workout = WorkoutEntry(
      id: _newId(),
      name: name,
      type: type,
      minutes: minutes,
      caloriesBurned: caloriesBurned,
      createdAt: DateTime.now(),
    );
    _workouts = [workout, ..._workouts];
    _recalculateMetrics();
    notifyListeners();
    await _persistWorkouts();
    await _syncWrite(() => _healthDataRepository.saveWorkout(workout));
  }

  List<MealEntry> searchMeals(String query, {MealType? type}) {
    final normalized = query.trim().toLowerCase();
    return _meals.where((meal) {
      final matchesType = type == null || meal.type == type;
      final matchesQuery =
          normalized.isEmpty || meal.name.toLowerCase().contains(normalized);
      return matchesType && matchesQuery;
    }).toList();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile.copyWith(avatarSeed: _initials(profile.name));
    _recalculateMetrics();
    notifyListeners();
    await _persistProfile();
    await _authRepository.updateProfile(_profile);
  }

  Future<void> signIn({required String email, required String password}) async {
    _profile = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );
    await _persistProfile();
    await syncNow(pushLocalFirst: false);
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String gender,
  }) async {
    _profile = await _authRepository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
      gender: gender,
    );
    await _persistProfile();
    await syncNow(pushLocalFirst: true);
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _profile = await _authRepository.signInWithGoogle();
    await _persistProfile();
    await syncNow(pushLocalFirst: false);
    notifyListeners();
  }

  Future<void> resetPassword(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> signOut() => _authRepository.signOut();

  Future<void> updateReminders(ReminderPreference reminders) async {
    _reminders = reminders;
    notifyListeners();
    await _notificationService.requestPermission();
    await _notificationService.scheduleHydrationReminder(
      enabled: reminders.water,
    );
    await _notificationService.scheduleMealReminder(enabled: reminders.meals);
    await _storage.setJsonMap(_remindersKey, reminders.toJson());
  }

  Future<void> syncNow({bool pushLocalFirst = true}) async {
    if (!_healthDataRepository.canSync) return;
    _isSyncing = true;
    notifyListeners();
    try {
      if (pushLocalFirst) {
        await _healthDataRepository.pushSnapshot(
          HealthDataSnapshot(
            meals: _meals,
            waterEntries: _waterEntries,
            workouts: _workouts,
            weightEntries: _weightEntries,
          ),
        );
      }
      final cloudSnapshot = await _healthDataRepository.loadAll();
      _meals = _mergeById(
        localItems: _meals,
        cloudItems: cloudSnapshot.meals,
        idOf: (meal) => meal.id,
        createdAtOf: (meal) => meal.createdAt,
      );
      _waterEntries = _mergeById(
        localItems: _waterEntries,
        cloudItems: cloudSnapshot.waterEntries,
        idOf: (entry) => entry.id,
        createdAtOf: (entry) => entry.createdAt,
      );
      _workouts = _mergeById(
        localItems: _workouts,
        cloudItems: cloudSnapshot.workouts,
        idOf: (workout) => workout.id,
        createdAtOf: (workout) => workout.createdAt,
      );
      _weightEntries = _mergeById(
        localItems: _weightEntries,
        cloudItems: cloudSnapshot.weightEntries,
        idOf: (entry) => entry.id,
        createdAtOf: (entry) => entry.createdAt,
      );
      _recalculateMetrics();
      await Future.wait([
        _persistMeals(),
        _persistWaterEntries(),
        _persistWorkouts(),
        _persistWeightEntries(),
      ]);
      await WaterStorageService.saveWater(_metrics.waterMl);
      _lastSyncedAt = DateTime.now();
      await _storage.setString(
        _lastSyncedAtKey,
        _lastSyncedAt!.toIso8601String(),
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  List<MealEntry> _mealsForDay([DateTime? day]) {
    final target = day ?? DateTime.now();
    return _meals.where((meal) => _isSameDay(meal.createdAt, target)).toList();
  }

  List<WorkoutEntry> _workoutsForDay([DateTime? day]) {
    final target = day ?? DateTime.now();
    return _workouts
        .where((workout) => _isSameDay(workout.createdAt, target))
        .toList();
  }

  int _waterForDay([DateTime? day]) {
    final target = day ?? DateTime.now();
    return _waterEntries
        .where((entry) => _isSameDay(entry.createdAt, target))
        .fold<int>(0, (total, entry) => total + entry.amountMl);
  }

  void _recalculateMetrics() {
    _metrics = _buildMetrics(
      profile: _profile,
      meals: _meals,
      waterMl: _waterForDay(),
      workouts: _workouts,
      weightEntries: _weightEntries,
      current: _metrics,
    );
  }

  Future<void> _persistProfile() =>
      _storage.setJsonMap(_profileKey, _profile.toJson());

  Future<void> _persistMeals() {
    return _storage.setJsonList(
      _mealsKey,
      _meals.map((meal) => meal.toJson()).toList(),
    );
  }

  Future<void> _persistWaterEntries() {
    return _storage.setJsonList(
      _waterEntriesKey,
      _waterEntries.map((entry) => entry.toJson()).toList(),
    );
  }

  Future<void> _persistWorkouts() {
    return _storage.setJsonList(
      _workoutsKey,
      _workouts.map((workout) => workout.toJson()).toList(),
    );
  }

  Future<void> _persistWeightEntries() {
    return _storage.setJsonList(
      _weightEntriesKey,
      _weightEntries.map((entry) => entry.toJson()).toList(),
    );
  }

  Future<void> _syncWrite(Future<void> Function() write) async {
    if (!_healthDataRepository.canSync) return;
    await write();
    _lastSyncedAt = DateTime.now();
    await _storage.setString(
      _lastSyncedAtKey,
      _lastSyncedAt!.toIso8601String(),
    );
    notifyListeners();
  }

  static HealthMetrics _buildMetrics({
    required UserProfile profile,
    required List<MealEntry> meals,
    required int waterMl,
    required List<WorkoutEntry> workouts,
    required List<WeightEntry> weightEntries,
    HealthMetrics? current,
  }) {
    final today = DateTime.now();
    final todayMeals = meals.where((meal) => _isSameDay(meal.createdAt, today));
    final calories = todayMeals.fold<int>(
      0,
      (total, meal) => total + meal.calories,
    );
    final carbs = todayMeals.fold<int>(0, (total, meal) => total + meal.carbs);
    final fat = todayMeals.fold<int>(0, (total, meal) => total + meal.fat);
    final protein = todayMeals.fold<int>(
      0,
      (total, meal) => total + meal.protein,
    );
    final latestWeight = weightEntries.isEmpty
        ? profile.weightKg
        : weightEntries.first.weightKg;
    return HealthMetrics.initial().copyWith(
      steps: current?.steps,
      waterMl: waterMl,
      calories: calories,
      carbs: carbs,
      fat: fat,
      protein: protein,
      heartRate: current?.heartRate,
      sleepMinutes: current?.sleepMinutes,
      weight: latestWeight,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  static List<T> _mergeById<T>({
    required List<T> localItems,
    required List<T> cloudItems,
    required String Function(T item) idOf,
    required DateTime Function(T item) createdAtOf,
  }) {
    final byId = <String, T>{};
    for (final item in cloudItems) {
      byId[idOf(item)] = item;
    }
    for (final item in localItems) {
      byId[idOf(item)] = item;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => createdAtOf(b).compareTo(createdAtOf(a)));
    return merged;
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return initials.isEmpty ? 'HU' : initials;
  }
}
