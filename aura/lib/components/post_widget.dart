import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../pages/post_detail_page.dart';
import 'gif_player.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final Function(String, bool) onReact;
  final Function(String) onComment;
  final bool hideCommentAction;

  const PostWidget({
    super.key,
    required this.post,
    required this.onReact,
    required this.onComment,
    this.hideCommentAction = false,
  });

  Future<void> _deletePost(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This will also delete all comments.'),
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
      final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);
      
      // Get and delete all comments
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: post.id)
          .get();
      
      for (var doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the post
      batch.delete(postRef);
      
      await batch.commit();

      if (context.mounted) {
        // If we're in the detail view (hideCommentAction is false), navigate back
        // Otherwise, just let the StreamBuilder handle the UI update
        if (!hideCommentAction && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: $e')),
        );
      }
    }
  }

  Stream<int> _getCommentCountStream() {
    return FirebaseFirestore.instance
        .collection('comments')
        .where('postId', isEqualTo: post.id)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final hasSparkled = currentUserId != null && post.sparkles.contains(currentUserId);
    final hasPooped = currentUserId != null && post.poops.contains(currentUserId);
    // final isCommented = currentUserId != null && post.comments.contains(currentUserId);
    final isOwner = currentUserId == post.userId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: post.color ?? Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: post.aura > 0 
                        ? const Color(0xFF4ECDC4)
                        : post.aura < 0 
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF4A5EBD),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'Aura: ${post.aura}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isOwner)
                  IconButton(
                    onPressed: () => _deletePost(context),
                    icon: Container(
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
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Post Content
          Container(
            color: Colors.white.withAlpha(160), //adjust for lighter color
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                if (post.gifUrl != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: GifPlayer(
                        url: post.gifUrl!,
                        fit: BoxFit.cover,
                        maxHeight: 250,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Post Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 4),
              ),
            ),
            child: Row(
              children: [
                _buildReactionButton(
                  icon: hasSparkled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                  count: post.sparkles.length,
                  isActive: hasSparkled,
                  onTap: () => onReact(post.id, true),
                  activeColor: const Color(0xFF4ECDC4),
                ),
                const SizedBox(width: 12),
                _buildReactionButton(
                  icon: hasPooped ? Icons.sentiment_very_dissatisfied : Icons.sentiment_very_dissatisfied_outlined,
                  count: post.poops.length,
                  isActive: hasPooped,
                  onTap: () => onReact(post.id, false),
                  activeColor: const Color(0xFFFF6B6B),
                ),
                const SizedBox(width: 12),
                if (!hideCommentAction)
                  StreamBuilder<int>(
                    stream: _getCommentCountStream(),
                    builder: (context, snapshot) {
                      final commentCount = snapshot.data ?? 0;
                      return _buildReactionButton(
                        icon: Icons.comment_outlined,
                        count: commentCount,
                        isActive: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(post: post),
                            ),
                          );
                        },
                        activeColor: const Color(0xFF4A5EBD),
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
    bool showCount = true,
    Color activeColor = const Color(0xFF4A5EBD),
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
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
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black,
              size: 20,
            ),
            if (showCount) ...[
              const SizedBox(width: 4),
              if (isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4A5EBD),
                  ),
                )
              else
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.black,
                  ),
                ),
            ],
          ],
        ),
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