import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/auth/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.monitor_heart_rounded,
      title: 'Track your health in one place',
      description:
          'Follow vitals, habits, steps, and everyday wellness progress with a simple daily view.',
      accentColor: Color(0xFF1397E5),
    ),
    _OnboardingPageData(
      icon: Icons.insights_rounded,
      title: 'Understand your progress',
      description:
          'Turn your check-ins into clean insights so you can spot patterns and stay motivated.',
      accentColor: Color(0xFF32C74E),
    ),
    _OnboardingPageData(
      icon: Icons.emoji_events_rounded,
      title: 'Build habits that last',
      description:
          'Set small goals, keep your streak alive, and make healthier routines feel achievable.',
      accentColor: Color(0xFF0B6BB7),
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openWelcome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: const WelcomeScreen(),
          );
        },
      ),
    );
  }

  void _goNext() {
    if (_isLastPage) {
      _openWelcome();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 430),
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
                top: 34,
                right: -54,
                child: _GlowCircle(size: 190, color: Color(0xFF1397E5)),
              ),
              const Positioned(
                bottom: 140,
                left: -70,
                child: _GlowCircle(size: 210, color: Color(0xFF32C74E)),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.10,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Health Tracker',
                          style: TextStyle(
                            color: Color(0xFF061A3A),
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _openWelcome,
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _OnboardingPage(
                          key: ValueKey(_pages[index].title),
                          data: _pages[index],
                          pageNumber: index + 1,
                          totalPages: _pages.length,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
                    child: Column(
                      children: [
                        _PageIndicators(
                          count: _pages.length,
                          selectedIndex: _currentPage,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
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
                                    _isLastPage ? 'Get started' : 'Next',
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
                      ],
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
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    super.key,
    required this.data,
    required this.pageNumber,
    required this.totalPages,
  });

  final _OnboardingPageData data;
  final int pageNumber;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final artSize = (constraints.maxWidth * 0.62).clamp(190.0, 270.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 520),
                  child: _HealthIllustration(
                    size: artSize,
                    icon: data.icon,
                    accentColor: data.accentColor,
                  ),
                ),
                const SizedBox(height: 38),
                FadeInUp(
                  delay: const Duration(milliseconds: 120),
                  duration: const Duration(milliseconds: 520),
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF061A3A),
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeInUp(
                  delay: const Duration(milliseconds: 180),
                  duration: const Duration(milliseconds: 520),
                  child: Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF607080),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 240),
                  duration: const Duration(milliseconds: 520),
                  child: _StepBadge(
                    pageNumber: pageNumber,
                    totalPages: totalPages,
                    accentColor: data.accentColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HealthIllustration extends StatelessWidget {
  const _HealthIllustration({
    required this.size,
    required this.icon,
    required this.accentColor,
  });

  final double size;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.92 + (0.08 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, accentColor.withValues(alpha: 0.10)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.16),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: Size.square(size * 0.78),
              painter: _PulseLinePainter(color: accentColor),
            ),
            Container(
              width: size * 0.46,
              height: size * 0.46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accentColor, const Color(0xFF32C74E)],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: size * 0.22),
            ),
            Positioned(
              right: size * 0.12,
              top: size * 0.18,
              child: _MiniMetric(
                icon: Icons.favorite_rounded,
                color: const Color(0xFFE5484D),
                text: '82',
              ),
            ),
            Positioned(
              left: size * 0.10,
              bottom: size * 0.18,
              child: _MiniMetric(
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFF32C74E),
                text: '1.8k',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF061A3A),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.pageNumber,
    required this.totalPages,
    required this.accentColor,
  });

  final int pageNumber;
  final int totalPages;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Text(
        '$pageNumber of $totalPages',
        style: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: isSelected ? 28 : 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFD7E8EE),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _PulseLinePainter extends CustomPainter {
  _PulseLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4
      ..color = color.withValues(alpha: 0.45);

    final path = Path();
    final y = size.height * 0.56;
    path.moveTo(size.width * 0.05, y);
    path.lineTo(size.width * 0.24, y);
    path.lineTo(size.width * 0.32, y + 20);
    path.lineTo(size.width * 0.43, y - 46);
    path.lineTo(size.width * 0.55, y + 34);
    path.lineTo(size.width * 0.65, y - 12);
    path.lineTo(size.width * 0.74, y);
    path.lineTo(size.width * 0.95, y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseLinePainter oldDelegate) {
    return oldDelegate.color != color;
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

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
}
