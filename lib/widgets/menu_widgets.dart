import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_video_player/constants/colors.dart';
import 'package:local_video_player/providers/video_provider.dart';
import 'package:local_video_player/widgets/text.dart';
import 'package:local_video_player/widgets/video_info.dart';

class DeleteVideo extends ConsumerWidget {
  const DeleteVideo({
    super.key,
    required this.path,
  });
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setVideoProvider = ref.read(videoProvider.notifier);

    void onConfirmDelete() {
      setVideoProvider.deleteVideo(path);
      Navigator.pop(context);
      Navigator.pop(context);
    }

    void showAleartDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: bgSecondColor,
            title: TextWidget(
              text: "Are you sure you want to delete this video?",
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              maxLines: 2,
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                ),
                onPressed: onConfirmDelete,
                child: TextWidget(text: "Delete"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: TextWidget(text: "Cancel", color: Colors.black),
              )
            ],
          );
        },
      );
    }

    return IconButton(
        onPressed: showAleartDialog,
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ));
  }
}

class ShowVideoInfo extends StatelessWidget {
  const ShowVideoInfo({
    super.key,
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });
  final String path;
  final String name;
  final String size;
  final DateTime modified;

  @override
  Widget build(BuildContext context) {
    void showVideoInfo() {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Theme(
            data: ThemeData(
                appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(color: Colors.white),
            )),
            child: VideoInfo(
              path: path,
              name: name,
              size: size,
              modified: modified,
            ),
          ),
        ),
      );
    }

    return IconButton(
        onPressed: showVideoInfo,
        icon: Icon(
          Icons.info,
          color: Colors.green,
        ));
  }
}

class ShareVideo extends StatelessWidget {
  const ShareVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(
        Icons.share,
        color: Colors.blue,
      ),
    );
  }
}
