import 'dart:async'; // Add this import for Timer
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_video_player/providers/video_setting.dart';
import 'package:local_video_player/widgets/video_controls/bottom_controls.dart';
import 'package:local_video_player/widgets/video_controls/top_bar.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class PlayVideo extends ConsumerStatefulWidget {
  const PlayVideo({
    super.key,
    required this.path,
    required this.name,
    this.isContent = false,
  });

  final String path;
  final String name;
  final bool isContent;

  @override
  ConsumerState<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends ConsumerState<PlayVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isLandScape = false;
  bool _showControls = true;
  bool _isControllerInitialized = false;
  Duration _currentPosition = Duration.zero;
  bool _isDraggingSlider = false;
  Timer? _hideControlsTimer;

  //? variables for drag seeking
  double _dragStartX = 0;
  Duration? _dragStartPosition;
  bool _isDragging = false;
  double _seekSeconds = 0;

  //? variables for vertical drag controls
  double _currentVolume = 0.0;
  double _currentBrightness = 0.0;
  bool _isVerticalDragging = false;
  String _verticalDragType = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializePlayer();
    _startHideControlsTimer();
    _initializeVolumeBrightness();

    // Initialize volume controller
    VolumeController.instance.showSystemUI = false;
  }

  Future<void> _initializeVolumeBrightness() async {
    setState(() {
      _currentBrightness = ToDoDB.instance.screenBrightness;
      _currentVolume = ToDoDB.instance.volume;
    });

    await ScreenBrightness.instance
        .setApplicationScreenBrightness(_currentBrightness);
    await VolumeController.instance.setVolume(_currentVolume);
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

  Future<void> _initializePlayer() async {
    if (widget.isContent) {
      _controller = VideoPlayerController.contentUri(Uri.parse(widget.path));
    } else {
      _controller = VideoPlayerController.file(File(widget.path));
    }
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

  //? listing to the vertical drags
  void _handleVerticalDragUpdate(
    DragUpdateDetails details,
    BuildContext context,
  ) {
    if (!_isVerticalDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isRightSide = details.globalPosition.dx > screenWidth / 2;

    // Calculate the drag percentage (-1 to 1)
    final dragPercent = -(details.delta.dy / screenHeight);

    setState(() {
      if (isRightSide) {
        // Volume control on right side
        _verticalDragType = 'volume';
        _currentVolume = (_currentVolume + dragPercent).clamp(0.0, 1.0);
        VolumeController.instance.setVolume(_currentVolume);
      } else {
        // Brightness control on left side
        _verticalDragType = 'brightness';
        _currentBrightness = (_currentBrightness + dragPercent).clamp(0.0, 1.0);
        ScreenBrightness.instance
            .setApplicationScreenBrightness(_currentBrightness);
      }
    });
  }

  //? turning the screen into landscape according to the aspect ratio
  void _setOrientation(double aspectRatio) {
    if (!mounted) return;

    final shouldBeLandscape = aspectRatio > 1.1;
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

  void _handleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  Future<void> _skipVideo(Duration duration) async {
    final newPosition = _controller.value.position + duration;
    if (newPosition < Duration.zero) {
      await _controller.seekTo(Duration.zero);
      setState(() {
        _currentPosition = Duration.zero;
      });
    } else if (newPosition > _controller.value.duration) {
      await _controller.seekTo(_controller.value.duration);
      setState(() {
        _currentPosition = _controller.value.duration;
      });
    } else {
      await _controller.seekTo(newPosition);
      setState(() {
        _currentPosition = newPosition;
      });
    }
    _startHideControlsTimer();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
      _dragStartPosition = _controller.value.position;
      _seekSeconds = 0;
    });
    // Pause video while dragging
    _controller.pause();
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (_dragStartPosition != null) {
      final newPosition = _dragStartPosition!.inSeconds + _seekSeconds;
      await _controller.seekTo(Duration(seconds: newPosition.round()));
      // Resume playback if video was playing before drag
      _controller.play();
    }
    setState(() {
      _isDragging = false;
      _dragStartPosition = null;
      _seekSeconds = 0;
    });
  }

  //? for handling drag seeking
  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final dragDistance = details.globalPosition.dx - _dragStartX;
    //! Adjust sensitivity: 1 second per 10 pixels of drag
    _seekSeconds = (dragDistance / 10).roundToDouble();

    if (_dragStartPosition != null) {
      final newPosition = _dragStartPosition!.inSeconds + _seekSeconds;
      final targetPosition = Duration(seconds: newPosition.round());

      //? Ensure we don't seek beyond video bounds
      if (targetPosition >= Duration.zero &&
          targetPosition <= _controller.value.duration) {
        setState(() {
          _currentPosition = targetPosition;
        });
      }
    }
  }

  //? for listning to those double taps
  void _onDoubleTapListners(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    if (dx < screenWidth / 3) {
      _skipVideo(const Duration(seconds: -10));
    } else if (dx > (screenWidth * 2 / 3)) {
      _skipVideo(const Duration(seconds: 10));
    } else {
      setState(() {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      });
      _startHideControlsTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                _isControllerInitialized) {
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _handleControlsVisibility,
                    onDoubleTapDown: _onDoubleTapListners,
                    onHorizontalDragStart: _onHorizontalDragStart,
                    onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    onVerticalDragStart: (details) {
                      setState(() {
                        _isVerticalDragging = true;
                      });
                    },
                    onVerticalDragUpdate: (details) =>
                        _handleVerticalDragUpdate(details, context),
                    onVerticalDragEnd: (details) {
                      setState(() {
                        _isVerticalDragging = false;
                        _verticalDragType = '';
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  ),
                  //? Seeking overlay
                  _buildSeekingOverlay(),
                  _buildVerticalDragOverlay(),
                  // Controls
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildTopBar(),
                  ),
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
    );
  }

  Widget _buildTopBar() {
    if (!_showControls) return const SizedBox.shrink();

    return TopBar(
      name: widget.name,
      isScreenRoated: isLandScape,
      isContent: widget.isContent,
    );
  }

  Widget _buildBottomControls() {
    if (!_showControls) return const SizedBox.shrink();

    return VideoBottomControls(
      controller: _controller,
      currentPosition: _currentPosition,
      showControls: _showControls,
      isLandScape: isLandScape,
      onPlayPausePressed: (isPlaying) {
        setState(() {
          isPlaying ? _controller.pause() : _controller.play();
        });
        _startHideControlsTimer();
      },
      onSliderChanged: (value) {
        _controller.seekTo(Duration(milliseconds: value.toInt()));
        setState(() {
          _currentPosition = Duration(milliseconds: value.toInt());
        });
      },
      onSliderChangeStart: (value) {
        _isDraggingSlider = true;
        _hideControlsTimer?.cancel();
      },
      onSliderChangeEnd: (value) {
        _isDraggingSlider = false;
        _startHideControlsTimer();
      },
    );
  }

  Widget _buildSeekingOverlay() {
    if (!_isDragging || _seekSeconds == 0) return const SizedBox.shrink();

    final seekText = _seekSeconds > 0
        ? '+${_seekSeconds.round()}s'
        : '${_seekSeconds.round()}s';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          seekText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDragOverlay() {
    if (!_isVerticalDragging) return const SizedBox.shrink();

    final IconData icon;
    final String label;
    final double value;

    if (_verticalDragType == 'volume') {
      icon = _currentVolume <= 0
          ? Icons.volume_off
          : _currentVolume < 0.5
              ? Icons.volume_down
              : Icons.volume_up;
      label = 'Volume';
      value = _currentVolume;
    } else {
      icon = Icons.brightness_6;
      label = 'Brightness';
      value = _currentBrightness;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[700],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    ToDoDB.instance.setBrightnessAndVolume(
      brightness: _currentBrightness,
      volume: _currentVolume,
    );
    VolumeController.instance.showSystemUI = true;
    ScreenBrightness.instance.resetApplicationScreenBrightness();
    super.dispose();
  }
}
