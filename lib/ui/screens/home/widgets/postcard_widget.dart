import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.snap, this.onComment});

  final Map<String, dynamic> snap;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    final username = _readString(['username', 'name', 'displayName']);
    final description = _readString(['description', 'caption', 'post']);
    final metric = _readString(['metric', 'mood', 'category']);
    final publishedAt = _readString(['datePublished', 'time']);
    final likesCount = _intValue(snap['likes']);
    final commentsCount = _intValue(snap['commentsCount']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EEF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1397E5).withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1397E5), Color(0xFF32C74E)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.isEmpty ? 'Health Tracker User' : username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF061A3A),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        publishedAt.isEmpty ? 'Just now' : publishedAt,
                        style: const TextStyle(
                          color: Color(0xFF81909D),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (metric.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      metric,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description.isEmpty ? 'Shared a new health update.' : description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF25364A),
                height: 1.42,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _PostAction(
                  icon: Icons.favorite_border_rounded,
                  label: '$likesCount',
                ),
                const SizedBox(width: 12),
                _PostAction(
                  icon: Icons.mode_comment_outlined,
                  label: '$commentsCount',
                  onTap: onComment,
                ),
                const Spacer(),
                const _PostAction(icon: Icons.share_rounded, label: 'Share'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _readString(List<String> keys) {
    for (final key in keys) {
      final value = snap[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return 0;
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5FAFC),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF607080)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF607080),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
