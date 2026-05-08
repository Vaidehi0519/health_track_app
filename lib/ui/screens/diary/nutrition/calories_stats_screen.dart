import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/nutrition/add_meal_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class CaloriesStatsScreen extends StatelessWidget {
  const CaloriesStatsScreen({super.key, this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Calories',
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Meal'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMealScreen()),
          );
        },
      ),
      children: [
        const DiaryMetricHeader(
          icon: Icons.local_fire_department_rounded,
          color: Color(0xFFFF7A1A),
          title: 'Food intake',
          value: '1560 kcal',
          subtitle: '540 kcal left today',
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: DiaryStatTile(
                label: 'Carbs',
                value: '185g',
                icon: Icons.rice_bowl_rounded,
                color: Color(0xFFE84D89),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: DiaryStatTile(
                label: 'Protein',
                value: '82g',
                icon: Icons.egg_alt_rounded,
                color: Color(0xFF32C74E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const DiaryStatTile(
          label: 'Fat',
          value: '46g',
          icon: Icons.opacity_rounded,
          color: Color(0xFF7357FF),
        ),
        const SizedBox(height: 16),
        const DiaryProgressPanel(
          title: 'Calorie Goal',
          value: 0.74,
          color: Color(0xFFFF7A1A),
          caption: 'Balanced day so far',
        ),
        const SizedBox(height: 16),
        DiaryPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...[
                'Breakfast - 420 kcal',
                'Lunch - 680 kcal',
                'Snack - 160 kcal',
              ].map(
                (meal) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restaurant_rounded),
                  title: Text(meal),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
