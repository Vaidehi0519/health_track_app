import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class RecordSleepScreen extends StatefulWidget {
  const RecordSleepScreen({super.key});

  @override
  State<RecordSleepScreen> createState() => _RecordSleepScreenState();
}

class _RecordSleepScreenState extends State<RecordSleepScreen> {
  final _hoursController = TextEditingController(text: '7');
  final _minutesController = TextEditingController(text: '50');
  double _quality = 0.76;

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _saveSleep() {
    showDiarySavedMessage(context, 'Sleep recorded');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Record Sleep',
      children: [
        const DiaryMetricHeader(
          icon: CupertinoIcons.moon_stars_fill,
          color: Color(0xFF7357FF),
          title: 'Sleep target',
          value: '8h 00m',
          subtitle: 'Recommended daily goal',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DiaryNumberField(
                controller: _hoursController,
                label: 'Hours',
                suffix: 'h',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DiaryNumberField(
                controller: _minutesController,
                label: 'Minutes',
                suffix: 'm',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DiaryPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sleep quality',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Slider(
                value: _quality,
                onChanged: (value) => setState(() => _quality = value),
              ),
              Text('${(_quality * 100).round()}% quality'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DiarySaveButton(label: 'Save sleep', onSave: _saveSleep),
      ],
    );
  }
}
