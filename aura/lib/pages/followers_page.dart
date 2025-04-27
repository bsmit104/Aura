import 'package:flutter/material.dart';
import 'package:aura/models/user.dart';
import 'package:aura/services/user_service.dart';

class FollowersPage extends StatefulWidget {
  final String userId;
  final bool isFollowers;

  const FollowersPage({
    super.key,
    required this.userId,
    required this.isFollowers,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E9),
      appBar: AppBar(
        title: Text(
          widget.isFollowers ? 'Followers' : 'Following',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4A5EBD),
        elevation: 0,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: widget.isFollowers
            ? UserService.getFollowers(widget.userId)
            : UserService.getFollowing(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                widget.isFollowers
                    ? 'No followers yet'
                    : 'Not following anyone yet',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserTile(user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
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
            color: Color(0xFFFF6B6B),
            size: 24,
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Posts: ${user.postCount}',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        trailing: FutureBuilder<bool>(
          future: UserService.isFollowing(user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            }

            final isFollowing = snapshot.data ?? false;

            return ElevatedButton(
              onPressed: () async {
                try {
                  if (isFollowing) {
                    await UserService.unfollowUser(user.id);
                  } else {
                    await UserService.followUser(user.id);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              child: Text(
                isFollowing ? 'Unfollow' : 'Follow',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 