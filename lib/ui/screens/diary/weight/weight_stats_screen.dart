import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/weight/add_weight_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class WeightStatsScreen extends StatelessWidget {
  const WeightStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Weight Stats',
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Weight'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWeightScreen()),
          );
        },
      ),
      children: const [
        DiaryMetricHeader(
          icon: Icons.monitor_weight_rounded,
          color: Color(0xFF7357FF),
          title: 'Current weight',
          value: '57.8 kg',
          subtitle: 'Goal: 55.0 kg',
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DiaryStatTile(
                label: 'Change',
                value: '-2.2 kg',
                icon: Icons.trending_down_rounded,
                color: Color(0xFF32C74E),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: DiaryStatTile(
                label: 'BMI',
                value: '22.1',
                icon: Icons.analytics_rounded,
                color: Color(0xFF1397E5),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        DiaryLineChart(
          color: Color(0xFF7357FF),
          points: [0.62, 0.58, 0.54, 0.56, 0.50, 0.48, 0.45],
        ),
      ],
    );
  }
}
