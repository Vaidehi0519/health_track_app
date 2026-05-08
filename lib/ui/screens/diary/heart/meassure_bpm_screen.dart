import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class MeassureBPMScreen extends StatefulWidget {
  const MeassureBPMScreen({super.key});

  @override
  State<MeassureBPMScreen> createState() => _MeassureBPMScreenState();
}

class _MeassureBPMScreenState extends State<MeassureBPMScreen> {
  int _bpm = 76;
  bool _measuring = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMeasure() {
    setState(() => _measuring = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (timer.tick >= 8) {
        timer.cancel();
        setState(() => _measuring = false);
        showDiarySavedMessage(context, 'Heart rate recorded');
        return;
      }
      setState(() => _bpm = 72 + math.Random().nextInt(18));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Measure BPM',
      children: [
        DiaryMetricHeader(
          icon: Icons.monitor_heart_rounded,
          color: const Color(0xFFE84D4D),
          title: _measuring ? 'Measuring...' : 'Latest reading',
          value: '$_bpm bpm',
          subtitle: _measuring ? 'Keep your finger steady' : 'Resting range',
        ),
        const SizedBox(height: 16),
        const DiaryLineChart(
          color: Color(0xFFE84D4D),
          points: [0.46, 0.44, 0.18, 0.82, 0.34, 0.46, 0.20, 0.76, 0.42],
          height: 150,
        ),
        const SizedBox(height: 20),
        DiarySaveButton(
          label: _measuring ? 'Measuring...' : 'Start measurement',
          onSave: _measuring ? () {} : _startMeasure,
        ),
      ],
    );
  }
}
