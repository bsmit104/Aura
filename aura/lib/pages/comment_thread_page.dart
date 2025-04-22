import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import '../components/comment_widget.dart';
import '../models/comment.dart';
import '../components/comment_list_item.dart';

class CommentThreadPage extends StatefulWidget {
  final String postId;
  final Comment parentComment;

  const CommentThreadPage({
    super.key,
    required this.postId,
    required this.parentComment,
  });

  @override
  State<CommentThreadPage> createState() => _CommentThreadPageState();
}

class _CommentThreadPageState extends State<CommentThreadPage> {
  final TextEditingController _commentController = TextEditingController();
  final _commentsCollection = FirebaseFirestore.instance.collection('comments');

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final commentRef = _commentsCollection.doc();
      final comment = Comment(
        id: commentRef.id,
        userId: currentUser.uid,
        username: currentUser.displayName ?? 'Anonymous',
        content: content,
        timestamp: DateTime.now(),
        parentId: widget.parentComment.id,
        sparkles: [],
        poops: [],
      );

      // Add the comment
      batch.set(commentRef, {
        ...comment.toMap(),
        'postId': widget.postId,
      });

      // Update post's comments array
      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      batch.update(postRef, {
        'comments': FieldValue.arrayUnion([currentUser.uid])
      });

      await batch.commit();
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToCommentThread(Comment comment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentThreadPage(
          postId: widget.postId,
          parentComment: comment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E9),
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4A5EBD),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Parent Comment
          CommentListItem(
            comment: widget.parentComment,
            isParent: true,
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(12),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a reply...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5EBD),
                    foregroundColor: const Color(0xFFFF6B6B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  child: const Text('Reply'),
                ),
              ],
            ),
          ),

          // Replies List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _commentsCollection
                  .where('postId', isEqualTo: widget.postId)
                  .where('parentId', isEqualTo: widget.parentComment.id)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data?.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Comment.fromMap({
                    ...data,
                    'id': doc.id,
                  });
                }).toList() ?? [];

                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No replies yet. Be the first to reply!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return CommentListItem(
                      comment: comment,
                      onTap: () => _navigateToCommentThread(comment),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 