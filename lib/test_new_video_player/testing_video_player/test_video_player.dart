import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TestVideoPlayer extends StatefulWidget {
  const TestVideoPlayer({
    super.key,
    required this.path,
    required this.name,
  });

  final String path;
  final String name;

  @override
  State<TestVideoPlayer> createState() => _TestVideoPlayerState();
}

class _TestVideoPlayerState extends State<TestVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
