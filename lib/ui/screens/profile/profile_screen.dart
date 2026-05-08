import 'package:flutter/material.dart';
import 'package:health_track_app/core/session_store.dart';
import 'package:health_track_app/ui/screens/auth/welcome_screen.dart';
import 'package:health_track_app/ui/screens/profile/edit_profilescreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Vaidehi';
  String _bio = 'Building healthier routines one small win at a time.';
  String _goal = 'Weekly wellness goal';
  double _goalProgress = 0.68;
  int _waterCups = 6;
  int _workoutMinutes = 42;
  int _caloriesBurned = 420;

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<EditProfileResult>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialName: _name,
          initialBio: _bio,
          initialGoal: _goal,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _name = result.name;
      _bio = result.bio;
      _goal = result.goal;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  void _addWaterCup() {
    setState(() {
      _waterCups = (_waterCups + 1).clamp(0, 12);
      _goalProgress = (_goalProgress + 0.04).clamp(0, 1);
    });
  }

  void _logWorkout() {
    setState(() {
      _workoutMinutes += 10;
      _caloriesBurned += 70;
      _goalProgress = (_goalProgress + 0.06).clamp(0, 1);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout added')));
  }

  void _resetProgress() {
    setState(() {
      _goalProgress = 0;
      _waterCups = 0;
      _workoutMinutes = 0;
      _caloriesBurned = 0;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Today\'s progress reset')));
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon')));
  }

  Future<void> _logout() async {
    await SessionStore.setLoggedIn(false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          PopupMenuButton<_ProfileMenuAction>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (action) {
              switch (action) {
                case _ProfileMenuAction.edit:
                  _openEditProfile();
                case _ProfileMenuAction.reset:
                  _resetProgress();
                case _ProfileMenuAction.logout:
                  _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ProfileMenuAction.edit,
                child: ListTile(
                  leading: Icon(Icons.edit_rounded),
                  title: Text('Edit profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _ProfileMenuAction.reset,
                child: ListTile(
                  leading: Icon(Icons.restart_alt_rounded),
                  title: Text('Reset progress'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _ProfileMenuAction.logout,
                child: ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _ProfileHeader(
              name: _name,
              bio: _bio,
              goal: _goal,
              progress: _goalProgress,
              onEdit: _openEditProfile,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.local_drink_rounded,
                    label: 'Water',
                    value: '$_waterCups cups',
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.directions_run_rounded,
                    label: 'Workout',
                    value: '$_workoutMinutes min',
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Calories burned',
              value: '$_caloriesBurned kcal',
              color: const Color(0xFFFF7A1A),
              wide: true,
            ),
            const SizedBox(height: 18),
            _ActionPanel(
              onAddWater: _addWaterCup,
              onLogWorkout: _logWorkout,
              onViewHistory: () => _showComingSoon('Health history'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ProfileMenuAction { edit, reset, logout }

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.bio,
    required this.goal,
    required this.progress,
    required this.onEdit,
  });

  final String name;
  final String bio;
  final String goal;
  final double progress;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressPercent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2EEF3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF607080),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Edit profile',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  goal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF25364A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$progressPercent%',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFEAF2F6),
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(wide ? 18 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EEF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF81909D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF061A3A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.onAddWater,
    required this.onLogWorkout,
    required this.onViewHistory,
  });

  final VoidCallback onAddWater;
  final VoidCallback onLogWorkout;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF061A3A),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAddWater,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add water cup'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onLogWorkout,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.fitness_center_rounded),
            label: const Text('Log 10 min workout'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onViewHistory,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
            ),
            icon: const Icon(Icons.history_rounded),
            label: const Text('View history'),
          ),
        ],
      ),
    );
  }
}
