import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class AddWaterScreen extends StatefulWidget {
  const AddWaterScreen({super.key});

  @override
  State<AddWaterScreen> createState() => _AddWaterScreenState();
}

class _AddWaterScreenState extends State<AddWaterScreen> {
  final _amountController = TextEditingController(text: '250');
  int _totalMl = 1750;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addWater() {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    setState(() => _totalMl = (_totalMl + amount).clamp(0, 5000));
    showDiarySavedMessage(context, 'Water added');
  }

  @override
  Widget build(BuildContext context) {
    return DiaryPageScaffold(
      title: 'Add Water',
      children: [
        DiaryMetricHeader(
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF1397E5),
          title: 'Current intake',
          value: '${(_totalMl / 1000).toStringAsFixed(2)} ltr',
          subtitle: 'Goal: 2.5 ltr',
        ),
        const SizedBox(height: 16),
        DiaryNumberField(
          controller: _amountController,
          label: 'Amount',
          suffix: 'ml',
          icon: Icons.local_drink_rounded,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [150, 250, 500, 750].map((amount) {
            return ActionChip(
              label: Text('$amount ml'),
              onPressed: () => _amountController.text = '$amount',
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        DiarySaveButton(label: 'Add water', onSave: _addWater),
      ],
    );
  }
}
