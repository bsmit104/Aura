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

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F1E9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, -4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: const CreatePost(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B),
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: _showCreatePostSheet,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
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
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    return Center(child: Text('Error: ${userSnapshot.error}'));
                  }

                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final following = List<String>.from(userData?['following'] ?? []);
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null && !following.contains(userId)) {
                    following.add(userId);
                  }

                  if (following.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Color(0xFF4A5EBD),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Posts Yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Follow some users to see their posts here!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('userId', whereIn: following)
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

                      if (posts.isEmpty) {
                        return const Center(
                          child: Text(
                            'No posts from people you follow yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

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