import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/theme/app_theme.dart';
import 'package:health_track_app/core/utils/app_feedback.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _SettingsHeader(colorScheme: colorScheme),
            const SizedBox(height: 18),
            _SettingsTile(
              icon: CupertinoIcons.moon_stars_fill,
              color: AppColors.purple,
              title: 'Dark mode',
              subtitle: 'Use a lower-glare interface at night.',
              trailing: CupertinoSwitch(
                value: appState.isDarkMode,
                activeTrackColor: colorScheme.primary,
                onChanged: (value) async {
                  await appState.setDarkMode(value);
                  if (!context.mounted) return;
                  AppFeedback.showSnackBar(
                    context,
                    value ? 'Dark mode enabled' : 'Light mode enabled',
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.notifications_active_rounded,
              color: AppColors.primary,
              title: 'Smart reminders',
              subtitle: 'Hydration, meals, sleep, and weekly check-ins.',
              trailing: CupertinoSwitch(
                value: appState.reminders.water,
                activeTrackColor: colorScheme.primary,
                onChanged: (value) async {
                  await appState.updateReminders(
                    appState.reminders.copyWith(water: value, meals: value),
                  );
                  if (!context.mounted) return;
                  AppFeedback.showSnackBar(
                    context,
                    value ? 'Reminders enabled' : 'Reminders paused',
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.health_and_safety_rounded,
              color: AppColors.secondary,
              title: 'Cloud sync',
              subtitle: _syncSubtitle(appState.lastSyncedAt),
              trailing: appState.isSyncing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.sync_rounded),
              onTap: appState.isSyncing
                  ? null
                  : () async {
                      if (!appState.canCloudSync) {
                        AppFeedback.showSnackBar(
                          context,
                          'Sign in to sync health data.',
                          icon: Icons.info_rounded,
                        );
                        return;
                      }
                      try {
                        await appState.syncNow();
                        if (!context.mounted) return;
                        AppFeedback.showSnackBar(
                          context,
                          'Health data synced',
                          icon: Icons.cloud_done_rounded,
                        );
                      } catch (error) {
                        if (!context.mounted) return;
                        AppFeedback.showSnackBar(
                          context,
                          error.toString(),
                          icon: Icons.error_outline_rounded,
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  String _syncSubtitle(DateTime? lastSyncedAt) {
    if (lastSyncedAt == null) {
      return 'Back up meals, water, workouts, and weight to Firestore.';
    }
    final time =
        '${lastSyncedAt.hour.toString().padLeft(2, '0')}:${lastSyncedAt.minute.toString().padLeft(2, '0')}';
    return 'Last synced ${lastSyncedAt.day}/${lastSyncedAt.month} at $time.';
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        children: [
          Icon(Icons.tune_rounded, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Personalize your health tracking experience.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.62),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
