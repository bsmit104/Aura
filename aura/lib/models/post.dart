import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';

class Post {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final List<String> sparkles; // Positive reactions
  final List<String> poops;    // Negative reactions
  final List<String> comments;
  final String? gifUrl;
  final int? colorValue; // Store color as an integer value

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
    required this.sparkles,
    required this.poops,
    required this.comments,
    this.gifUrl,
    this.colorValue,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] as String,
      username: data['username'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      sparkles: List<String>.from(data['sparkles'] ?? []),
      poops: List<String>.from(data['poops'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
      gifUrl: data['gifUrl'] as String?,
      colorValue: data['colorValue'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'timestamp': timestamp,
      'sparkles': sparkles,
      'poops': poops,
      'comments': comments,
      'gifUrl': gifUrl,
      'colorValue': colorValue,
    };
  }

  int get aura => sparkles.length - poops.length;

  Color? get color => colorValue != null ? Color(colorValue!) : null;
} 