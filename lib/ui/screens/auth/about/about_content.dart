import 'package:flutter/material.dart';

class AboutContent {
  const AboutContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}

const aboutContents = [
  AboutContent(
    title: 'Tell us about you',
    description: 'Choose the profile that helps personalize your health plan.',
    icon: Icons.wc_rounded,
    accentColor: Color(0xFF1397E5),
  ),
  AboutContent(
    title: 'What is your age?',
    description: 'Age helps tune wellness recommendations and daily goals.',
    icon: Icons.cake_rounded,
    accentColor: Color(0xFF32C74E),
  ),
  AboutContent(
    title: 'Add your weight',
    description: 'We use this to make progress tracking feel more accurate.',
    icon: Icons.monitor_weight_rounded,
    accentColor: Color(0xFF0B6BB7),
  ),
];
