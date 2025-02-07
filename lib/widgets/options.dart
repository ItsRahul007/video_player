import 'package:flutter/material.dart';
import 'package:local_video_player/providers/video_provider.dart';
import 'package:local_video_player/widgets/menu_widgets.dart';

class Options extends StatelessWidget {
  const Options({super.key, required this.video});

  final VideoFile video;

  @override
  Widget build(BuildContext context) {
    List<Widget> menuList = [
      ShareVideo(),
      ShowVideoInfo(
        path: video.path,
        name: video.name,
        size: video.fileSize,
        modified: video.modified,
      ),
      DeleteVideo(path: video.path),
    ];

    return Row(
      children: menuList.map((item) => item).toList(),
    );
  }
}
