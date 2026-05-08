import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/diary/heart/heart_stats_screen.dart';
import 'package:health_track_app/ui/screens/diary/heart/meassure_bpm_screen.dart';
import 'package:health_track_app/ui/screens/diary/nutrition/add_meal_screen.dart';
import 'package:health_track_app/ui/screens/diary/nutrition/calories_stats_screen.dart';
import 'package:health_track_app/ui/screens/diary/sleep/record_sleep_screen.dart';
import 'package:health_track_app/ui/screens/diary/sleep/sleep_stats_screen.dart';
import 'package:health_track_app/ui/screens/diary/water/add_water_screen.dart';
import 'package:health_track_app/ui/screens/diary/water/water_stats_screen.dart';
import 'package:health_track_app/ui/screens/diary/weight/add_weight_screen.dart';
import 'package:health_track_app/ui/screens/diary/weight/weight_stats_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _selectedDate = DateTime.now();
  int _steps = 8240;
  int _waterMl = 1750;
  int _calories = 1560;
  int _carbs = 185;
  int _fat = 46;
  int _protein = 82;
  int _heartRate = 76;
  int _sleepMinutes = 470;
  double _weight = 57.8;

  bool get _isToday {
    final now = DateTime.now();
    return now.year == _selectedDate.year &&
        now.month == _selectedDate.month &&
        now.day == _selectedDate.day;
  }

  Future<void> _pickDate() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
    );

    if (newDate == null) return;
    setState(() => _selectedDate = newDate);
  }

  void _quickAdd(_DiaryAction action) {
    setState(() {
      switch (action) {
        case _DiaryAction.water:
          _waterMl = (_waterMl + 250).clamp(0, 4000);
        case _DiaryAction.meal:
          _calories += 320;
          _carbs += 36;
          _fat += 10;
          _protein += 18;
        case _DiaryAction.steps:
          _steps += 1000;
        case _DiaryAction.heart:
          _heartRate = 74 + math.Random().nextInt(10);
        case _DiaryAction.sleep:
          _sleepMinutes = (_sleepMinutes + 30).clamp(0, 720);
        case _DiaryAction.weight:
          _weight = double.parse((_weight + 0.1).toStringAsFixed(1));
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${action.label} updated')));
  }

  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _showQuickAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick add',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.08,
                  children: _DiaryAction.values.map((action) {
                    return _QuickActionButton(
                      action: action,
                      onTap: () {
                        Navigator.pop(context);
                        switch (action) {
                          case _DiaryAction.water:
                            _openScreen(const AddWaterScreen());
                          case _DiaryAction.meal:
                            _openScreen(const AddMealScreen());
                          case _DiaryAction.steps:
                            _quickAdd(action);
                          case _DiaryAction.heart:
                            _openScreen(const MeassureBPMScreen());
                          case _DiaryAction.sleep:
                            _openScreen(const RecordSleepScreen());
                          case _DiaryAction.weight:
                            _openScreen(const AddWeightScreen());
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final waterLiters = (_waterMl / 1000).toStringAsFixed(2);
    final sleepHours = '${_sleepMinutes ~/ 60}h ${_sleepMinutes % 60}m';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: _DiaryHeader(
                  selectedDate: _selectedDate,
                  isToday: _isToday,
                  onPickDate: _pickDate,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _ActivityCard(steps: _steps),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _HeartCard(
                              heartRate: _heartRate,
                              onTap: () =>
                                  _openScreen(const HeartStatsScreen()),
                            ),
                            const SizedBox(height: 14),
                            _WaterCard(
                              liters: waterLiters,
                              progress: _waterMl / 2500,
                              onTap: () =>
                                  _openScreen(const WaterStatsScreen()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            _CaloriesCard(
                              calories: _calories,
                              carbs: _carbs,
                              fat: _fat,
                              protein: _protein,
                              onTap: () => _openScreen(
                                CaloriesStatsScreen(date: _selectedDate),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _SleepCard(
                              sleepText: sleepHours,
                              onTap: () =>
                                  _openScreen(const SleepStatsScreen()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _WeightCard(
                    weight: _weight,
                    onTap: () => _openScreen(const WeightStatsScreen()),
                  ),
                  const SizedBox(height: 14),
                  _InsightPanel(colorScheme: colorScheme),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: _showQuickAddSheet,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _DiaryHeader extends StatelessWidget {
  const _DiaryHeader({
    required this.selectedDate,
    required this.isToday,
    required this.onPickDate,
  });

  final DateTime selectedDate;
  final bool isToday;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, const Color(0xFF32C74E)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.20),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Good morning, Vaidehi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onPickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isToday ? 'Today' : _formatDate(selectedDate),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: 0.72,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '72% of today\'s wellness targets complete',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.steps});

  final int steps;

  @override
  Widget build(BuildContext context) {
    final calories = (steps * 0.04).round();
    final distance = (steps * 0.0007).toStringAsFixed(2);

    return _DiaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Activity',
            icon: Icons.directions_walk_rounded,
            color: Color(0xFF32C74E),
            trailing: 'Today',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ProgressRing(
                  value: steps / 12000,
                  color: const Color(0xFF32C74E),
                  label: '$steps',
                  caption: 'Steps',
                ),
              ),
              Expanded(
                child: _ProgressRing(
                  value: calories / 700,
                  color: const Color(0xFFFF7A1A),
                  label: '$calories',
                  caption: 'Kcal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  icon: Icons.location_on_rounded,
                  label: 'Distance',
                  value: '$distance km',
                  color: const Color(0xFFFF7A1A),
                ),
              ),
              const Expanded(
                child: _MiniMetric(
                  icon: Icons.speed_rounded,
                  label: 'Walking',
                  value: '76%',
                  color: Color(0xFF32C74E),
                ),
              ),
              const Expanded(
                child: _MiniMetric(
                  icon: Icons.directions_run_rounded,
                  label: 'Running',
                  value: '24%',
                  color: Color(0xFFE84D89),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeartCard extends StatelessWidget {
  const _HeartCard({required this.heartRate, required this.onTap});

  final int heartRate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DiaryCard(
      onTap: onTap,
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Heart',
            icon: Icons.monitor_heart_rounded,
            color: Color(0xFFE84D4D),
          ),
          const SizedBox(height: 14),
          const SizedBox(
            height: 82,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineGraphPainter(
                color: Color(0xFFE84D4D),
                points: [0.44, 0.44, 0.18, 0.82, 0.34, 0.46, 0.46, 0.20, 0.74],
              ),
            ),
          ),
          _ValueWithUnit(value: '$heartRate', unit: 'bpm'),
        ],
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard({
    required this.liters,
    required this.progress,
    required this.onTap,
  });

  final String liters;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DiaryCard(
      onTap: onTap,
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Water',
            icon: Icons.water_drop_rounded,
            color: Color(0xFF1397E5),
          ),
          const SizedBox(height: 18),
          _ProgressRing(
            value: progress,
            color: const Color(0xFF1397E5),
            label: liters,
            caption: 'Liters',
            radius: 42,
          ),
          const SizedBox(height: 14),
          _ValueWithUnit(value: liters, unit: 'ltr'),
        ],
      ),
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.onTap,
  });

  final int calories;
  final int carbs;
  final int fat;
  final int protein;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DiaryCard(
      onTap: onTap,
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Calories',
            icon: Icons.local_fire_department_rounded,
            color: Color(0xFFFF7A1A),
          ),
          const SizedBox(height: 16),
          Center(
            child: _ProgressRing(
              value: calories / 2100,
              color: const Color(0xFFFF7A1A),
              label: '$calories',
              caption: 'Kcal',
              radius: 46,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MacroChip(label: 'Carbs', value: '${carbs}g'),
              _MacroChip(label: 'Fat', value: '${fat}g'),
              _MacroChip(label: 'Protein', value: '${protein}g'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({required this.sleepText, required this.onTap});

  final String sleepText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DiaryCard(
      onTap: onTap,
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Sleep',
            icon: CupertinoIcons.moon_stars_fill,
            color: Color(0xFF7357FF),
          ),
          const SizedBox(height: 28),
          _ValueWithUnit(value: sleepText, unit: '/day'),
          const SizedBox(height: 8),
          Text(
            'Deep sleep trend is steady',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.weight, required this.onTap});

  final double weight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DiaryCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Weight',
            icon: Icons.monitor_weight_rounded,
            color: Color(0xFF7357FF),
            trailing: '90 days',
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineGraphPainter(
                color: const Color(0xFF7357FF),
                fill: true,
                points: [0.62, 0.58, 0.54, 0.56, 0.50, 0.48, 0.45],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _ValueWithUnit(value: weight.toStringAsFixed(1), unit: 'kg'),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'You are close to your hydration goal. Add one more glass before dinner.',
              style: TextStyle(
                color: Color(0xFF061A3A),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({required this.child, this.compact = false, this.onTap});

  final Widget child;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 14 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2EEF3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF061A3A).withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.title,
    required this.icon,
    required this.color,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF061A3A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: Color(0xFF81909D),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        Icon(icon, color: color, size: 23),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.value,
    required this.color,
    required this.label,
    required this.caption,
    this.radius = 52,
  });

  final double value;
  final Color color;
  final String label;
  final String caption;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: radius * 2,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF061A3A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                caption,
                style: const TextStyle(
                  color: Color(0xFF81909D),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF607080),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF061A3A),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ValueWithUnit extends StatelessWidget {
  const _ValueWithUnit({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF061A3A),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            unit,
            style: const TextStyle(
              color: Color(0xFF81909D),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2EEF3)),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Color(0xFF607080),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action, required this.onTap});

  final _DiaryAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: action.color.withValues(alpha: 0.16)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF061A3A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  const _LineGraphPainter({
    required this.color,
    required this.points,
    this.fill = false,
  });

  final Color color;
  final List<double> points;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2EEF3)
      ..strokeWidth = 1;

    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height * points[i].clamp(0, 1);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.22), Colors.transparent],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.fill != fill ||
        oldDelegate.points != points;
  }
}

enum _DiaryAction {
  water('Water', Icons.water_drop_rounded, Color(0xFF1397E5)),
  meal('Meal', Icons.restaurant_rounded, Color(0xFFFF7A1A)),
  steps('Steps', Icons.directions_walk_rounded, Color(0xFF32C74E)),
  heart('Heart', Icons.monitor_heart_rounded, Color(0xFFE84D4D)),
  sleep('Sleep', CupertinoIcons.moon_stars_fill, Color(0xFF7357FF)),
  weight('Weight', Icons.monitor_weight_rounded, Color(0xFF7357FF));

  const _DiaryAction(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

String _formatDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${date.day} ${months[date.month - 1]}, ${date.year}';
}
