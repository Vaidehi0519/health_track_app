import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/domain/models/health_entry.dart';
import 'package:health_track_app/ui/screens/diary/nutrition/add_meal_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class CaloriesStatsScreen extends StatefulWidget {
  const CaloriesStatsScreen({super.key, this.date});

  final DateTime? date;

  @override
  State<CaloriesStatsScreen> createState() => _CaloriesStatsScreenState();
}

class _CaloriesStatsScreenState extends State<CaloriesStatsScreen> {
  Future<void> _openAddMeal() async {
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddMealScreen()),
    );

    if (didSave != true || !mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final targetDate = widget.date ?? DateTime.now();
    final meals = appState.meals
        .where((meal) => _isSameDay(meal.createdAt, targetDate))
        .toList();
    final nutrition = appState.nutritionForDay(targetDate);
    final calories = nutrition.calories;
    final carbs = nutrition.carbs;
    final protein = nutrition.protein;
    final fat = nutrition.fat;
    final calorieTarget = appState.profile.dailyCalorieTarget;
    final proteinTarget = appState.profile.dailyProteinTarget;
    final caloriesLeft = (calorieTarget - calories).clamp(0, calorieTarget);
    final mealGroups = {
      for (final type in MealType.values)
        type: meals.where((meal) => meal.type == type).toList(),
    };

    return DiaryPageScaffold(
      title: _isToday(targetDate) ? 'Calories' : _dateTitle(targetDate),
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
          value: '$calories kcal',
          subtitle: '$caloriesLeft kcal left',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DiaryStatTile(
                label: 'Carbs',
                value: '${carbs}g',
                icon: Icons.rice_bowl_rounded,
                color: const Color(0xFFE84D89),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DiaryStatTile(
                label: 'Protein',
                value: '${protein}g',
                icon: Icons.egg_alt_rounded,
                color: const Color(0xFF32C74E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DiaryStatTile(
          label: 'Fat',
          value: '${fat}g',
          icon: Icons.opacity_rounded,
          color: const Color(0xFF7357FF),
        ),
        const SizedBox(height: 16),
        DiaryProgressPanel(
          title: 'Calorie Goal',
          value: calories / calorieTarget,
          color: const Color(0xFFFF7A1A),
          caption: calories < calorieTarget
              ? '${((calories / calorieTarget) * 100).clamp(0, 999).round()}% of daily goal'
              : 'Goal reached for this day',
        ),
        const SizedBox(height: 16),
        _MacroTargetsPanel(
          calories: calories,
          calorieTarget: calorieTarget,
          protein: protein,
          proteinTarget: proteinTarget,
          carbs: carbs,
          fat: fat,
        ),
        const SizedBox(height: 16),
        _MealBreakdownPanel(mealGroups: mealGroups),
        const SizedBox(height: 16),
        _MealsPanel(
          meals: meals,
          onAddMeal: _openAddMeal,
          onDeleteMeal: (meal) async {
            await appState.deleteMeal(meal.id);
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime day) => _isSameDay(day, DateTime.now());

  String _dateTitle(DateTime date) {
    return 'Calories ${date.day}/${date.month}';
  }
}

class _MacroTargetsPanel extends StatelessWidget {
  const _MacroTargetsPanel({
    required this.calories,
    required this.calorieTarget,
    required this.protein,
    required this.proteinTarget,
    required this.carbs,
    required this.fat,
  });

  final int calories;
  final int calorieTarget;
  final int protein;
  final int proteinTarget;
  final int carbs;
  final int fat;

  @override
  Widget build(BuildContext context) {
    return DiaryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily targets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _TargetRow(
            label: 'Calories',
            value: calories,
            target: calorieTarget,
            suffix: 'kcal',
            color: const Color(0xFFFF7A1A),
          ),
          const SizedBox(height: 12),
          _TargetRow(
            label: 'Protein',
            value: protein,
            target: proteinTarget,
            suffix: 'g',
            color: const Color(0xFF32C74E),
          ),
          const SizedBox(height: 12),
          Text(
            'Macros logged: ${carbs}g carbs • ${fat}g fat',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.label,
    required this.value,
    required this.target,
    required this.suffix,
    required this.color,
  });

  final String label;
  final int value;
  final int target;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            const Spacer(),
            Text(
              '$value / $target $suffix',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.64),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: target == 0 ? 0 : (value / target).clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MealBreakdownPanel extends StatelessWidget {
  const _MealBreakdownPanel({required this.mealGroups});

  final Map<MealType, List<MealEntry>> mealGroups;

  @override
  Widget build(BuildContext context) {
    return DiaryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meal breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...MealType.values.map((type) {
            final meals = mealGroups[type] ?? const <MealEntry>[];
            final calories = meals.fold<int>(
              0,
              (total, meal) => total + meal.calories,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(_mealTypeIcon(type), color: _mealTypeColor(type)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _mealTypeLabel(type),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${meals.length} • $calories kcal',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MealsPanel extends StatelessWidget {
  const _MealsPanel({
    required this.meals,
    required this.onAddMeal,
    required this.onDeleteMeal,
  });

  final List<MealEntry> meals;
  final VoidCallback onAddMeal;
  final ValueChanged<MealEntry> onDeleteMeal;

  @override
  Widget build(BuildContext context) {
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
            _EmptyMeals(onAddMeal: onAddMeal)
          else
            ...meals.map(
              (meal) => Dismissible(
                key: ValueKey(meal.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE84D4D).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE84D4D),
                  ),
                ),
                onDismissed: (_) => onDeleteMeal(meal),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _mealTypeIcon(meal.type),
                    color: _mealTypeColor(meal.type),
                  ),
                  title: Text(meal.name),
                  subtitle: Text(
                    '${_mealTypeLabel(meal.type)} • ${meal.protein}g protein • ${meal.carbs}g carbs • ${meal.fat}g fat',
                  ),
                  trailing: Text(
                    '${meal.calories} kcal',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _mealTypeLabel(MealType type) {
  return switch (type) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
  };
}

IconData _mealTypeIcon(MealType type) {
  return switch (type) {
    MealType.breakfast => Icons.free_breakfast_rounded,
    MealType.lunch => Icons.lunch_dining_rounded,
    MealType.dinner => Icons.dinner_dining_rounded,
    MealType.snack => Icons.cookie_rounded,
  };
}

Color _mealTypeColor(MealType type) {
  return switch (type) {
    MealType.breakfast => const Color(0xFFFF7A1A),
    MealType.lunch => const Color(0xFF32C74E),
    MealType.dinner => const Color(0xFF7357FF),
    MealType.snack => const Color(0xFFE84D89),
  };
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
