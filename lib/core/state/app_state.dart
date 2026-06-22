import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:health_track_app/data/repositories/auth_repository.dart';
import 'package:health_track_app/data/repositories/health_data_repository.dart';
import 'package:health_track_app/data/services/local_storage_service.dart';
import 'package:health_track_app/data/services/notification_service.dart';
import 'package:health_track_app/domain/models/health_entry.dart';
import 'package:health_track_app/domain/models/user_profile.dart';
import 'package:health_track_app/core/state/health_metrics.dart';
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
    required List<DailyNutritionSummary> dailySummaries,
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
       _dailySummaries = dailySummaries,
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
    final todayWater = syncedWaterEntries
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
        dailySummaries: cloudSnapshot.dailySummaries,
        waterMl: todayWater,
        workouts: syncedWorkouts,
        weightEntries: syncedWeightEntries,
      ),
      profile: userProfile,
      meals: syncedMeals,
      waterEntries: syncedWaterEntries,
      workouts: syncedWorkouts,
      weightEntries: syncedWeightEntries,
      dailySummaries: cloudSnapshot.dailySummaries,
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
  List<DailyNutritionSummary> _dailySummaries;
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
  List<DailyNutritionSummary> get dailySummaries =>
      List.unmodifiable(_dailySummaries);
  ReminderPreference get reminders => _reminders;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  bool get isSyncing => _isSyncing;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  int get dailyCalories => nutritionForDay(DateTime.now()).calories;
  int get dailyProtein => nutritionForDay(DateTime.now()).protein;
  int get dailyWorkoutMinutes =>
      _workoutsForDay().fold(0, (total, workout) => total + workout.minutes);
  double get bmi => _profile.bmi;
  bool get isOfflineReady => true;
  bool get canCloudSync => _healthDataRepository.canSync;

  DailyNutritionSummary nutritionForDay(DateTime day) {
    final meals = _mealsForDay(day);
    if (meals.isNotEmpty) {
      return _nutritionSummaryFromMeals(day, meals);
    }

    final dateId = _dateId(day);
    return _dailySummaries.firstWhere(
      (summary) => summary.dateId == dateId,
      orElse: () => DailyNutritionSummary(
        dateId: dateId,
        date: DateTime(day.year, day.month, day.day),
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      ),
    );
  }

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
    _checkIntRange(amountMl, field: 'Water amount', min: 1, max: 5000);
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
    await _syncWrite(
      () => _healthDataRepository.saveWater(entry),
      affectedDay: entry.createdAt,
    );
  }

  Future<void> addMeal({
    String name = 'Balanced meal',
    MealType type = MealType.snack,
    required int calories,
    required int carbs,
    required int fat,
    required int protein,
  }) async {
    _checkIntRange(calories, field: 'Calories', min: 0, max: 5000);
    _checkIntRange(carbs, field: 'Carbs', min: 0, max: 700);
    _checkIntRange(fat, field: 'Fat', min: 0, max: 300);
    _checkIntRange(protein, field: 'Protein', min: 0, max: 400);

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
    await _syncWrite(
      () => _healthDataRepository.saveMeal(meal),
      affectedDay: meal.createdAt,
    );
  }

  Future<void> updateMeal(MealEntry meal) async {
    _meals = _meals.map((entry) => entry.id == meal.id ? meal : entry).toList();
    _recalculateMetrics();
    notifyListeners();
    await _persistMeals();
    await _syncWrite(
      () => _healthDataRepository.saveMeal(meal),
      affectedDay: meal.createdAt,
    );
  }

  Future<void> deleteMeal(String mealId) async {
    final deletedMeal = _meals.where((meal) => meal.id == mealId).firstOrNull;
    _meals = _meals.where((meal) => meal.id != mealId).toList();
    _recalculateMetrics();
    notifyListeners();
    await _persistMeals();
    await _syncWrite(
      () => _healthDataRepository.deleteMeal(mealId),
      affectedDay: deletedMeal?.createdAt,
    );
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
    _syncWrite(
      () => _healthDataRepository.saveWeight(entry),
      affectedDay: entry.createdAt,
    );
  }

  Future<void> addWeight(double weightKg) async {
    _checkDoubleRange(weightKg, field: 'Weight', min: 20, max: 300);
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
    await _syncWrite(
      () => _healthDataRepository.saveWeight(entry),
      affectedDay: entry.createdAt,
    );
  }

  Future<void> addWorkout({
    required String name,
    required WorkoutType type,
    required int minutes,
    required int caloriesBurned,
  }) async {
    _checkIntRange(minutes, field: 'Workout minutes', min: 1, max: 1440);
    _checkIntRange(caloriesBurned, field: 'Calories burned', min: 0, max: 5000);

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
    await _syncWrite(
      () => _healthDataRepository.saveWorkout(workout),
      affectedDay: workout.createdAt,
    );
  }

  Future<void> deleteWorkout(String workoutId) async {
    final deletedWorkout = _workouts
        .where((workout) => workout.id == workoutId)
        .firstOrNull;
    _workouts = _workouts.where((workout) => workout.id != workoutId).toList();
    _recalculateMetrics();
    notifyListeners();
    await _persistWorkouts();
    await _syncWrite(
      () => _healthDataRepository.deleteWorkout(workoutId),
      affectedDay: deletedWorkout?.createdAt,
    );
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

  Future<void> signOut() async {
    await _authRepository.signOut();
    _profile = UserProfile.demo();
    _meals = [];
    _waterEntries = [];
    _workouts = [];
    _weightEntries = [];
    _dailySummaries = [];
    _lastSyncedAt = null;
    _isSyncing = false;
    _metrics = _buildMetrics(
      profile: _profile,
      meals: _meals,
      dailySummaries: _dailySummaries,
      waterMl: 0,
      workouts: _workouts,
      weightEntries: _weightEntries,
    );
    await Future.wait([
      _storage.remove(_profileKey),
      _storage.remove(_mealsKey),
      _storage.remove(_waterEntriesKey),
      _storage.remove(_workoutsKey),
      _storage.remove(_weightEntriesKey),
      _storage.remove(_lastSyncedAtKey),
    ]);
    notifyListeners();
  }

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
            dailySummaries: _dailySummaries,
          ),
        );
        await _healthDataRepository.saveDailyLogs(_dailyLogsByDate());
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
      _dailySummaries = cloudSnapshot.dailySummaries;
      _recalculateMetrics();
      await Future.wait([
        _persistMeals(),
        _persistWaterEntries(),
        _persistWorkouts(),
        _persistWeightEntries(),
      ]);
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
      dailySummaries: _dailySummaries,
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

  Future<void> _syncWrite(
    Future<void> Function() write, {
    DateTime? affectedDay,
  }) async {
    if (!_healthDataRepository.canSync) return;
    await write();
    if (affectedDay != null) {
      await _healthDataRepository.saveDailyLog(
        dateId: _dateId(affectedDay),
        data: _dailyLogForDay(affectedDay),
      );
    }
    _lastSyncedAt = DateTime.now();
    await _storage.setString(
      _lastSyncedAtKey,
      _lastSyncedAt!.toIso8601String(),
    );
    notifyListeners();
  }

  Map<String, Map<String, Object?>> _dailyLogsByDate() {
    final days = <String, DateTime>{};
    for (final meal in _meals) {
      days[_dateId(meal.createdAt)] = meal.createdAt;
    }
    for (final entry in _waterEntries) {
      days[_dateId(entry.createdAt)] = entry.createdAt;
    }
    for (final workout in _workouts) {
      days[_dateId(workout.createdAt)] = workout.createdAt;
    }
    for (final entry in _weightEntries) {
      days[_dateId(entry.createdAt)] = entry.createdAt;
    }

    return {
      for (final day in days.entries) day.key: _dailyLogForDay(day.value),
    };
  }

  Map<String, Object?> _dailyLogForDay(DateTime day) {
    final meals = _mealsForDay(day);
    final workouts = _workoutsForDay(day);
    final waterMl = _waterForDay(day);
    final weight = _weightEntries
        .where((entry) => _isSameDay(entry.createdAt, day))
        .map((entry) => entry.weightKg)
        .firstOrNull;
    final calories = meals.fold<int>(0, (total, meal) => total + meal.calories);
    final protein = meals.fold<int>(0, (total, meal) => total + meal.protein);
    final carbs = meals.fold<int>(0, (total, meal) => total + meal.carbs);
    final fat = meals.fold<int>(0, (total, meal) => total + meal.fat);
    final workoutMinutes = workouts.fold<int>(
      0,
      (total, workout) => total + workout.minutes,
    );
    final workoutCalories = workouts.fold<int>(
      0,
      (total, workout) => total + workout.caloriesBurned,
    );
    final loggedWeight = weight ?? _profile.weightKg;

    return {
      'dateId': _dateId(day),
      'date': DateTime(day.year, day.month, day.day).toIso8601String(),
      'userId': _profile.uid,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'waterMl': waterMl,
      'workoutMinutes': workoutMinutes,
      'workoutCalories': workoutCalories,
      'weightKg': loggedWeight,
      'bmi': _bmiForWeight(loggedWeight),
      'mealCount': meals.length,
      'waterEntryCount': _waterEntries
          .where((entry) => _isSameDay(entry.createdAt, day))
          .length,
      'workoutCount': workouts.length,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static HealthMetrics _buildMetrics({
    required UserProfile profile,
    required List<MealEntry> meals,
    required List<DailyNutritionSummary> dailySummaries,
    required int waterMl,
    required List<WorkoutEntry> workouts,
    required List<WeightEntry> weightEntries,
    HealthMetrics? current,
  }) {
    final today = DateTime.now();
    final todayMeals = meals.where((meal) => _isSameDay(meal.createdAt, today));
    final todaySummary = todayMeals.isEmpty
        ? dailySummaries
              .where((summary) => summary.dateId == _dateId(today))
              .firstOrNull
        : null;
    final calories =
        todaySummary?.calories ??
        todayMeals.fold<int>(0, (total, meal) => total + meal.calories);
    final carbs =
        todaySummary?.carbs ??
        todayMeals.fold<int>(0, (total, meal) => total + meal.carbs);
    final fat =
        todaySummary?.fat ??
        todayMeals.fold<int>(0, (total, meal) => total + meal.fat);
    final protein =
        todaySummary?.protein ??
        todayMeals.fold<int>(0, (total, meal) => total + meal.protein);
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

  static String _dateId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DailyNutritionSummary _nutritionSummaryFromMeals(
    DateTime day,
    Iterable<MealEntry> meals,
  ) {
    return DailyNutritionSummary(
      dateId: _dateId(day),
      date: DateTime(day.year, day.month, day.day),
      calories: meals.fold<int>(0, (total, meal) => total + meal.calories),
      protein: meals.fold<int>(0, (total, meal) => total + meal.protein),
      carbs: meals.fold<int>(0, (total, meal) => total + meal.carbs),
      fat: meals.fold<int>(0, (total, meal) => total + meal.fat),
    );
  }

  double _bmiForWeight(double weightKg) {
    final heightM = _profile.heightCm / 100;
    if (heightM <= 0) return 0;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

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

  static void _checkIntRange(
    int value, {
    required String field,
    required int min,
    required int max,
  }) {
    if (value < min || value > max) {
      throw ArgumentError.value(value, field, 'Must be between $min and $max.');
    }
  }

  static void _checkDoubleRange(
    double value, {
    required String field,
    required double min,
    required double max,
  }) {
    if (value < min || value > max) {
      throw ArgumentError.value(value, field, 'Must be between $min and $max.');
    }
  }
}
