import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_video_player/providers/permission_provider.dart';
import 'package:local_video_player/providers/video_provider.dart';
import 'package:local_video_player/screens/folder_videos.dart';
import 'package:local_video_player/widgets/text.dart';

class Folders extends ConsumerWidget {
  const Folders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(permissionProvider);
    final videos =
        ref.watch(videoProvider); // Changed from ref.read to ref.watch

    if (permission.isLoading || videos.isLoading) {
      return const Center(child: CircularProgressIndicator());
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

    //! Adding a key to force rebuild when the folder list changes
    return KeyedSubtree(
      key: ValueKey(videos.videoFolders.length),
      child: ListView.builder(
          itemBuilder: (context, index) => _folders(
              context,
              videos.videoFolders[index].folderName,
              videos.videoFolders[index].videoFiles.length,
              index),
          itemCount: videos.videoFolders.length),
    );
  }

  Widget _folders(
      BuildContext context, String name, int videoCount, int index) {
    //? if there are more than 100 videos
    final String count = videoCount >= 100 ? "99+" : videoCount.toString();

    void onFolderClick() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Theme(
            data: ThemeData(
              appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
              ),
            ),
            child: FolderVideos(
              folderName: name,
              index: index,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0).r,
      child: InkWell(
        onTap: onFolderClick,
        child: Row(
          children: [
            Icon(
              Icons.folder,
              size: 60.sp,
              color: Colors.grey,
            ),
            SizedBox(
              width: 10.w,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: name,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                TextWidget(
                  text: "$count videos",
                  color: Colors.white60,
                  fontSize: 12.sp,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
