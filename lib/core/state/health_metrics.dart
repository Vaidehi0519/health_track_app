class HealthMetrics {
  const HealthMetrics({
    required this.steps,
    required this.waterMl,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.heartRate,
    required this.sleepMinutes,
    required this.weight,
  });

  factory HealthMetrics.initial() {
    return const HealthMetrics(
      steps: 8240,
      waterMl: 0,
      calories: 1560,
      carbs: 185,
      fat: 46,
      protein: 82,
      heartRate: 76,
      sleepMinutes: 470,
      weight: 57.8,
    );
  }

  final int steps;
  final int waterMl;
  final int calories;
  final int carbs;
  final int fat;
  final int protein;
  final int heartRate;
  final int sleepMinutes;
  final double weight;

  double get targetCompletion {
    final scores = [
      steps / 12000,
      waterMl / 2500,
      calories / 2100,
      sleepMinutes / 480,
    ];

    final average =
        scores.fold<double>(0, (total, score) {
          return total + score.clamp(0.0, 1.0);
        }) /
        scores.length;

    return average.clamp(0.0, 1.0);
  }

  HealthMetrics copyWith({
    int? steps,
    int? waterMl,
    int? calories,
    int? carbs,
    int? fat,
    int? protein,
    int? heartRate,
    int? sleepMinutes,
    double? weight,
  }) {
    return HealthMetrics(
      steps: steps ?? this.steps,
      waterMl: waterMl ?? this.waterMl,
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      protein: protein ?? this.protein,
      heartRate: heartRate ?? this.heartRate,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      weight: weight ?? this.weight,
    );
  }
}
