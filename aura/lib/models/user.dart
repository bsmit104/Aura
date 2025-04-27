import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? bio;
  final String? profileImageUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final List<String> followers;
  final List<String> following;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.bio,
    this.profileImageUrl,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.followers = const [],
    this.following = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] as String,
      email: data['email'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      bio: data['bio'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      postCount: data['postCount'] as int? ?? 0,
      followerCount: data['followerCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'createdAt': createdAt,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'postCount': postCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'followers': followers,
      'following': following,
    };
  }
} 