import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/auth/about/about_content.dart';
import 'package:health_track_app/ui/screens/auth/about/widget/gender_picker.dart';
import 'package:health_track_app/ui/screens/auth/registration_screen.dart';

class AboutYouScreen extends StatefulWidget {
  const AboutYouScreen({super.key});

  @override
  State<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  final _controller = PageController();

  Sex _sex = Sex.female;
  int _age = 24;
  double _weight = 58;
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == aboutContents.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentPage == 0) {
      Navigator.pop(context);
      return;
    }

    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() {
    if (_isLastPage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
      );
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7FFF9), Color(0xFFEAF7FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 42,
                right: -54,
                child: _GlowCircle(size: 180, color: Color(0xFF1397E5)),
              ),
              const Positioned(
                bottom: 120,
                left: -64,
                child: _GlowCircle(size: 210, color: Color(0xFF32C74E)),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onPressed: _goBack,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationScreen(),
                              ),
                            );
                          },
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 6),
                    child: _ProgressHeader(
                      currentPage: _currentPage,
                      totalPages: aboutContents.length,
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (value) {
                        setState(() => _currentPage = value);
                      },
                      itemCount: aboutContents.length,
                      itemBuilder: (context, index) {
                        final content = aboutContents[index];
                        return _AboutPage(
                          key: ValueKey(content.title),
                          content: content,
                          child: _buildPageBody(index),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 26),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 8,
                          shadowColor: colorScheme.primary.withValues(
                            alpha: 0.28,
                          ),
                        ),
                        onPressed: _goNext,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Row(
                            key: ValueKey(_isLastPage),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLastPage ? 'Continue' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                _isLastPage
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageBody(int index) {
    switch (index) {
      case 0:
        return GenderPicker(
          selectedSex: _sex,
          onChanged: (value) => setState(() => _sex = value),
        );
      case 1:
        return _MetricPicker(
          value: _age.toDouble(),
          min: 12,
          max: 90,
          divisions: 78,
          label: '$_age',
          unit: 'years',
          icon: Icons.cake_rounded,
          onChanged: (value) => setState(() => _age = value.round()),
        );
      default:
        return _MetricPicker(
          value: _weight,
          min: 30,
          max: 160,
          divisions: 130,
          label: _weight.round().toString(),
          unit: 'kg',
          icon: Icons.monitor_weight_rounded,
          onChanged: (value) => setState(() => _weight = value),
        );
    }
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage({super.key, required this.content, required this.child});

  final AboutContent content;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 520),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [content.accentColor, const Color(0xFF32C74E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: content.accentColor.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Icon(content.icon, color: Colors.white, size: 42),
                  ),
                ),
                const SizedBox(height: 26),
                FadeInUp(
                  delay: const Duration(milliseconds: 120),
                  duration: const Duration(milliseconds: 520),
                  child: Text(
                    content.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF061A3A),
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 180),
                  duration: const Duration(milliseconds: 520),
                  child: Text(
                    content.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF607080),
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                FadeInUp(
                  delay: const Duration(milliseconds: 240),
                  duration: const Duration(milliseconds: 520),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricPicker extends StatelessWidget {
  const _MetricPicker({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.unit,
    required this.icon,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final String unit;
  final IconData icon;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD9E7EE)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 34),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Color(0xFF061A3A),
                fontSize: 54,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: Color(0xFF607080),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: const Color(0xFFD7E8EE),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.14),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.currentPage, required this.totalPages});

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final progress = (currentPage + 1) / totalPages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'About you',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF061A3A),
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              '${currentPage + 1}/$totalPages',
              style: const TextStyle(
                color: Color(0xFF607080),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: progress,
            backgroundColor: const Color(0xFFD7E8EE),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: 'Back',
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}
