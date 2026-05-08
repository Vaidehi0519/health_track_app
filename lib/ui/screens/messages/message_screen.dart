import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/messages/conversation_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  final List<_ConversationPreview> _conversations = const [
    _ConversationPreview(
      name: 'Health Coach',
      subtitle: 'Online',
      message: 'Add one glass of water before dinner.',
      time: 'Now',
      unread: 2,
      color: Color(0xFF1397E5),
      icon: Icons.health_and_safety_rounded,
    ),
    _ConversationPreview(
      name: 'Nutrition Team',
      subtitle: 'Typically replies in 1h',
      message: 'Your lunch log looks balanced today.',
      time: '11:20',
      unread: 0,
      color: Color(0xFFFF7A1A),
      icon: Icons.restaurant_rounded,
    ),
    _ConversationPreview(
      name: 'Workout Buddy',
      subtitle: 'Active today',
      message: 'Evening walk at 7?',
      time: 'Yesterday',
      unread: 1,
      color: Color(0xFF32C74E),
      icon: Icons.directions_run_rounded,
    ),
    _ConversationPreview(
      name: 'Sleep Reminder',
      subtitle: 'Automated',
      message: 'Start winding down in 30 minutes.',
      time: 'Mon',
      unread: 0,
      color: Color(0xFF7357FF),
      icon: Icons.bedtime_rounded,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleConversations = _conversations.where((conversation) {
      final query = _query.toLowerCase();
      return conversation.name.toLowerCase().contains(query) ||
          conversation.message.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'New message',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New message coming soon')),
              );
            },
            icon: const Icon(Icons.edit_square),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          children: [
            _SearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 18),
            _MessageSummary(
              unreadCount: _conversations.fold<int>(
                0,
                (total, conversation) => total + conversation.unread,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Conversations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF061A3A),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            if (visibleConversations.isEmpty)
              const _EmptyMessages()
            else
              ...visibleConversations.map((conversation) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ConversationTile(conversation: conversation),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search messages',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2EEF3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2EEF3)),
        ),
      ),
    );
  }
}

class _MessageSummary extends StatelessWidget {
  const _MessageSummary({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, const Color(0xFF32C74E)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health inbox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unreadCount unread messages',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w700,
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

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final _ConversationPreview conversation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationScreen(
                name: conversation.name,
                subtitle: conversation.subtitle,
                avatarColor: conversation.color,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2EEF3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: conversation.color.withValues(alpha: 0.12),
                child: Icon(conversation.icon, color: conversation.color),
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
                            conversation.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF061A3A),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          conversation.time,
                          style: const TextStyle(
                            color: Color(0xFF81909D),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      conversation.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF607080),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (conversation.unread > 0) ...[
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${conversation.unread}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EEF3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.mark_chat_unread_outlined, size: 40),
          SizedBox(height: 10),
          Text(
            'No messages found',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ConversationPreview {
  const _ConversationPreview({
    required this.name,
    required this.subtitle,
    required this.message,
    required this.time,
    required this.unread,
    required this.color,
    required this.icon,
  });

  final String name;
  final String subtitle;
  final String message;
  final String time;
  final int unread;
  final Color color;
  final IconData icon;
}
