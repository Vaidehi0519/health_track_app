import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/core/session_store.dart';
import 'package:health_track_app/ui/screens/auth/onboarding/onboarding_screen.dart';
import 'package:health_track_app/ui/screens/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _logoScale = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.58, curve: Curves.easeOutBack),
    );
    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.34, curve: Curves.easeOut),
    );
    _titleOffset = Tween<Offset>(begin: const Offset(0, 0.45), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.44, 0.82, curve: Curves.easeOutCubic),
          ),
        );
    _contentOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.46, 1, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 3300), () async {
      if (!mounted) return;
      final isLoggedIn = await SessionStore.isLoggedIn();
      final hasFirebaseSession = FirebaseAuth.instance.currentUser != null;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
                opacity: animation,
                child: isLoggedIn || hasFirebaseSession
                    ? const AppShell()
                    : const OnboardingScreen(),
              ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = math.min(size.width * 0.5, 230.0);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FFFB), Color(0xFFEAF7FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _SplashBackgroundPainter(
                        progress: _pulseController.value,
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _introController,
                          _pulseController,
                        ]),
                        builder: (context, child) {
                          final pulse =
                              1 +
                              (math.sin(_pulseController.value * math.pi * 2) *
                                  0.025);
                          return Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value * pulse,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0B6BB7,
                                ).withValues(alpha: 0.13),
                                blurRadius: 34,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFF29B743,
                                ).withValues(alpha: 0.10),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _contentOpacity,
                        child: SlideTransition(
                          position: _titleOffset,
                          child: Column(
                            children: [
                              Text(
                                'Health Tracker',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: const Color(0xFF061A3A),
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Track better. Feel stronger.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: const Color(0xFF526273),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 34),
                              const _LoadingIndicator(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2300),
      curve: Curves.easeInOutCubic,
      builder: (context, value, _) {
        return Container(
          width: 156,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFD7E8EE),
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF32C74E), Color(0xFF1397E5)],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  _SplashBackgroundPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF1397E5).withValues(alpha: 0.08);
    final greenRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF32C74E).withValues(alpha: 0.08);
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3
      ..shader = const LinearGradient(
        colors: [Color(0xFF32C74E), Color(0xFF1397E5)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2 - 24);
    final maxRadius = math.max(size.width, size.height) * 0.42;
    for (var i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1;
      final radius = 90 + (maxRadius - 90) * t;
      final opacity = (1 - t).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        radius,
        ringPaint
          ..color = const Color(0xFF1397E5).withValues(alpha: 0.07 * opacity),
      );
      canvas.drawCircle(
        center.translate(0, 10),
        radius * 0.74,
        greenRingPaint
          ..color = const Color(0xFF32C74E).withValues(alpha: 0.055 * opacity),
      );
    }

    final path = Path();
    final y = size.height * 0.74;
    final startX = size.width * 0.18;
    final endX = size.width * 0.82;
    final width = endX - startX;
    path.moveTo(startX, y);
    path.lineTo(startX + width * 0.23, y);
    path.lineTo(startX + width * 0.31, y + 18);
    path.lineTo(startX + width * 0.39, y - 38);
    path.lineTo(startX + width * 0.49, y + 32);
    path.lineTo(startX + width * 0.57, y - 8);
    path.lineTo(startX + width * 0.66, y);
    path.lineTo(endX, y);

    final metric = path.computeMetrics().first;
    final visiblePath = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(visiblePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _SplashBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
