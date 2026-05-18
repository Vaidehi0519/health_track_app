enum MealType { breakfast, lunch, dinner, snack }

enum WorkoutType { walk, run, strength, yoga, cycling, cardio }

class MealEntry {
  const MealEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
  });

  factory MealEntry.fromJson(Map<String, Object?> json) {
    return MealEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MealType.values.byName(json['type'] as String? ?? 'snack'),
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String name;
  final MealType type;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime createdAt;

  MealEntry copyWith({
    String? id,
    String? name,
    MealType? type,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    DateTime? createdAt,
  }) {
    return MealEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WaterEntry {
  const WaterEntry({
    required this.id,
    required this.amountMl,
    required this.createdAt,
  });

  factory WaterEntry.fromJson(Map<String, Object?> json) {
    return WaterEntry(
      id: json['id'] as String,
      amountMl: json['amountMl'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final int amountMl;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WorkoutEntry {
  const WorkoutEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.minutes,
    required this.caloriesBurned,
    required this.createdAt,
  });

  factory WorkoutEntry.fromJson(Map<String, Object?> json) {
    return WorkoutEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      type: WorkoutType.values.byName(json['type'] as String? ?? 'walk'),
      minutes: json['minutes'] as int? ?? 0,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String name;
  final WorkoutType type;
  final int minutes;
  final int caloriesBurned;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'minutes': minutes,
      'caloriesBurned': caloriesBurned,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.createdAt,
  });

  factory WeightEntry.fromJson(Map<String, Object?> json) {
    return WeightEntry(
      id: json['id'] as String,
      weightKg: (json['weightKg'] as num? ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final double weightKg;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'weightKg': weightKg,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ReminderPreference {
  const ReminderPreference({
    required this.water,
    required this.meals,
    required this.workouts,
    required this.sleep,
  });

  factory ReminderPreference.defaults() {
    return const ReminderPreference(
      water: true,
      meals: true,
      workouts: true,
      sleep: false,
    );
  }

  factory ReminderPreference.fromJson(Map<String, Object?> json) {
    return ReminderPreference(
      water: json['water'] as bool? ?? true,
      meals: json['meals'] as bool? ?? true,
      workouts: json['workouts'] as bool? ?? true,
      sleep: json['sleep'] as bool? ?? false,
    );
  }

  final bool water;
  final bool meals;
  final bool workouts;
  final bool sleep;

  ReminderPreference copyWith({
    bool? water,
    bool? meals,
    bool? workouts,
    bool? sleep,
  }) {
    return ReminderPreference(
      water: water ?? this.water,
      meals: meals ?? this.meals,
      workouts: workouts ?? this.workouts,
      sleep: sleep ?? this.sleep,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'water': water,
      'meals': meals,
      'workouts': workouts,
      'sleep': sleep,
    };
  }
}
