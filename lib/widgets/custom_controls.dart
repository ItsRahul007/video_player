import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_video_player/constants/widget_list.dart';

class CustomControls extends StatefulWidget {
  final BetterPlayerController controller;
  final Function(bool visbility)? onControlsVisibilityChanged;

  const CustomControls({
    super.key,
    required this.controller,
    this.onControlsVisibilityChanged,
  });

  @override
  State<CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  bool isPlaying = true;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  Timer? _positionUpdateTimer;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    _startPositionUpdateTimer();
  }

  void setIsPlaying(bool value) {
    setState(() {
      isPlaying = value;
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
          widget.onControlsVisibilityChanged?.call(false);
        });
      }
    });
  }

  void _startPositionUpdateTimer() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentPosition =
              widget.controller.videoPlayerController?.value.position ??
                  Duration.zero;
        });
      }
    });
  }

  void _handleTap() {
    setState(() {
      _controlsVisible = !_controlsVisible;
      widget.onControlsVisibilityChanged?.call(_controlsVisible);
    });

    if (_controlsVisible) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          // This transparent container ensures the GestureDetector covers full area
          Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),

          // Controls Layer
          AnimatedOpacity(
            opacity: _controlsVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Stack(
              children: [
                // Play/Pause Button
                Center(
                  child: StreamBuilder(
                    stream: widget.controller.controllerEventStream,
                    builder: (context, snapshot) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 50.sp,
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              widget.controller.pause();
                              setIsPlaying(false);
                              _handleTap();
                            } else {
                              widget.controller.play();
                              setIsPlaying(true);
                            }
                            _startHideTimer();
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(top: 18).r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: StreamBuilder(
                      stream: widget.controller.controllerEventStream,
                      builder: (context, snapshot) {
                        final duration = widget.controller.videoPlayerController
                                ?.value.duration ??
                            Duration.zero;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress Slider
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8).r,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  thumbColor: Colors.white,
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor:
                                      Colors.white.withOpacity(0.3),
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                  trackHeight: 3,
                                ),
                                child: Slider(
                                  value: _currentPosition.inMilliseconds
                                      .toDouble(),
                                  max: duration.inMilliseconds.toDouble(),
                                  onChanged: (value) {
                                    widget.controller.seekTo(
                                        Duration(milliseconds: value.toInt()));
                                    _startHideTimer();
                                  },
                                ),
                              ),
                            ),

                            // Bottom Row
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16).r,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Time Display
                                  Text(
                                    '${_formatDuration(_currentPosition)} / ${_formatDuration(duration)}',
                                    style: TextStyle(color: Colors.white),
                                  ),

                                  // Control Buttons
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.speed,
                                            color: Colors.white),
                                        onPressed: () {
                                          _showSpeedDialog(context);
                                          _startHideTimer();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.fullscreen,
                                            color: Colors.white),
                                        onPressed: () {
                                          widget.controller.toggleFullScreen();
                                          _startHideTimer();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Playback Speed'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (double speed in speedList)
                  ListTile(
                    title: Text('${speed}x'),
                    onTap: () {
                      widget.controller.setSpeed(speed);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _positionUpdateTimer?.cancel();
    super.dispose();
  }
}
