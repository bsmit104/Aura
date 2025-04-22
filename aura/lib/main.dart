import 'package:aura/auth/auth.dart';
import 'package:aura/auth/login_or_register.dart';
import 'package:aura/firebase_options.dart';
import 'package:aura/pages/home_page.dart';
import 'package:aura/pages/profile_page.dart';
import 'package:aura/pages/comment_thread_page.dart';
import 'package:aura/theme/theme.dart';
import 'package:aura/models/comment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configure image cache
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 200; // 200 MB
  PaintingBinding.instance.imageCache.maximumSize = 1000; // number of images
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: neoBrutalistTheme,
      routes: {
        '/login_register_page':(context) => const LoginOrRegister(),
        '/home_page':(context) => const HomePage(),
        '/profile_page':(context) => const ProfilePage(),
        '/comment_thread': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CommentThreadPage(
            postId: args['postId'] as String,
            parentComment: args['parentComment'] as Comment,
          );
        },
      }
    );
  }
}


// import 'package:aura/auth/auth.dart';
// import 'package:aura/firebase_options.dart';
// import 'package:aura/theme/dark_mode.dart';
// import 'package:aura/theme/light_mode.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// // import 'pages/login_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const AuthPage(),
//       theme: lightMode,
//       darkTheme: darkMode,
//     );
//   }
// }