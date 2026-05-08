import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _mealController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _saveMeal() {
    showDiarySavedMessage(context, '${widget.title} saved');
    Navigator.pop(context);
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
}
