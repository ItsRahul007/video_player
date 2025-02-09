import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoBottomControls extends StatelessWidget {
  final VideoPlayerController controller;
  final Duration currentPosition;
  final bool showControls;
  final bool isLandScape;
  final Function(bool) onPlayPausePressed;
  final Function(double) onSliderChanged;
  final Function(double) onSliderChangeStart;
  final Function(double) onSliderChangeEnd;

  const VideoBottomControls({
    super.key,
    required this.controller,
    required this.currentPosition,
    required this.showControls,
    required this.isLandScape,
    required this.onPlayPausePressed,
    required this.onSliderChanged,
    required this.onSliderChangeStart,
    required this.onSliderChangeEnd,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (!showControls) return const SizedBox.shrink();
    double iconSize = isLandScape ? 18.sp : 34.sp;

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
                _formatDuration(currentPosition),
                style: const TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Slider(
                  value: currentPosition.inMilliseconds.toDouble(),
                  min: 0.0,
                  max: controller.value.duration.inMilliseconds.toDouble(),
                  onChangeStart: onSliderChangeStart,
                  onChangeEnd: onSliderChangeEnd,
                  onChanged: onSliderChanged,
                ),
              ),
              Text(
                _formatDuration(controller.value.duration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          //? pause, next, and previous buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: iconSize,
                ),
                onPressed: () => onPlayPausePressed(controller.value.isPlaying),
              ),
              SizedBox(width: 16.w),
              IconButton(
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: iconSize,
                ),
                onPressed: () => onPlayPausePressed(controller.value.isPlaying),
              ),
              SizedBox(width: 16.w),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: iconSize,
                ),
                onPressed: () => onPlayPausePressed(controller.value.isPlaying),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
