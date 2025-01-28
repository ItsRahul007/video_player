import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/constants/widget_list.dart';
import 'package:video_player/providers/permission_provider.dart';
import 'package:video_player/providers/video_provider.dart';
import 'package:video_player/widgets/single_video_file.dart';
import 'package:video_player/widgets/text.dart';

class AllVideos extends ConsumerStatefulWidget {
  const AllVideos({super.key});

  @override
  ConsumerState<AllVideos> createState() => _AllVideosState();
}

class _AllVideosState extends ConsumerState<AllVideos> {
  @override
  void initState() {
    Future(() async {
      final permission =
          await ref.read(permissionProvider.notifier).checkAudioPermissions();
      if (!permission) {
        ref.read(permissionProvider.notifier).manualRequestPermission();
      } else {
        ref.read(videoProvider.notifier).getAllVideos();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(permissionProvider);
    final videos = ref.read(videoProvider);

    if (permission.isLoading || videos.isLoading) {
      return Center(child: CircularProgressIndicator());
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
        name: videos.videoFiles[index].name,
        path: videos.videoFiles[index].path,
      ),
      itemCount: videos.videoFiles.length,
    );
  }
}
