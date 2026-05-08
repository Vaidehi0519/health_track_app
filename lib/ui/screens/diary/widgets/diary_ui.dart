import 'package:flutter/material.dart';

const diaryBackground = Color(0xFFF7FBFD);
const diaryText = Color(0xFF061A3A);
const diaryMutedText = Color(0xFF607080);
const diaryBorder = Color(0xFFE2EEF3);

class DiaryPageScaffold extends StatelessWidget {
  const DiaryPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: diaryBackground,
      appBar: AppBar(
        backgroundColor: diaryBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: actions,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: children,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class DiaryPanel extends StatelessWidget {
  const DiaryPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: diaryBorder),
        boxShadow: [
          BoxShadow(
            color: diaryText.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class DiaryMetricHeader extends StatelessWidget {
  const DiaryMetricHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DiaryPanel(
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: diaryMutedText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: diaryText,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: diaryMutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiaryStatTile extends StatelessWidget {
  const DiaryStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DiaryPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: diaryMutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: diaryText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class DiaryProgressPanel extends StatelessWidget {
  const DiaryProgressPanel({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.caption,
  });

  final String title;
  final double value;
  final Color color;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return DiaryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: diaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: value.clamp(0, 1),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caption,
            style: const TextStyle(
              color: diaryMutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class DiaryLineChart extends StatelessWidget {
  const DiaryLineChart({
    super.key,
    required this.color,
    required this.points,
    this.height = 180,
  });

  final Color color;
  final List<double> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DiaryPanel(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _DiaryLinePainter(color, points)),
      ),
    );
  }
}

class DiarySaveButton extends StatelessWidget {
  const DiarySaveButton({super.key, required this.label, required this.onSave});

  final String label;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onSave,
      icon: const Icon(Icons.check_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class DiaryNumberField extends StatelessWidget {
  const DiaryNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon == null ? null : Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: diaryBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: diaryBorder),
        ),
      ),
    );
  }
}

void showDiarySavedMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _DiaryLinePainter extends CustomPainter {
  const _DiaryLinePainter(this.color, this.points);

  final Color color;
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = diaryBorder
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
          colors: [color.withValues(alpha: 0.20), Colors.transparent],
        ).createShader(Offset.zero & size),
    );

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
  bool shouldRepaint(covariant _DiaryLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.points != points;
  }
}
