import 'dart:async'; // Add this import for Timer
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({
    super.key,
    required this.path,
    required this.name,
  });

  final String path;
  final String name;

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isLandScape = false;
  bool _showControls = true;
  bool _isControllerInitialized = false;
  Duration _currentPosition = Duration.zero;
  bool _isDraggingSlider = false;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializePlayer();
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel(); // Cancel any existing timer
    if (_showControls) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _handleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.file(File(widget.path));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _setOrientation(_controller.value.aspectRatio);
      if (mounted) {
        setState(() {
          _isControllerInitialized = true;
        });
        _controller.play();
      }
    });

    _controller.addListener(_controllerListener);
  }

  void _setOrientation(double aspectRatio) {
    if (!mounted) return;

    final shouldBeLandscape = aspectRatio > 1;
    if (isLandScape != shouldBeLandscape) {
      isLandScape = shouldBeLandscape;
      SystemChrome.setPreferredOrientations(shouldBeLandscape
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp]);
    }
  }

  void _controllerListener() {
    if (!_isDraggingSlider && mounted && _controller.value.isPlaying) {
      setState(() {
        _currentPosition = _controller.value.position;
      });
    }
  }

  Future<void> _skipVideo(Duration duration) async {
    final newPosition = _controller.value.position + duration;
    if (newPosition < Duration.zero) {
      await _controller.seekTo(Duration.zero);
    } else if (newPosition > _controller.value.duration) {
      await _controller.seekTo(_controller.value.duration);
    } else {
      await _controller.seekTo(newPosition);
    }
    _startHideControlsTimer(); // Reset timer after skipping
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildTopBar() {
    if (!_showControls) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.r),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              widget.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    if (!_showControls) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition.inMilliseconds.toDouble(),
                  min: 0.0,
                  max: _controller.value.duration.inMilliseconds.toDouble(),
                  onChangeStart: (value) {
                    _isDraggingSlider = true;
                    _hideControlsTimer?.cancel(); // Don't hide while dragging
                  },
                  onChangeEnd: (value) {
                    _isDraggingSlider = false;
                    _startHideControlsTimer(); // Start timer after drag ends
                  },
                  onChanged: (value) {
                    _controller.seekTo(Duration(milliseconds: value.toInt()));
                    setState(() {
                      _currentPosition = Duration(milliseconds: value.toInt());
                    });
                  },
                ),
              ),
              Text(
                _formatDuration(_controller.value.duration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32.r,
            ),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
              _startHideControlsTimer(); // Reset timer after play/pause
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            color: Colors.black,
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    _isControllerInitialized) {
                  return Stack(
                    children: [
                      // Video player with gesture detection
                      GestureDetector(
                        onTap: _handleControlsVisibility,
                        onDoubleTapDown: (details) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final dx = details.globalPosition.dx;

                          if (dx < screenWidth / 3) {
                            _skipVideo(const Duration(seconds: -10));
                          } else if (dx > (screenWidth * 2 / 3)) {
                            _skipVideo(const Duration(seconds: 10));
                          } else {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                            _startHideControlsTimer();
                          }
                        },
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                      // Top bar with title
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildTopBar(),
                      ),
                      // Bottom controls
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildBottomControls(),
                      ),
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel(); // Cancel timer when disposing
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }
}
