import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/utils/app_feedback.dart';
import 'package:health_track_app/ui/screens/diary/widgets/diary_ui.dart';

class AddWaterScreen extends StatefulWidget {
  const AddWaterScreen({super.key});

  @override
  State<AddWaterScreen> createState() => _AddWaterScreenState();
}

class _AddWaterScreenState extends State<AddWaterScreen> {
  final _amountController = TextEditingController(text: '250');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addWater() async {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      AppFeedback.showSnackBar(
        context,
        'Enter a water amount greater than zero',
        icon: Icons.error_rounded,
      );
      return;
    }

    await AppScope.of(context).addWater(amount);
    if (!mounted) return;
    showDiarySavedMessage(context, 'Water added');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final totalMl = AppScope.of(context).metrics.waterMl;

    return DiaryPageScaffold(
      title: 'Add Water',
      children: [
        DiaryMetricHeader(
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF1397E5),
          title: 'Current intake',
          value: '${(totalMl / 1000).toStringAsFixed(2)} ltr',
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
              onPressed: () {
                _amountController.text = '$amount';
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        DiarySaveButton(label: 'Add water', onSave: _addWater),
      ],
    );
  }
}
