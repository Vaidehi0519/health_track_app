import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notifications = const [
    _AlertItem(
      icon: Icons.water_drop_rounded,
      title: 'Hydration reminder',
      message: 'You are 2 cups away from today\'s water goal.',
      time: '10 min ago',
      color: Color(0xFF1397E5),
    ),
    _AlertItem(
      icon: Icons.directions_walk_rounded,
      title: 'Step goal update',
      message: 'Nice pace. You completed 68% of your daily steps.',
      time: 'Today',
      color: Color(0xFF32C74E),
    ),
    _AlertItem(
      icon: Icons.monitor_heart_rounded,
      title: 'Weekly check-in',
      message: 'Log your mood and energy to complete this week\'s insight.',
      time: 'Yesterday',
      color: Color(0xFFFF7A1A),
    ),
  ];

  final _messages = const [
    _AlertItem(
      icon: Icons.person_rounded,
      title: 'Health Tracker',
      message: 'Your habit summary is ready to review.',
      time: '2h ago',
      color: Color(0xFF1397E5),
    ),
    _AlertItem(
      icon: Icons.group_rounded,
      title: 'Community',
      message: 'A new wellness challenge starts today.',
      time: 'This week',
      color: Color(0xFF32C74E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        centerTitle: true,
        title: const Text(
          'Alerts',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2EEF3)),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF607080),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tabs: const [
                      Tab(text: 'Notifications'),
                      Tab(text: 'Messages'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _AlertList(items: _notifications),
                    _AlertList(items: _messages),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList({required this.items});

  final List<_AlertItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2EEF3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF061A3A),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          item.time,
                          style: const TextStyle(
                            color: Color(0xFF81909D),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: const TextStyle(
                        color: Color(0xFF607080),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AlertItem {
  const _AlertItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
}
