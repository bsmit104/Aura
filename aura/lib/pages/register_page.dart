import 'package:aura/components/my_textfield.dart';
import 'package:aura/components/my_button.dart';
import 'package:aura/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  void register() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
      ),
    );

    if (passwordController.text != confirmPwController.text) {
      if (mounted) {
        Navigator.pop(context);
        displayMessageToUser("Passwords don't match", context);
      }
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await userCredential.user?.updateDisplayName(usernameController.text);
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E9), // Eggshell background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A5EBD), // Deep blue
                    border: Border.all(color: Colors.black, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 80,
                    color: Color(0xFFFF6B6B), // Coral
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "A U R A",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8A4AF0), // Muted purple
                    letterSpacing: 2,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                MyTextfield(
                  hintText: "Username",
                  obscureText: false,
                  controller: usernameController,
                ),
                const SizedBox(height: 15),
                MyTextfield(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(height: 15),
                MyTextfield(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 15),
                MyTextfield(
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPwController,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: const Color(0xFF4ECDC4), // Punchy green
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                MyButton(text: "Register", onTap: register),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "  Login Here",
                        style: TextStyle(
                          color: const Color(0xFFFF6B6B), // Coral
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:aura/components/my_textfield.dart';
// import 'package:aura/components/my_button.dart';
// import 'package:aura/helper/helper_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class RegisterPage extends StatefulWidget {
//   final void Function()? onTap;

//   const RegisterPage({super.key, required this.onTap});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPwController = TextEditingController();

//   void register() async {
//     showDialog(
//       context: context,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );

//     if (passwordController.text != confirmPwController.text) {
//       if (mounted) {
//         Navigator.pop(context);
//         displayMessageToUser("Passwords don't match", context);
//       }
//       return;
//     }

//     try {
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );

//       // Update the user's display name with the username
//       await userCredential.user?.updateDisplayName(usernameController.text);

//       if (mounted) {
//         Navigator.pop(context);
//       }
//     } on FirebaseAuthException catch (e) {
//       if (mounted) {
//         Navigator.pop(context);
//         displayMessageToUser(e.code, context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.person,
//                 size: 80,
//                 color: Theme.of(context).colorScheme.inversePrimary,
//               ),
//               const SizedBox(height: 25),
//               Text("A U R A", style: TextStyle(fontSize: 20)),
//               const SizedBox(height: 50),
//               MyTextfield(
//                 hintText: "Username",
//                 obscureText: false,
//                 controller: usernameController,
//               ),
//               const SizedBox(height: 10),
//               MyTextfield(
//                 hintText: "Email",
//                 obscureText: false,
//                 controller: emailController,
//               ),
//               const SizedBox(height: 10),
//               MyTextfield(
//                 hintText: "Password",
//                 obscureText: true,
//                 controller: passwordController,
//               ),
//               const SizedBox(height: 10),
//               MyTextfield(
//                 hintText: "Confirm Password",
//                 obscureText: true,
//                 controller: confirmPwController,
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Forgot Password?",
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.inversePrimary,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 25),
//               MyButton(text: "Register", onTap: register),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Already have an account?",
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.inversePrimary,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: widget.onTap,
//                     child: const Text(
//                       "  login Here",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }














// import 'package:aura/components/my_textfield.dart';
// import 'package:aura/components/my_button.dart';
// import 'package:aura/helper/helper_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class RegisterPage extends StatefulWidget {
//   final void Function()? onTap;

//   const RegisterPage({super.key, required this.onTap});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPwController = TextEditingController();

//   void register() async {
//     showDialog(
//       context: context,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );

//     if (passwordController.text != confirmPwController.text) {
//       if (mounted) {
//         Navigator.pop(context);
//         displayMessageToUser("Passwords don't match", context);
//       }
//       return;
//     }

//     try {
//       UserCredential? userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );

//       if (mounted) {
//         Navigator.pop(context);
//       }
//     } on FirebaseAuthException catch (e) {
//       if (mounted) {
//         Navigator.pop(context);
//         displayMessageToUser(e.code, context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.person,
//                 size: 80,
//                 color: Theme.of(context).colorScheme.inversePrimary,
//               ),
//               const SizedBox(height: 25),
//               Text("A U R A", style: TextStyle(fontSize: 20)),
//               const SizedBox(height: 50),
//               MyTextfield(
//                 hintText: "Username",
//                 obscureText: false,
//                 controller: usernameController,
//               ),
//               const SizedBox(height: 10),
//               MyTextfield(
//                 hintText: "Email",
//                 obscureText: false,
//                 controller: emailController,
//               ),
//               const SizedBox(height: 10),
//               MyTextfield(
//                 hintText: "Password",
//                 obscureText: true,
//                 controller: passwordController,
//               ),
//               const SizedBox(height: 10),
//               MyTextfield(
//                 hintText: "Confirm Password",
//                 obscureText: true,
//                 controller: confirmPwController,
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Forgot Password?",
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.inversePrimary,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 25),
//               MyButton(text: "Register", onTap: register),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Already have an account?",
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.inversePrimary,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: widget.onTap,
//                     child: const Text(
//                       "  login Here",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












// import 'package:aura/components/my_textfield.dart';
// import 'package:aura/components/my_button.dart';
// import 'package:aura/helper/helper_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class RegisterPage extends StatefulWidget {
//   final void Function()? onTap;

//   const RegisterPage({super.key, required this.onTap});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController usernameController = TextEditingController();

//   final TextEditingController emailController = TextEditingController();

//   final TextEditingController passwordController = TextEditingController();

//   final TextEditingController confirmPwController = TextEditingController();

//   void register() async {
//     showDialog(
//       context: context,
//       builder: (context) => Center(child: CircularProgressIndicator()),
//     );

//     if (passwordController.text != confirmPwController.text) {
//       Navigator.pop(context);

//       displayMessageToUser("Passwords don't match", context);
//     } else {
//       try {
//         UserCredential? userCredential = await FirebaseAuth.instance
//             .createUserWithEmailAndPassword(
//               email: emailController.text,
//               password: passwordController.text,
//             );

//         Navigator.pop(context);
//       } on FirebaseAuthException catch (e) {
//         Navigator.pop(context);
//         displayMessageToUser(e.code, context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.person,
//                 size: 80,
//                 color: Theme.of(context).colorScheme.inversePrimary,
//               ),

//               const SizedBox(height: 25),

//               Text("A U R A", style: TextStyle(fontSize: 20)),

//               const SizedBox(height: 50),

//               MyTextfield(
//                 hintText: "Username",
//                 obscureText: false,
//                 controller: usernameController,
//               ),

//               const SizedBox(height: 10),

//               MyTextfield(
//                 hintText: "Email",
//                 obscureText: false,
//                 controller: emailController,
//               ),

//               const SizedBox(height: 10),

//               MyTextfield(
//                 hintText: "Password",
//                 obscureText: true,
//                 controller: passwordController,
//               ),

//               const SizedBox(height: 10),

//               MyTextfield(
//                 hintText: "Confirm Password",
//                 obscureText: true,
//                 controller: confirmPwController,
//               ),

//               const SizedBox(height: 10),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Forgot Password?",
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.inversePrimary,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 25),

//               MyButton(text: "Register", onTap: register),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Already have an account?",
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.inversePrimary,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: widget.onTap,
//                     child: const Text(
//                       "  login Here",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
