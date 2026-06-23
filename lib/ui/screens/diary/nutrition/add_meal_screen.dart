import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/utils/app_feedback.dart';
import 'package:health_track_app/domain/models/health_entry.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key, this.title = 'Meal'});

  final String title;

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _mealController = TextEditingController();
  final _calorieController = TextEditingController(text: '320');
  final _proteinController = TextEditingController(text: '18');
  final _carbsController = TextEditingController(text: '36');
  final _fatController = TextEditingController(text: '10');
  MealType _mealType = MealType.snack;

  @override
  void dispose() {
    _mealController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    final name = _mealController.text.trim();
    final calories = int.tryParse(_calorieController.text.trim());
    final protein = int.tryParse(_proteinController.text.trim());
    final carbs = int.tryParse(_carbsController.text.trim());
    final fat = int.tryParse(_fatController.text.trim());

    if (name.isEmpty) {
      AppFeedback.showSnackBar(
        context,
        'Please enter food name',
        icon: Icons.error_rounded,
      );
      return;
    }

    if (!_isValidNumber(calories, max: 5000) ||
        !_isValidNumber(protein, max: 400) ||
        !_isValidNumber(carbs, max: 700) ||
        !_isValidNumber(fat, max: 300)) {
      AppFeedback.showSnackBar(
        context,
        'Enter valid nutrition values',
        icon: Icons.error_rounded,
      );
      return;
    }

    await AppScope.read(context).addMeal(
      name: name,
      type: _mealType,
      calories: calories!,
      protein: protein!,
      carbs: carbs!,
      fat: fat!,
    );

    if (!mounted) return;

    showDiarySavedMessage(context, '${widget.title} saved');

    Navigator.pop(context, true);
  }

  bool _isValidNumber(int? value, {required int max}) {
    return value != null && value >= 0 && value <= max;
  }

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Add ${widget.title}',
      children: [
        TextField(
          controller: _mealController,
          decoration: InputDecoration(
            labelText: 'Food name',
            prefixIcon: const Icon(Icons.restaurant_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<MealType>(
          initialValue: _mealType,
          decoration: InputDecoration(
            labelText: 'Meal type',
            prefixIcon: const Icon(Icons.category_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
          items: MealType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(_mealTypeLabel(type)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _mealType = value);
          },
        ),
        const SizedBox(height: 14),
        DiaryNumberField(
          controller: _calorieController,
          label: 'Calories',
          suffix: 'kcal',
          icon: Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DiaryNumberField(
                controller: _carbsController,
                label: 'Carbs',
                suffix: 'g',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DiaryNumberField(
                controller: _proteinController,
                label: 'Protein',
                suffix: 'g',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DiaryNumberField(controller: _fatController, label: 'Fat', suffix: 'g'),
        const SizedBox(height: 20),
        DiarySaveButton(label: 'Save meal', onSave: _saveMeal),
      ],
    );
  }

  String _mealTypeLabel(MealType type) {
    return switch (type) {
      MealType.breakfast => 'Breakfast',
      MealType.lunch => 'Lunch',
      MealType.dinner => 'Dinner',
      MealType.snack => 'Snack',
    };
  }
}
