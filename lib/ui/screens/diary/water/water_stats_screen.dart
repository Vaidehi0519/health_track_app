import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/water/add_water_screen.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterStatsScreen extends StatefulWidget {
  const WaterStatsScreen({super.key});

  @override
  State<WaterStatsScreen> createState() => _WaterStatsScreenState();
}

class _WaterStatsScreenState extends State<WaterStatsScreen> {
  int _totalMl = 1750;
  static const String waterKey = 'total_water_ml';
  final int _dailyGoal = 2500;

  double get _progressValue => _totalMl / _dailyGoal;
  int get _remainingMl => (_dailyGoal - _totalMl).clamp(0, _dailyGoal);

  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _totalMl = prefs.getInt(waterKey) ?? 1750;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Water Stats',
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWaterScreen()),
          );

          _loadWaterData();
        },
        child: const Icon(Icons.add_rounded),
      ),
      children: [
        DiaryMetricHeader(
          icon: Icons.water_drop_rounded,
          color: Color(0xFF1397E5),
          title: 'Today',
          value: '${(_totalMl / 1000).toStringAsFixed(2)} ltr',
          subtitle: '70% of your daily target',
        ),
        SizedBox(height: 16),
        DiaryProgressPanel(
          title: 'Daily Goal',
          value: _progressValue,
          color: Color(0xFF1397E5),
          caption: _remainingMl == 0
              ? 'Daily goal achieved 🎉'
              : '$_remainingMl ml remaining',
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
