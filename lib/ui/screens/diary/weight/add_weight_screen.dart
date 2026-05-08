import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({super.key});

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final _weightController = TextEditingController(text: '57.8');
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveWeight() {
    showDiarySavedMessage(context, 'Weight saved');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Add Weight',
      children: [
        const DiaryMetricHeader(
          icon: Icons.monitor_weight_rounded,
          color: Color(0xFF7357FF),
          title: 'Latest weight',
          value: '57.8 kg',
          subtitle: 'Down 2.2 kg in 90 days',
        ),
        const SizedBox(height: 16),
        DiaryNumberField(
          controller: _weightController,
          label: 'Weight',
          suffix: 'kg',
          icon: Icons.monitor_weight_rounded,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Note',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        const SizedBox(height: 20),
        DiarySaveButton(label: 'Save weight', onSave: _saveWeight),
      ],
    );
  }
}
