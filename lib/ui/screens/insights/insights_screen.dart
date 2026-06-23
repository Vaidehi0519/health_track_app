import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/theme/app_theme.dart';
import 'package:health_track_app/ui/widgets/health_components.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _addWeight() async {
    final appState = AppScope.read(context);
    _weightController.text = appState.currentWeightKg.toStringAsFixed(1);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add weight'),
          content: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Weight kg',
              prefixIcon: Icon(Icons.monitor_weight_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final weight = double.tryParse(_weightController.text);
                if (weight == null || weight <= 0) return;
                final navigator = Navigator.of(context);
                final route = ModalRoute.of(context);
                await appState.addWeight(weight);
                if (navigator.mounted && (route?.isCurrent ?? false)) {
                  navigator.pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final values = appState.weightEntries
        .take(12)
        .map((entry) => entry.weightKg)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            tooltip: 'Add weight',
            onPressed: _addWeight,
            icon: const Icon(Icons.add_chart_rounded),
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
                    icon: Icons.monitor_weight_rounded,
                    label: 'Weight',
                    value: '${appState.currentWeightKg.toStringAsFixed(1)}kg',
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthStatCard(
                    icon: Icons.health_and_safety_rounded,
                    label: 'BMI',
                    value: appState.bmi.toStringAsFixed(1),
                    subtitle: appState.bmiCategory,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Weight trend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Add weight',
                        onPressed: _addWeight,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TrendChart(
                    values: values.isEmpty
                        ? [appState.currentWeightKg]
                        : values,
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nutrition targets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: appState.dailyCalories / appState.dailyCalorieTarget,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.accent,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${appState.dailyCalories} of ${appState.dailyCalorieTarget} kcal',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: appState.dailyProtein / appState.dailyProteinTarget,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.secondary,
                    backgroundColor: AppColors.secondary.withValues(
                      alpha: 0.12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${appState.dailyProtein} of ${appState.dailyProteinTarget}g protein',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
