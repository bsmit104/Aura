import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aura/models/user.dart';
import 'package:aura/services/user_service.dart';
import 'package:aura/pages/followers_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  UserModel? _userModel;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    try {
      // Use UserService to ensure user document exists
      _userModel = await UserService.ensureUserDocument();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    // Prioritize Firestore username, then Auth displayName, then email-based fallback
    final String displayName = _userModel?.username ?? 
        currentUser?.displayName ?? 
        (currentUser?.email?.split('@')[0] ?? 'Guest');
    final String email = _userModel?.email ?? currentUser?.email ?? 'No email';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E9), // Eggshell background
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5EBD), // Deep blue
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Container(
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
                    ),
                    const SizedBox(height: 20),
                    
                    // User Info Card
                    _buildInfoCard(
                      title: 'User Information',
                      children: [
                        _buildInfoRow('Username', displayName),
                        _buildInfoRow('Email', email),
                        if (_userModel?.bio != null)
                          _buildInfoRow('Bio', _userModel!.bio!),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Section
                    const Text(
                      'Your Stats',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Posts',
                            value: _userModel?.postCount.toString() ?? '0',
                            color: const Color(0xFF8A4AF0), // Muted purple
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowersPage(
                                    userId: _userModel!.id,
                                    isFollowers: false,
                                  ),
                                ),
                              );
                            },
                            child: _buildStatCard(
                              title: 'Following',
                              value: _userModel?.followingCount.toString() ?? '0',
                              color: const Color(0xFF4ECDC4), // Punchy green
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowersPage(
                                    userId: _userModel!.id,
                                    isFollowers: true,
                                  ),
                                ),
                              );
                            },
                            child: _buildStatCard(
                              title: 'Followers',
                              value: _userModel?.followerCount.toString() ?? '0',
                              color: const Color(0xFFFF6B6B), // Coral
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Settings Section
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsButton(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () {},
                    ),
                    _buildSettingsButton(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _buildSettingsButton(
                      icon: Icons.security,
                      title: 'Privacy',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1E9), // Eggshell
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required Color color}) {
    return Container(
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
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F1E9), // Eggshell
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
              size: 24,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
