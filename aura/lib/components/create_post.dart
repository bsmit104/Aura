import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giphy_picker/giphy_picker.dart';
import '../helper/helper_functions.dart';
import '../services/user_service.dart';
import 'gif_player.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _contentController = TextEditingController();
  String? _gifUrl;
  bool _isLoading = false;
  Color _selectedColor = Colors.white;
  final List<Color> _colorOptions = [
    Colors.white,
    const Color(0xFFFF6B6B), // Coral Red
    const Color(0xFF4ECDC4), // Turquoise
    const Color(0xFFFFE66D), // Sunny Yellow
    const Color(0xFF7C5CBF), // Royal Purple
    const Color(0xFF95E1D3), // Mint
    const Color(0xFFF17A7E), // Salmon Pink
    const Color(0xFF4A5EBD), // Deep Blue
    const Color(0xFFFFB84D), // Orange
    const Color(0xFF66D7D1), // Aqua
    const Color(0xFFFC9842), // Tangerine
    const Color(0xFFFF8FD2), // Hot Pink
  ];

  Future<void> _pickGif() async {
    final gif = await GiphyPicker.pickGif(
      context: context,
      apiKey: 'm0ReKgP5RyqTmPh9e6n9wlENvQRzSMZc',
      fullScreenDialog: false,
      previewType: GiphyPreviewType.original,
      decorator: GiphyDecorator(
        showAppBar: false,
        searchElevation: 0,
        giphyTheme: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: Colors.black, width: 4),
            ),
          ),
        ),
      ),
    );

    if (gif != null && mounted) {
      final optimizedUrl = gif.images.fixedHeight?.url ?? gif.images.original!.url;
      setState(() {
        _gifUrl = optimizedUrl;
      });
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Background Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _colorOptions.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: Colors.black,
                      width: color == _selectedColor ? 4 : 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (_contentController.text.isEmpty && _gifUrl == null) {
      if (mounted) {
        displayMessageToUser("Please add some content or a GIF", context);
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get user data from Firestore to ensure we have the correct username
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        throw Exception("User document not found");
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final username = userData['username'] as String;

      // Start a batch write
      final batch = FirebaseFirestore.instance.batch();
      
      // Create the post document
      final postRef = FirebaseFirestore.instance.collection('posts').doc();
      batch.set(postRef, {
        'userId': user.uid,
        'username': username, // Use username from Firestore
        'content': _contentController.text,
        'gifUrl': _gifUrl,
        'timestamp': Timestamp.now(),
        'sparkles': [],
        'poops': [],
        'comments': [],
        'colorValue': _selectedColor != Colors.white ? _selectedColor.toARGB32() : null,
      });
      
      // Update the user's post count
      await UserService.incrementPostCount(user.uid);
      
      // Commit the batch
      await batch.commit();

      _contentController.clear();
      if (mounted) {
        setState(() {
          _gifUrl = null;
          _selectedColor = Colors.white;
        });
      }
    } catch (e) {
      if (mounted) {
        displayMessageToUser(e.toString(), context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _selectedColor,
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                letterSpacing: 0.2,
              ),
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_gifUrl != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: GifPlayer(
                url: _gifUrl!,
                fit: BoxFit.cover,
                maxHeight: 250,
              ),
            ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A5EBD),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _pickGif,
                  icon: const Icon(
                    Icons.gif_box,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _showColorPicker,
                  icon: const Icon(
                    Icons.palette,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 