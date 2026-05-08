import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/water/add_water_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class WaterStatsScreen extends StatelessWidget {
  const WaterStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Water Stats',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWaterScreen()),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      children: const [
        DiaryMetricHeader(
          icon: Icons.water_drop_rounded,
          color: Color(0xFF1397E5),
          title: 'Today',
          value: '1.75 ltr',
          subtitle: '70% of your daily target',
        ),
        SizedBox(height: 16),
        DiaryProgressPanel(
          title: 'Daily Goal',
          value: 0.70,
          color: Color(0xFF1397E5),
          caption: '750 ml remaining',
        ),
        SizedBox(height: 16),
        DiaryLineChart(
          color: Color(0xFF1397E5),
          points: [0.72, 0.62, 0.48, 0.38, 0.30, 0.44, 0.28],
        ),
      ],
    );
  }
}
