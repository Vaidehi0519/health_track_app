import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/heart/meassure_bpm_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class HeartStatsScreen extends StatelessWidget {
  const HeartStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Heart Rate',
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.monitor_heart_rounded),
        label: const Text('Measure'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeassureBPMScreen()),
          );
        },
      ),
      children: const [
        DiaryMetricHeader(
          icon: Icons.monitor_heart_rounded,
          color: Color(0xFFE84D4D),
          title: 'Average today',
          value: '76 bpm',
          subtitle: 'Normal resting range',
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DiaryStatTile(
                label: 'Lowest',
                value: '68',
                icon: Icons.arrow_downward_rounded,
                color: Color(0xFF32C74E),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: DiaryStatTile(
                label: 'Highest',
                value: '112',
                icon: Icons.arrow_upward_rounded,
                color: Color(0xFFFF7A1A),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        DiaryLineChart(
          color: Color(0xFFE84D4D),
          points: [0.54, 0.46, 0.50, 0.35, 0.42, 0.31, 0.40, 0.28],
        ),
      ],
    );
  }
}
