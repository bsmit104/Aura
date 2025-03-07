import 'package:aura/auth/auth.dart';
import 'package:aura/auth/login_or_register.dart';
import 'package:aura/firebase_options.dart';
import 'package:aura/pages/home_page.dart';
import 'package:aura/pages/profile_page.dart';
import 'package:aura/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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