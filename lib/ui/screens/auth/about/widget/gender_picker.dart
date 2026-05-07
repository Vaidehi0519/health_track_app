import 'package:flutter/material.dart';

enum Sex { female, male }

class GenderPicker extends StatelessWidget {
  const GenderPicker({
    super.key,
    required this.selectedSex,
    required this.onChanged,
  });

  final Sex selectedSex;
  final ValueChanged<Sex> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderCard(
            label: 'Female',
            icon: Icons.female_rounded,
            selected: selectedSex == Sex.female,
            onTap: () => onChanged(Sex.female),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _GenderCard(
            label: 'Male',
            icon: Icons.male_rounded,
            selected: selectedSex == Sex.male,
            onTap: () => onChanged(Sex.male),
          ),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.primary : const Color(0xFF607080);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF7FF) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? colorScheme.primary : const Color(0xFFD9E7EE),
          width: selected ? 1.7 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 46),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
