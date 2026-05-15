import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/data/models/meal_model.dart';
import 'package:health_track_app/data/services/meals_storage_service.dart';
import 'package:health_track_app/ui/screens/diary/nutrition/add_meal_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class CaloriesStatsScreen extends StatefulWidget {
  const CaloriesStatsScreen({super.key, this.date});

  final DateTime? date;

  @override
  State<CaloriesStatsScreen> createState() => _CaloriesStatsScreenState();
}

class _CaloriesStatsScreenState extends State<CaloriesStatsScreen> {
  late Future<List<MealModel>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _mealsFuture = MealStorageService.getMeals();
  }

  Future<void> _openAddMeal() async {
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddMealScreen()),
    );

    if (didSave != true || !mounted) return;
    setState(() => _mealsFuture = MealStorageService.getMeals());
  }

  @override
  Widget build(BuildContext context) {
    final metrics = AppScope.of(context).metrics;
    final caloriesLeft = (2100 - metrics.calories).clamp(0, 2100);

    return DiaryPageScaffold(
      title: 'Calories',
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Meal'),
        onPressed: _openAddMeal,
      ),
      children: [
        DiaryMetricHeader(
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFFF7A1A),
          title: 'Food intake',
          value: '${metrics.calories} kcal',
          subtitle: '$caloriesLeft kcal left today',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DiaryStatTile(
                label: 'Carbs',
                value: '${metrics.carbs}g',
                icon: Icons.rice_bowl_rounded,
                color: const Color(0xFFE84D89),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DiaryStatTile(
                label: 'Protein',
                value: '${metrics.protein}g',
                icon: Icons.egg_alt_rounded,
                color: const Color(0xFF32C74E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DiaryStatTile(
          label: 'Fat',
          value: '${metrics.fat}g',
          icon: Icons.opacity_rounded,
          color: const Color(0xFF7357FF),
        ),
        const SizedBox(height: 16),
        DiaryProgressPanel(
          title: 'Calorie Goal',
          value: metrics.calories / 2100,
          color: const Color(0xFFFF7A1A),
          caption: metrics.calories < 2100
              ? 'Balanced day so far'
              : 'Goal reached for today',
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<MealModel>>(
          future: _mealsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _MealSkeleton();
            }

            final meals = snapshot.data ?? const <MealModel>[];
            return DiaryPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  if (meals.isEmpty)
                    _EmptyMeals(onAddMeal: _openAddMeal)
                  else
                    ...meals.reversed.map(
                      (meal) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.restaurant_rounded),
                        title: Text(meal.name),
                        subtitle: Text(
                          '${meal.protein}g protein • ${meal.carbs}g carbs • ${meal.fat}g fat',
                        ),
                        trailing: Text(
                          '${meal.calories} kcal',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MealSkeleton extends StatelessWidget {
  const _MealSkeleton();

  @override
  Widget build(BuildContext context) {
    return DiaryPanel(
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
            child: Row(
              children: [
                _SkeletonBox(width: 42, height: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: double.infinity, height: 12),
                      const SizedBox(height: 8),
                      _SkeletonBox(width: 150, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals({required this.onAddMeal});

  final VoidCallback onAddMeal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 38,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          const Text(
            'No meals logged yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Add breakfast, lunch, dinner, or snacks to understand your daily nutrition pattern.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.62),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAddMeal,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add meal'),
          ),
        ],
      ),
    );
  }
}
