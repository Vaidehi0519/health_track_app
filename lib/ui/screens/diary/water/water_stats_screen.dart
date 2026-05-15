import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/ui/screens/diary/water/add_water_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class WaterStatsScreen extends StatelessWidget {
  const WaterStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalMl = AppScope.of(context).metrics.waterMl;
    const dailyGoal = 2500;
    final progressValue = totalMl / dailyGoal;
    final remainingMl = (dailyGoal - totalMl).clamp(0, dailyGoal);

    return DiaryPageScaffold(
      title: 'Water Stats',
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final appState = AppScope.of(context);
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWaterScreen()),
          );

          await appState.refreshWater();
        },
        child: const Icon(Icons.add_rounded),
      ),
      children: [
        DiaryMetricHeader(
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF1397E5),
          title: 'Today',
          value: '${(totalMl / 1000).toStringAsFixed(2)} ltr',
          subtitle:
              '${(progressValue.clamp(0, 1) * 100).round()}% of your daily target',
        ),
        const SizedBox(height: 16),
        DiaryProgressPanel(
          title: 'Daily Goal',
          value: progressValue,
          color: const Color(0xFF1397E5),
          caption: remainingMl == 0
              ? 'Daily goal achieved 🎉'
              : '$remainingMl ml remaining',
        ),
        const SizedBox(height: 16),
        const DiaryLineChart(
          color: Color(0xFF1397E5),
          points: [0.72, 0.62, 0.48, 0.38, 0.30, 0.44, 0.28],
        ),
      ],
    );
  }
}
