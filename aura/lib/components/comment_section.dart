import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import 'comment_widget.dart';

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({
    super.key,
    required this.postId,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyingToCommentId;
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

    final comment = Comment(
      id: '',
      userId: currentUser.uid,
      username: currentUser.displayName ?? 'Anonymous',
      content: content,
      timestamp: DateTime.now(),
      parentId: _replyingToCommentId,
      likes: [],
    );

    await _commentsCollection.add(comment.toMap());

    _commentController.clear();
    setState(() {
      _replyingToCommentId = null;
    });
  }

  Future<void> _likeComment(String commentId, List<String> likes) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final updatedLikes = List<String>.from(likes);
    if (updatedLikes.contains(currentUserId)) {
      updatedLikes.remove(currentUserId);
    } else {
      updatedLikes.add(currentUserId);
    }

    await _commentsCollection.doc(commentId).update({
      'likes': updatedLikes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Comment Input
        Container(
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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (_replyingToCommentId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Text(
                        'Replying to:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _replyingToCommentId = null;
                          });
                        },
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Comments List
        StreamBuilder<QuerySnapshot>(
          stream: _commentsCollection
              .where('postId', isEqualTo: widget.postId)
              .where('parentId', isNull: true)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data!.docs
                .map((doc) => Comment.fromMap(doc.data() as Map<String, dynamic>))
                .toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Column(
                  children: [
                    CommentWidget(
                      comment: comment,
                      onReply: (commentId) {
                        setState(() {
                          _replyingToCommentId = commentId;
                        });
                      },
                      onLike: (commentId) {
                        _likeComment(commentId, comment.likes);
                      },
                    ),
                    // Replies
                    StreamBuilder<QuerySnapshot>(
                      stream: _commentsCollection
                          .where('postId', isEqualTo: widget.postId)
                          .where('parentId', isEqualTo: comment.id)
                          .orderBy('timestamp', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final replies = snapshot.data!.docs
                            .map((doc) => Comment.fromMap(doc.data() as Map<String, dynamic>))
                            .toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: replies.length,
                          itemBuilder: (context, index) {
                            final reply = replies[index];
                            return CommentWidget(
                              comment: reply,
                              isReply: true,
                              onReply: (commentId) {
                                setState(() {
                                  _replyingToCommentId = commentId;
                                });
                              },
                              onLike: (commentId) {
                                _likeComment(commentId, reply.likes);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
} 