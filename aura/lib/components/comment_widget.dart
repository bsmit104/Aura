import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function(String) onReply;
  final Function(String, bool) onReact;
  final bool isReply;
  final int depth;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onReact,
    this.isReply = false,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final hasSparkled = currentUserId != null && comment.sparkles.contains(currentUserId);
    final hasPooped = currentUserId != null && comment.poops.contains(currentUserId);

    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 32.0 : 0.0,
        top: 8.0,
        bottom: 8.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1E9),
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A5EBD),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFFF6B6B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Aura Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: comment.aura > 0 
                        ? const Color(0xFF4ECDC4)
                        : comment.aura < 0 
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF4A5EBD),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'Aura: ${comment.aura}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Comment Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Comment Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Sparkle button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasSparkled ? const Color(0xFF4ECDC4) : Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => onReact(comment.id, true),
                    child: Row(
                      children: [
                        Icon(
                          hasSparkled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                          color: hasSparkled ? Colors.white : Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.sparkles.length.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasSparkled ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Poop button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasPooped ? const Color(0xFFFF6B6B) : Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => onReact(comment.id, false),
                    child: Row(
                      children: [
                        Icon(
                          hasPooped ? Icons.sentiment_very_dissatisfied : Icons.sentiment_very_dissatisfied_outlined,
                          color: hasPooped ? Colors.white : Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.poops.length.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasPooped ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Reply button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => onReply(comment.id),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.reply,
                          color: Color(0xFF4A5EBD),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 