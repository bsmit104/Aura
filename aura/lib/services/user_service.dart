import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura/models/user.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static final CollectionReference _usersCollection = 
      _firestore.collection('users');
  
  // Get currently logged in user
  static User? get currentUser => _auth.currentUser;
  
  // Get user document reference
  static DocumentReference getUserRef(String userId) {
    return _usersCollection.doc(userId);
  }
  
  // Create a new user document in Firestore
  static Future<void> createUserDocument({
    required String userId,
    required String username,
    required String email,
  }) async {
    try {
      await _usersCollection.doc(userId).set({
        'username': username,
        'email': email,
        'createdAt': Timestamp.now(),
        'bio': null,
        'profileImageUrl': null,
        'postCount': 0,
        'followerCount': 0,
        'followingCount': 0,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Get user data from Firestore
  static Future<UserModel?> getUserData(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();
      
      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  // Ensure user document exists (create if not)
  static Future<UserModel> ensureUserDocument() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is logged in");
    }
    
    try {
      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Create new user document using displayName or email-based fallback
        final username = currentUser.displayName ?? currentUser.email!.split('@')[0];
        final newUser = UserModel(
          id: currentUser.uid,
          username: username,
          email: currentUser.email ?? '',
          createdAt: DateTime.now(),
        );
        
        await _usersCollection.doc(currentUser.uid).set(newUser.toMap());
        
        return newUser;
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user's post count
  static Future<void> incrementPostCount(String userId) async {
    try {
      final userRef = _usersCollection.doc(userId);
      final userDoc = await userRef.get();
      
      if (userDoc.exists) {
        await userRef.update({
          'postCount': FieldValue.increment(1)
        });
      } else {
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid == userId) {
          await createUserDocument(
            userId: userId,
            username: currentUser.displayName ?? currentUser.email!.split('@')[0],
            email: currentUser.email ?? '',
          );
          
          await userRef.update({
            'postCount': 1
          });
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Follow a user
  static Future<void> followUser(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("No user is logged in");

    final batch = _firestore.batch();
    
    // Add to current user's following list
    batch.update(
      _usersCollection.doc(currentUser.uid),
      {
        'following': FieldValue.arrayUnion([targetUserId]),
        'followingCount': FieldValue.increment(1),
      },
    );
    
    // Add to target user's followers list
    batch.update(
      _usersCollection.doc(targetUserId),
      {
        'followers': FieldValue.arrayUnion([currentUser.uid]),
        'followerCount': FieldValue.increment(1),
      },
    );
    
    await batch.commit();
  }

  // Unfollow a user
  static Future<void> unfollowUser(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("No user is logged in");

    final batch = _firestore.batch();
    
    // Remove from current user's following list
    batch.update(
      _usersCollection.doc(currentUser.uid),
      {
        'following': FieldValue.arrayRemove([targetUserId]),
        'followingCount': FieldValue.increment(-1),
      },
    );
    
    // Remove from target user's followers list
    batch.update(
      _usersCollection.doc(targetUserId),
      {
        'followers': FieldValue.arrayRemove([currentUser.uid]),
        'followerCount': FieldValue.increment(-1),
      },
    );
    
    await batch.commit();
  }

  // Check if current user is following a target user
  static Future<bool> isFollowing(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final userDoc = await _usersCollection.doc(currentUser.uid).get();
    if (!userDoc.exists) return false;

    final userData = userDoc.data() as Map<String, dynamic>;
    final following = List<String>.from(userData['following'] ?? []);
    return following.contains(targetUserId);
  }

  // Get list of followers for a user
  static Stream<List<UserModel>> getFollowers(String userId) {
    return _usersCollection.doc(userId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return [];
      
      final userData = doc.data() as Map<String, dynamic>;
      final followers = List<String>.from(userData['followers'] ?? []);
      
      final followerDocs = await Future.wait(
        followers.map((id) => _usersCollection.doc(id).get())
      );
      
      return followerDocs
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get list of users being followed
  static Stream<List<UserModel>> getFollowing(String userId) {
    return _usersCollection.doc(userId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return [];
      
      final userData = doc.data() as Map<String, dynamic>;
      final following = List<String>.from(userData['following'] ?? []);
      
      final followingDocs = await Future.wait(
        following.map((id) => _usersCollection.doc(id).get())
      );
      
      return followingDocs
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    });
  }
}
