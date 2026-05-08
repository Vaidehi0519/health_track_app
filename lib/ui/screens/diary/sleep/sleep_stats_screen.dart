import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/sleep/record_sleep_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class SleepStatsScreen extends StatelessWidget {
  const SleepStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Sleep Stats',
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordSleepScreen()),
          );
        },
      ),
      children: const [
        DiaryMetricHeader(
          icon: CupertinoIcons.moon_stars_fill,
          color: Color(0xFF7357FF),
          title: 'Last night',
          value: '7h 50m',
          subtitle: 'Good recovery',
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DiaryStatTile(
                label: 'Deep',
                value: '2h 10m',
                icon: Icons.bedtime_rounded,
                color: Color(0xFF7357FF),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: DiaryStatTile(
                label: 'Quality',
                value: '76%',
                icon: Icons.auto_awesome_rounded,
                color: Color(0xFF1397E5),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        DiaryLineChart(
          color: Color(0xFF7357FF),
          points: [0.40, 0.36, 0.32, 0.46, 0.28, 0.34, 0.30],
        ),
      ],
    );
  }
}
