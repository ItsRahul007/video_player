import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:local_video_player/constants/widget_list.dart';
import 'package:local_video_player/widgets/comon_bg.dart';
import 'package:local_video_player/widgets/text.dart';
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
  bool isLoading = true;

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
        isLoading = false;
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

  String _formatDuration(Duration? duration) {
    if (duration == null) {
      return "Unknown";
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String _getVideoWidthAndHeight(Size? size) {
    if (size == null) {
      return "Unknown";
    }

    return "${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}";
  }

  String _getModifiedDate(DateTime modified) {
    final double modifiedHour = modified.hour.toDouble() > 12
        ? modified.hour - 12
        : modified.hour.toDouble();

    return "Modified ${modified.day} ${monthAbbreviations[modified.month - 1]} ${modified.year} at ${modifiedHour.toStringAsFixed(0)}:${modified.minute} ${modified.hour >= 12 ? "PM" : "AM"}";
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _videoThumbnail(),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.all(10).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: widget.name,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        maxLines: 3,
                      ),
                      SizedBox(height: 38.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                          SizedBox(width: 24.w),
                          Expanded(
                            child: Column(
                              children: [
                                TextWidget(
                                  text: widget.path,
                                  maxLines: 4,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextWidget(
                                      text: _getVideoWidthAndHeight(
                                          videoWidthAndHeight),
                                    ),
                                    SizedBox(width: 10.w),
                                    TextWidget(
                                      text: "•",
                                      fontSize: 20.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    TextWidget(
                                      text: widget.size,
                                    ),
                                    SizedBox(width: 10.w),
                                    TextWidget(
                                      text: "•",
                                      fontSize: 20.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    TextWidget(
                                      text: _formatDuration(videoDuration),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: const EdgeInsets.all(10).r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                      SizedBox(width: 24.w),
                      TextWidget(
                        text: _getModifiedDate(widget.modified),
                        fontSize: 18.sp,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _videoThumbnail() {
    return Container(
      height: 200.h,
      width: double.infinity,
      color: Colors.white24,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          isLoading
              ? Center(
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: const CircularProgressIndicator(),
                  ),
                )
              : videoThumbnail != null
                  ? Image.memory(
                      videoThumbnail!,
                      fit: BoxFit.fitHeight,
                    )
                  : Image.asset("assets/images/video_not_loaded.jpg"),
          Container(
            height: 100.h,
            width: double.infinity,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 10.w),
                SizedBox(
                  height: 50.h,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30.sp,
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
}
