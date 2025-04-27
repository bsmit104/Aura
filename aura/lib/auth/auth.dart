import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aura/auth/login_or_register.dart';
import 'package:aura/services/user_service.dart';
import '../pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Ensure user document exists in Firestore
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                await UserService.ensureUserDocument();
              } catch (error) {
                // Handle error silently
              }
            });
            return const HomePage();
          }
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}