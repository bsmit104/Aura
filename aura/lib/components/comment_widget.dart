import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function(String) onReply;
  final Function(String) onLike;
  final bool isReply;
  final int depth;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onLike,
    this.isReply = false,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = currentUserId != null && comment.likes.contains(currentUserId);

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
                IconButton(
                  onPressed: () => onLike(comment.id),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? const Color(0xFFFF6B6B) : Colors.black,
                    size: 20,
                  ),
                ),
                Text(
                  comment.likes.length.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => onReply(comment.id),
                  icon: const Icon(
                    Icons.reply,
                    color: Colors.black,
                    size: 20,
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