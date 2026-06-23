import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/theme/app_theme.dart';
import 'package:health_track_app/domain/models/health_entry.dart';
import 'package:health_track_app/ui/widgets/health_components.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  Future<void> _showWorkoutSheet() async {
    final appState = AppScope.read(context);
    final nameController = TextEditingController(text: 'Evening workout');
    final minutesController = TextEditingController(text: '30');
    final caloriesController = TextEditingController(text: '180');
    var type = WorkoutType.strength;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  6,
                  20,
                  MediaQuery.viewInsetsOf(context).bottom + 20,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Log workout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Workout name',
                          prefixIcon: Icon(Icons.fitness_center_rounded),
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Enter a workout'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<WorkoutType>(
                        initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: WorkoutType.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(_workoutTypeLabel(item)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setSheetState(() => type = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _NumberInput(
                              controller: minutesController,
                              label: 'Minutes',
                              max: 1440,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NumberInput(
                              controller: caloriesController,
                              label: 'Calories',
                              max: 5000,
                              allowZero: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final navigator = Navigator.of(context);
                          final route = ModalRoute.of(context);
                          await appState.addWorkout(
                            name: nameController.text.trim(),
                            type: type,
                            minutes: int.parse(minutesController.text),
                            caloriesBurned: int.parse(caloriesController.text),
                          );
                          if (navigator.mounted &&
                              (route?.isCurrent ?? false)) {
                            navigator.pop();
                          }
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Save workout'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    minutesController.dispose();
    caloriesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final today = DateTime.now();
    final todayWorkouts = appState.workouts
        .where((workout) => _isSameDay(workout.createdAt, today))
        .toList();
    final weeklyWorkouts = appState.workouts
        .where((workout) => today.difference(workout.createdAt).inDays < 7)
        .toList();
    final caloriesBurned = todayWorkouts.fold<int>(
      0,
      (total, workout) => total + workout.caloriesBurned,
    );
    final weeklyMinutes = weeklyWorkouts.fold<int>(
      0,
      (total, workout) => total + workout.minutes,
    );
    final workoutCount = todayWorkouts.length;
    final weeklyPoints = _weeklyMinutePoints(appState.workouts, today);
    final typeTotals = {
      for (final type in WorkoutType.values)
        type: todayWorkouts
            .where((workout) => workout.type == type)
            .fold<int>(0, (total, workout) => total + workout.minutes),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            tooltip: 'Add workout',
            onPressed: _showWorkoutSheet,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: HealthStatCard(
                    icon: Icons.timer_rounded,
                    label: 'Workout time',
                    value: '${appState.dailyWorkoutMinutes}m',
                    subtitle: '$workoutCount sessions today',
                    color: AppColors.secondary,
                    progress: appState.dailyWorkoutMinutes / 45,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthStatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Burned',
                    value: '$caloriesBurned',
                    subtitle: 'kcal today',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _showWorkoutSheet,
              icon: const Icon(Icons.fitness_center_rounded),
              label: const Text('Log workout'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: HealthStatCard(
                    icon: Icons.calendar_view_week_rounded,
                    label: 'This week',
                    value: '${weeklyMinutes}m',
                    subtitle: '${weeklyWorkouts.length} workouts',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthStatCard(
                    icon: Icons.flag_rounded,
                    label: 'Daily goal',
                    value:
                        '${(appState.dailyWorkoutMinutes / 45 * 100).clamp(0, 999).round()}%',
                    subtitle: '45 min movement target',
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ActivityPanel(
              title: '7-day movement',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrendChart(
                    values: weeklyPoints
                        .map((value) => value.toDouble())
                        .toList(),
                    color: AppColors.secondary,
                    height: 140,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Minutes logged over the last 7 days',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ActivityPanel(
              title: 'Today by type',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: WorkoutType.values.map((type) {
                  final minutes = typeTotals[type] ?? 0;
                  return _TypeChip(type: type, minutes: minutes);
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Today\'s workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (todayWorkouts.isEmpty)
              const EmptyState(
                icon: Icons.directions_run_rounded,
                title: 'No workouts logged',
                message: 'Add walks, strength sessions, yoga, or cardio here.',
              )
            else
              ...todayWorkouts.map(
                (workout) => Dismissible(
                  key: ValueKey(workout.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                  ),
                  onDismissed: (_) async {
                    await appState.deleteWorkout(workout.id);
                    if (mounted) setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary.withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(
                          _workoutTypeIcon(workout.type),
                          color: AppColors.secondary,
                        ),
                      ),
                      title: Text(
                        workout.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${_workoutTypeLabel(workout.type)} - ${workout.minutes} minutes',
                      ),
                      trailing: Text(
                        '${workout.caloriesBurned} kcal',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({
    required this.controller,
    required this.label,
    required this.max,
    this.allowZero = false,
  });

  final TextEditingController controller;
  final String label;
  final int max;
  final bool allowZero;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final number = int.tryParse(value ?? '');
        final min = allowZero ? 0 : 1;
        if (number == null || number < min || number > max) {
          return '$min-$max';
        }
        return null;
      },
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type, required this.minutes});

  final WorkoutType type;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final color = _workoutTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_workoutTypeIcon(type), color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            '${_workoutTypeLabel(type)} $minutes m',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

List<int> _weeklyMinutePoints(List<WorkoutEntry> workouts, DateTime today) {
  final start = DateTime(
    today.year,
    today.month,
    today.day,
  ).subtract(const Duration(days: 6));
  return List.generate(7, (index) {
    final day = start.add(Duration(days: index));
    return workouts
        .where((workout) => _isSameDay(workout.createdAt, day))
        .fold<int>(0, (total, workout) => total + workout.minutes);
  });
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _workoutTypeLabel(WorkoutType type) {
  return switch (type) {
    WorkoutType.walk => 'Walk',
    WorkoutType.run => 'Run',
    WorkoutType.strength => 'Strength',
    WorkoutType.yoga => 'Yoga',
    WorkoutType.cycling => 'Cycling',
    WorkoutType.cardio => 'Cardio',
  };
}

IconData _workoutTypeIcon(WorkoutType type) {
  return switch (type) {
    WorkoutType.walk => Icons.directions_walk_rounded,
    WorkoutType.run => Icons.directions_run_rounded,
    WorkoutType.strength => Icons.fitness_center_rounded,
    WorkoutType.yoga => Icons.self_improvement_rounded,
    WorkoutType.cycling => Icons.directions_bike_rounded,
    WorkoutType.cardio => Icons.monitor_heart_rounded,
  };
}

Color _workoutTypeColor(WorkoutType type) {
  return switch (type) {
    WorkoutType.walk => AppColors.primary,
    WorkoutType.run => AppColors.accent,
    WorkoutType.strength => AppColors.secondary,
    WorkoutType.yoga => AppColors.purple,
    WorkoutType.cycling => AppColors.rose,
    WorkoutType.cardio => AppColors.danger,
  };
}
