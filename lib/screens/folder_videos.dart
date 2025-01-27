import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/widgets/comon_bg.dart';
import 'package:video_player/widgets/single_video_file.dart';
import 'package:video_player/widgets/text.dart';

class FolderVideos extends StatelessWidget {
  final String folderName;

  const FolderVideos({super.key, required this.folderName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: ComonBg(),
        elevation: 5,
        title: TextWidget(
          text: folderName,
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ComonBg(
        child: Column(
          children: [
            SingleVideoFile(
              name: "hehe",
              date: "12 Jan",
            ),
            SingleVideoFile(
              name: "New video",
              date: "2 Jan",
            ),
            SingleVideoFile(
              name: "Yoyo bantai",
              date: "12 Dec",
            ),
          ],
        ),
      ),
    );
  }
}
