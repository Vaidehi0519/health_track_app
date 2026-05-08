import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/home/widgets/comment_card.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key, required this.post});

  final Map<String, dynamic> post;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [
    {
      'username': 'Health Tracker',
      'text': 'Great consistency. Keep this streak going.',
      'time': '15 min ago',
    },
    {
      'username': 'Demo User',
      'text': 'Nice update. Small wins count.',
      'time': '1h ago',
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(0, {
        'username': 'Vaidehi',
        'text': text,
        'time': 'Just now',
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.post['description'] as String? ?? '';
    final username = widget.post['username'] as String? ?? 'Health Tracker';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        centerTitle: true,
        title: const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2EEF3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Color(0xFF061A3A),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF25364A),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                itemCount: _comments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return CommentCard(comment: _comments[index]);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                12 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add a comment',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9E7EE),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9E7EE),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    tooltip: 'Send comment',
                    onPressed: _addComment,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
