import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GifPlayer extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double maxHeight;

  const GifPlayer({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.maxHeight = 300,
  });

  @override
  State<GifPlayer> createState() => _GifPlayerState();
}

class _GifPlayerState extends State<GifPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isVisible = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (_isDisposed) return;

    final mp4Url = widget.url.replaceAll('.gif', '.mp4');
    
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(mp4Url),
    );
    
    try {
      await _controller?.initialize();
      if (_isDisposed) {
        _controller?.dispose();
        return;
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller?.setLooping(true);
        if (_isVisible) {
          _controller?.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (_isDisposed) return;
    
    // Consider the widget visible if it's more than 50% visible
    final isVisible = info.visibleFraction > 0.5;
    
    if (_isVisible != isVisible && mounted) {
      setState(() {
        _isVisible = isVisible;
      });
      
      if (_isInitialized && _controller != null) {
        if (_isVisible) {
          _controller?.play();
        } else {
          _controller?.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.maxHeight,
        ),
        child: CachedNetworkImage(
          imageUrl: widget.url,
          fit: widget.fit,
          width: widget.width ?? double.infinity,
          height: widget.height,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4A5EBD),
            ),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(
              Icons.error_outline,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ),
      );
    }

    final aspectRatio = _controller!.value.aspectRatio;
    
    return VisibilityDetector(
      key: Key('gif_${widget.url}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.maxHeight,
        ),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
} 