import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_video_player/constants/widget_list.dart';
import 'package:local_video_player/providers/permission_provider.dart';
import 'package:local_video_player/providers/video_provider.dart';
import 'package:local_video_player/widgets/comon_bg.dart';
import 'package:local_video_player/widgets/no_videos.dart';
import 'package:local_video_player/widgets/single_video_file.dart';
import 'package:local_video_player/widgets/text.dart';

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
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    final permission =
        await ref.read(permissionProvider.notifier).checkAudioPermissions();
    if (!permission) {
      final bool isPermissionGranted =
          await ref.read(permissionProvider.notifier).manualRequestPermission();
      if (isPermissionGranted) {
        await ref.read(videoProvider.notifier).getAllVideos();
      }
    } else {
      await ref.read(videoProvider.notifier).getAllVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(permissionProvider);
    final videos = ref.watch(videoProvider);

    if (permission.isLoading || videos.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (videos.videoFiles.isEmpty) {
      return NoVideos();
    }

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
