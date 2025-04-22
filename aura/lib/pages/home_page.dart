import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aura/components/my_drawer.dart';
import 'package:aura/components/create_post.dart';
import 'package:aura/components/post_widget.dart';
import 'package:aura/models/post.dart';
import 'package:aura/helper/helper_functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _reactToPost(String postId, bool isSparkle) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      final post = Post.fromFirestore(postDoc);

      // Remove any existing reaction
      if (post.sparkles.contains(currentUserId)) {
        await postRef.update({
          'sparkles': FieldValue.arrayRemove([currentUserId])
        });
      }
      if (post.poops.contains(currentUserId)) {
        await postRef.update({
          'poops': FieldValue.arrayRemove([currentUserId])
        });
      }

      // Add new reaction
      if (isSparkle) {
        await postRef.update({
          'sparkles': FieldValue.arrayUnion([currentUserId])
        });
      } else {
        await postRef.update({
          'poops': FieldValue.arrayUnion([currentUserId])
        });
      }
    } catch (e) {
      if (mounted) {
        displayMessageToUser(e.toString(), context);
      }
    }
  }

  void _showCommentDialog(String postId) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comments'),
        content: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (context, index) {
                  final comment = snapshot.data!.docs[index];
                  return ListTile(
                    title: Text(comment['username']),
                    subtitle: Text(comment['content']),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E9),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Stack(
              children: [
                // Black outline effect
                Text(
                  'A U R A',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 8
                      ..color = Colors.black,
                  ),
                ),
                // Main text
                Text(
                  'A U R A',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4A5EBD),
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (mounted) {
            setState(() {});
          }
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const CreatePost(),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final posts = snapshot.data!.docs
                      .map((doc) => Post.fromFirestore(doc))
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostWidget(
                        post: post,
                        onReact: _reactToPost,
                        onComment: _showCommentDialog,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}