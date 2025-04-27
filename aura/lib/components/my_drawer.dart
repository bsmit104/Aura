import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aura/pages/search_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // Logout function
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8F1E9), // Eggshell background
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
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
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B), // Coral
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Navigation Items
          // Home Item
          _buildDrawerItem(
            context: context,
            icon: Icons.home,
            title: "Home",
            color: const Color(0xFF8A4AF0), // Muted purple
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Search Item
          _buildDrawerItem(
            context: context,
            icon: Icons.search,
            title: "Search Users",
            color: const Color(0xFF4ECDC4), // Punchy green
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
          ),

          // Profile Item
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: "Profile",
            color: const Color(0xFF4ECDC4), // Punchy green
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile_page');
            },
          ),

          // Logout Item
          _buildDrawerItem(
            context: context,
            icon: Icons.logout, // Changed to logout icon
            title: "Logout",
            color: const Color(0xFFFF6B6B), // Coral
            onTap: () {
              Navigator.pop(context);
              logout();
            },
          ),

          // Spacer to keep content at the top
          const Spacer(),
        ],
      ),
    );
  }

  // Helper method to build neobrutalist drawer items
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: 30,
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8F1E9), // Eggshell text
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//////////////////////basic////////////////////////
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class MyDrawer extends StatelessWidget {
//   const MyDrawer({super.key});

//     void logout() {
//     FirebaseAuth.instance.signOut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.amber,
//       child: Column(
//         children: [
//           DrawerHeader(
//             child: Icon(
//               Icons.favorite,
//               color: Colors.black,
//             ),
//           ),

//           const SizedBox(height: 25),

//           Padding(
//             padding: const EdgeInsets.only(left: 25.0),
//             child: ListTile(
//               leading: Icon(
//                 Icons.home,
//                 color: Colors.black
//               ),
//               title: Text("Home"),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.only(left: 25.0),
//             child: ListTile(
//               leading: Icon(
//                 Icons.person,
//                 color: Colors.black
//               ),
//               title: const Text("Profile"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/profile_page');
//               },
//             ),
//           ),
          
//           Padding(
//             padding: const EdgeInsets.only(left: 25.0),
//             child: ListTile(
//               leading: Icon(
//                 Icons.home,
//                 color: Colors.black
//               ),
//               title: Text("Logout"),
//               onTap: () {
//                 Navigator.pop(context);
//                 logout();
//               },
//             ),
//           ),

//         ],
//       )
//     );
//   }
// }