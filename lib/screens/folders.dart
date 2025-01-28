import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/providers/permission_provider.dart';
import 'package:video_player/providers/video_provider.dart';
import 'package:video_player/screens/folder_videos.dart';
import 'package:video_player/widgets/text.dart';

class Folders extends ConsumerStatefulWidget {
  const Folders({super.key});

  @override
  ConsumerState<Folders> createState() => _FoldersState();
}

class _FoldersState extends ConsumerState<Folders> {
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

    debugPrint("folders: ${videos.videoFolders.length}");

    return ListView.builder(
        itemBuilder: (context, index) => _folders(
            context,
            videos.videoFolders[index].folderName,
            videos.videoFolders[index].videoFiles.length,
            index),
        itemCount: videos.videoFolders.length);
  }

  Widget _folders(
      BuildContext context, String name, int videoCount, int index) {
    //? if there are more than 100 videos
    final String count = videoCount >= 100 ? "99+" : videoCount.toString();

    void onFolderClick() {
      showDialog(
        context: context,
        builder: (context) => Theme(
          data: ThemeData(
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(
                  color: Colors.white), // Set your desired color here
            ),
          ),
          child: FolderVideos(
            folderName: name,
            index: index,
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
            //? the icon
            Icon(
              Icons.folder,
              size: 60.sp,
              color: Colors.grey,
            ),
            SizedBox(
              width: 10.w,
            ),
            //?
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
