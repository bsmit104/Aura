import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final String? parentId;
  final List<String> sparkles;
  final List<String> poops;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
    this.parentId,
    required this.sparkles,
    required this.poops,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      parentId: map['parentId'] as String?,
      sparkles: List<String>.from(map['sparkles'] ?? []),
      poops: List<String>.from(map['poops'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'content': content,
      'timestamp': timestamp,
      'parentId': parentId,
      'sparkles': sparkles,
      'poops': poops,
    };
  }

  int get aura => sparkles.length - poops.length;
} 