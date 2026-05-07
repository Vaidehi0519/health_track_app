import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/auth/about/about_screen.dart';
import 'package:health_track_app/ui/screens/auth/login_screens.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                top: 54,
                right: -52,
                child: _GlowCircle(size: 180, color: Color(0xFF1397E5)),
              ),
              const Positioned(
                bottom: 110,
                left: -70,
                child: _GlowCircle(size: 210, color: Color(0xFF32C74E)),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 58,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeInDown(
                                duration: const Duration(milliseconds: 600),
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(44),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF1397E5,
                                        ).withValues(alpha: 0.14),
                                        blurRadius: 34,
                                        offset: const Offset(0, 18),
                                      ),
                                      BoxShadow(
                                        color: const Color(
                                          0xFF32C74E,
                                        ).withValues(alpha: 0.12),
                                        blurRadius: 24,
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
                              const SizedBox(height: 34),
                              FadeInUp(
                                delay: const Duration(milliseconds: 120),
                                duration: const Duration(milliseconds: 550),
                                child: Text(
                                  'Health Tracker',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: const Color(0xFF061A3A),
                                        fontWeight: FontWeight.w900,
                                        height: 1.05,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FadeInUp(
                                delay: const Duration(milliseconds: 180),
                                duration: const Duration(milliseconds: 550),
                                child: Text(
                                  'Build healthier habits with daily tracking, simple insights, and progress that feels easy to follow.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: const Color(0xFF607080),
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              FadeInUp(
                                delay: const Duration(milliseconds: 240),
                                duration: const Duration(milliseconds: 550),
                                child: const _FeatureRow(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          FadeInUp(
                            delay: const Duration(milliseconds: 320),
                            duration: const Duration(milliseconds: 550),
                            child: Column(
                              children: [
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
                                      shadowColor: colorScheme.primary
                                          .withValues(alpha: 0.28),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AboutYouScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Create account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      side: BorderSide(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreens(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _FeaturePill(
            icon: Icons.monitor_heart_rounded,
            label: 'Vitals',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _FeaturePill(
            icon: Icons.directions_walk_rounded,
            label: 'Activity',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _FeaturePill(icon: Icons.eco_rounded, label: 'Wellness'),
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E7EE)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 23),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF607080),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
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
