import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentListItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onTap;
  final bool isParent;

  const CommentListItem({
    super.key,
    required this.comment,
    this.onTap,
    this.isParent = false,
  });

  Future<void> _deleteComment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment? This will also delete all replies.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final commentRef = FirebaseFirestore.instance.collection('comments').doc(comment.id);
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // Get all replies recursively
      final repliesSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('parentId', isEqualTo: comment.id)
          .get();
      
      // Delete all replies
      for (var doc in repliesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the comment itself
      batch.delete(commentRef);

      // Update post's comments array
      if (currentUser != null) {
        final commentDoc = await commentRef.get();
        if (commentDoc.exists) {
          final postId = commentDoc.data()?['postId'] as String?;
          if (postId != null) {
            final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
            batch.update(postRef, {
              'comments': FieldValue.arrayRemove([currentUser.uid])
            });
          }
        }
      }
      
      await batch.commit();

      if (context.mounted && isParent) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting comment: $e')),
        );
      }
    }
  }

  Future<void> _reactToComment(BuildContext context, bool isSparkle) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final commentRef = FirebaseFirestore.instance.collection('comments').doc(comment.id);

      // Remove any existing reaction
      if (comment.sparkles.contains(currentUserId)) {
        batch.update(commentRef, {
          'sparkles': FieldValue.arrayRemove([currentUserId])
        });
      }
      if (comment.poops.contains(currentUserId)) {
        batch.update(commentRef, {
          'poops': FieldValue.arrayRemove([currentUserId])
        });
      }

      // Add new reaction if it's different from the removed one
      if (isSparkle && !comment.sparkles.contains(currentUserId)) {
        batch.update(commentRef, {
          'sparkles': FieldValue.arrayUnion([currentUserId])
        });
      } else if (!isSparkle && !comment.poops.contains(currentUserId)) {
        batch.update(commentRef, {
          'poops': FieldValue.arrayUnion([currentUserId])
        });
      }

      await batch.commit();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reaction: $e')),
        );
      }
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Stream<int> _getReplyCountStream() {
    return FirebaseFirestore.instance
        .collection('comments')
        .where('parentId', isEqualTo: comment.id)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final hasSparkled = currentUserId != null && comment.sparkles.contains(currentUserId);
    final hasPooped = currentUserId != null && comment.poops.contains(currentUserId);
    final isOwner = currentUserId == comment.userId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          top: isParent ? 0 : 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F1E9),
          border: Border.all(
            color: Colors.black,
            width: isParent ? 4 : 3,
          ),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isParent ? const Color.fromRGBO(74, 94, 189, 0.1) : null,
                border: isParent
                    ? const Border(
                        bottom: BorderSide(color: Colors.black, width: 2),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A5EBD),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFFF6B6B),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _formatTimestamp(comment.timestamp),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  if (isOwner) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
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
                        onTap: () => _deleteComment(context),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                comment.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Row(
                children: [
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
                      onTap: () => _reactToComment(context, true),
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
                      onTap: () => _reactToComment(context, false),
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

                  const Spacer(),

                  StreamBuilder<int>(
                    stream: _getReplyCountStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF4A5EBD),
                          ),
                        );
                      }
                      final replyCount = snapshot.data ?? 0;
                      if (replyCount > 0) {
                        return Container(
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
                          child: Row(
                            children: [
                              const Icon(
                                Icons.comment_outlined,
                                size: 16,
                                color: Color(0xFF4A5EBD),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                replyCount.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
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