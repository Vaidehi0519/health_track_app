import 'dart:convert';

class MealModel {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime createdAt;

  MealModel({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      name: map['name'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory MealModel.fromJson(String source) {
    return MealModel.fromMap(jsonDecode(source));
  }
}
