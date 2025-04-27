import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/post_widget.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../components/comment_list_item.dart';
import './comment_thread_page.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final _commentsCollection = FirebaseFirestore.instance.collection('comments');

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Get user data from Firestore to ensure we have the correct username
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!userDoc.exists) {
        throw Exception("User document not found");
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final username = userData['username'] as String;

      final commentRef = _commentsCollection.doc();
      final comment = Comment(
        id: commentRef.id,
        userId: currentUser.uid,
        username: username, // Use username from Firestore
        content: content,
        timestamp: DateTime.now(),
        parentId: null,
        sparkles: [],
        poops: [],
      );

      await commentRef.set({
        ...comment.toMap(),
        'postId': widget.post.id,
      });

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
          postId: widget.post.id,
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
          'Post',
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
          // Original Post
          PostWidget(
            post: widget.post,
            onReact: (postId, isLike) {
              // Handle post reaction
            },
            onComment: (postId) {
              // Already in comment section
            },
            hideCommentAction: true,
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
                      hintText: 'Write a comment...',
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
                  child: const Text('Post'),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _commentsCollection
                  .where('postId', isEqualTo: widget.post.id)
                  .where('parentId', isNull: true)
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
                      'No comments yet. Be the first to comment!',
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