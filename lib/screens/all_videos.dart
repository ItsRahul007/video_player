import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_video_player/constants/widget_list.dart';
import 'package:local_video_player/providers/permission_provider.dart';
import 'package:local_video_player/providers/video_provider.dart';
import 'package:local_video_player/widgets/no_videos.dart';
import 'package:local_video_player/widgets/single_video_file.dart';
import 'package:local_video_player/widgets/text.dart';

class AllVideos extends ConsumerStatefulWidget {
  const AllVideos({super.key});

  @override
  ConsumerState<AllVideos> createState() => _AllVideosState();
}

class _AllVideosState extends ConsumerState<AllVideos> {
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
      return const Center(child: CircularProgressIndicator());
    }

    if (videos.videoFiles.isEmpty) {
      return NoVideos();
    }

    if (!permission.havePermission) {
      return Center(
        child: TextButton(
            onPressed: () {
              ref.read(permissionProvider.notifier).manualRequestPermission();
            },
            child: TextWidget(text: "Give Permission")),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) => SingleVideoFile(
        date:
            "${videos.videoFiles[index].modified.day} ${monthAbbreviations[videos.videoFiles[index].modified.month - 1]}",
        video: videos.videoFiles[index],
      ),
      itemCount: videos.videoFiles.length,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
