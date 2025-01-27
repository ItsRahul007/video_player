import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/screens/folder_videos.dart';
import 'package:video_player/widgets/text.dart';

class Folders extends StatelessWidget {
  const Folders({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _folders(context, "Camera", 6),
        _folders(context, "Download", 10),
        _folders(context, "WhatsApp", 200),
      ],
    );
  }

  Widget _folders(BuildContext context, String name, int videoCount) {
    //? if there are more than 100 videos
    final String count = videoCount >= 100 ? "99+" : videoCount.toString();

    //TODO: if we click on any folder then show a dialogue where we will show case all the videos
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
