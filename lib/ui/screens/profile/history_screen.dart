import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/state/app_state.dart';
import 'package:health_track_app/core/theme/app_theme.dart';
import 'package:health_track_app/domain/models/health_entry.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final events = _buildEvents(appState).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final workouts = events
        .where((event) => event.category == _HistoryCategory.workout)
        .toList();
    final meals = events
        .where((event) => event.category == _HistoryCategory.meal)
        .toList();
    final water = events
        .where((event) => event.category == _HistoryCategory.water)
        .toList();
    final weight = events
        .where((event) => event.category == _HistoryCategory.weight)
        .toList();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Health history'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Workouts'),
              Tab(text: 'Meals'),
              Tab(text: 'Water'),
              Tab(text: 'Weight'),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _HistorySummary(
                workoutCount: appState.workouts.length,
                mealCount: appState.meals.length,
                waterCount: appState.waterEntries.length,
                weightCount: appState.weightEntries.length,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _HistoryList(events: events),
                    _HistoryList(events: workouts),
                    _HistoryList(events: meals),
                    _HistoryList(events: water),
                    _HistoryList(events: weight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Iterable<_HistoryEvent> _buildEvents(AppState appState) sync* {
    for (final workout in appState.workouts) {
      yield _HistoryEvent(
        category: _HistoryCategory.workout,
        title: workout.name,
        subtitle: '${_workoutTypeLabel(workout.type)} - ${workout.minutes} min',
        detail: '${workout.caloriesBurned} kcal',
        createdAt: workout.createdAt,
        icon: _workoutTypeIcon(workout.type),
        color: AppColors.secondary,
      );
    }

    for (final meal in appState.meals) {
      yield _HistoryEvent(
        category: _HistoryCategory.meal,
        title: meal.name,
        subtitle: '${_mealTypeLabel(meal.type)} - ${meal.protein}g protein',
        detail: '${meal.calories} kcal',
        createdAt: meal.createdAt,
        icon: Icons.restaurant_rounded,
        color: AppColors.accent,
      );
    }

    for (final entry in appState.waterEntries) {
      yield _HistoryEvent(
        category: _HistoryCategory.water,
        title: 'Water intake',
        subtitle: '${(entry.amountMl / 1000).toStringAsFixed(2)} ltr',
        detail: '${entry.amountMl} ml',
        createdAt: entry.createdAt,
        icon: Icons.water_drop_rounded,
        color: AppColors.primary,
      );
    }

    for (final entry in appState.weightEntries) {
      yield _HistoryEvent(
        category: _HistoryCategory.weight,
        title: 'Weight logged',
        subtitle: '${entry.weightKg.toStringAsFixed(1)} kg',
        detail: 'BMI ${appState.bmi.toStringAsFixed(1)}',
        createdAt: entry.createdAt,
        icon: Icons.monitor_weight_rounded,
        color: AppColors.purple,
      );
    }
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({
    required this.workoutCount,
    required this.mealCount,
    required this.waterCount,
    required this.weightCount,
  });

  final int workoutCount;
  final int mealCount;
  final int waterCount;
  final int weightCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              label: 'Move',
              value: '$workoutCount',
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryTile(
              label: 'Meals',
              value: '$mealCount',
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryTile(
              label: 'Water',
              value: '$waterCount',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryTile(
              label: 'Weight',
              value: '$weightCount',
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.66),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.events});

  final List<_HistoryEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _EmptyHistory();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _HistoryTile(event: events[index]),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.event});

  final _HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(event.icon, color: event.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      event.detail,
                      style: TextStyle(
                        color: event.color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.64),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDateTime(event.createdAt),
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.48),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 52,
              color: AppColors.muted.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            const Text(
              'No history yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Saved workouts, meals, water, and weight logs will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _HistoryCategory { workout, meal, water, weight }

class _HistoryEvent {
  const _HistoryEvent({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.createdAt,
    required this.icon,
    required this.color,
  });

  final _HistoryCategory category;
  final String title;
  final String subtitle;
  final String detail;
  final DateTime createdAt;
  final IconData icon;
  final Color color;
}

String _formatDateTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_monthName(date.month)} ${date.day}, ${date.year} - $hour:$minute $period';
}

String _monthName(int month) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[(month - 1).clamp(0, 11)];
}

String _mealTypeLabel(MealType type) {
  return switch (type) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
  };
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
