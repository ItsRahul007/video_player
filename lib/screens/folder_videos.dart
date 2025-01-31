import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/constants/widget_list.dart';
import 'package:video_player/providers/video_provider.dart';
import 'package:video_player/widgets/comon_bg.dart';
import 'package:video_player/widgets/single_video_file.dart';
import 'package:video_player/widgets/text.dart';

class FolderVideos extends ConsumerStatefulWidget {
  final String folderName;
  final int index;

  const FolderVideos(
      {super.key, required this.folderName, required this.index});

  @override
  ConsumerState<FolderVideos> createState() => _FolderVideosState();
}

class _FolderVideosState extends ConsumerState<FolderVideos> {
  @override
  Widget build(BuildContext context) {
    final videos = ref.read(videoProvider);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: ComonBg(),
        elevation: 5,
        title: TextWidget(
          text: widget.folderName,
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ComonBg(
        child: ListView.builder(
          itemBuilder: (context, index) {
            final VideoFile video =
                videos.videoFolders[widget.index].videoFiles[index];

            return SingleVideoFile(
              name: video.name,
              path: video.path,
              date:
                  "${video.modified.day} ${monthAbbreviations[video.modified.month - 1]}",
            );
          },
          itemCount: videos.videoFolders[widget.index].videoFiles.length,
        ),
      ),
    );
  }
}
