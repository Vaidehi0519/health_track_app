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
    final appState = AppScope.of(context);
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
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: WorkoutType.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.name),
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
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NumberInput(
                              controller: caloriesController,
                              label: 'Calories',
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
                          await appState.addWorkout(
                            name: nameController.text.trim(),
                            type: type,
                            minutes: int.parse(minutesController.text),
                            caloriesBurned: int.parse(caloriesController.text),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
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
    final workouts = appState.workouts;
    final caloriesBurned = workouts.fold<int>(
      0,
      (total, workout) => total + workout.caloriesBurned,
    );

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
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthStatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Burned',
                    value: '$caloriesBurned',
                    subtitle: 'kcal total',
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
            const Text(
              'Workout history',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (workouts.isEmpty)
              const EmptyState(
                icon: Icons.directions_run_rounded,
                title: 'No workouts logged',
                message: 'Add walks, strength sessions, yoga, or cardio here.',
              )
            else
              ...workouts.map(
                (workout) => Padding(
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
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: Text(
                      workout.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${workout.type.name} - ${workout.minutes} minutes',
                    ),
                    trailing: Text(
                      '${workout.caloriesBurned} kcal',
                      style: const TextStyle(fontWeight: FontWeight.w900),
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
  const _NumberInput({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final number = int.tryParse(value ?? '');
        if (number == null || number <= 0) return 'Required';
        return null;
      },
    );
  }
}
