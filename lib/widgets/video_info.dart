import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:local_video_player/widgets/comon_bg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoInfo extends StatefulWidget {
  const VideoInfo({
    super.key,
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });

  final String path;
  final String name;
  final String size;
  final DateTime modified;

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> {
  late VideoPlayerController _controller;
  //! if we can't get any thumbnail then use asset fall back image
  Uint8List? videoThumbnail;
  //? video width and height
  Size? videoWidthAndHeight;
  Duration? videoDuration;

  void _generateVideoThumbnail() async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: widget.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 600,
      quality: 40,
    );

    // ignore: unnecessary_null_comparison
    if (uint8list != null) {
      setState(() {
        videoThumbnail = uint8list;
      });
    }
  }

  void _setController() async {
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then(
        (value) {
          setState(() {
            videoWidthAndHeight = _controller.value.size;
            videoDuration = _controller.value.duration;
          });
        },
      );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _generateVideoThumbnail();
    _setController();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return ComonBg(
      child: SafeArea(
        child: Scaffold(
          body: ComonBg(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 200.h,
                  width: double.infinity,
                  child: videoThumbnail != null
                      ? Image.memory(
                          videoThumbnail!,
                          fit: BoxFit.fitHeight,
                        )
                      : Image.asset("assets/images/video_not_loaded.jpg"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
