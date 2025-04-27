import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';

void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text(message),
    ),
  );
}

/// Platform-specific user authentication helper
/// Handles different behavior between iOS, Android, and Web platforms
class AuthHelper {
  static Future<bool> updateUsername(User user, String username) async {
    try {
      // iOS and Android have different timing issues with Firebase Auth
      if (Platform.isIOS) {
        // On iOS, we need to wait a bit longer for the display name update
        await user.updateDisplayName(username);
        await Future.delayed(const Duration(milliseconds: 500));
        await user.reload();
        return true;
      } else if (Platform.isAndroid) {
        // Android sometimes needs multiple attempts
        await user.updateDisplayName(username);
        await user.reload();
        
        // Verify if the update took effect
        final updatedUser = FirebaseAuth.instance.currentUser;
        if (updatedUser?.displayName != username) {
          // Try once more if it didn't work
          await updatedUser?.updateDisplayName(username);
          await updatedUser?.reload();
        }
        return true;
      } else {
        // Web or other platforms
        await user.updateDisplayName(username);
        await user.reload();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating username: $e');
      return false;
    }
  }
}