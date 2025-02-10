import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_video_player/constants/colors.dart';
import 'package:local_video_player/providers/video_provider.dart';
import 'package:local_video_player/widgets/text.dart';
import 'package:local_video_player/screens/video_info.dart';
import 'package:share_plus/share_plus.dart';

class DeleteVideo extends ConsumerStatefulWidget {
  const DeleteVideo({
    super.key,
    required this.path,
  });
  final String path;

  @override
  ConsumerState<DeleteVideo> createState() => _DeleteVideoState();
}

class _DeleteVideoState extends ConsumerState<DeleteVideo> {
  @override
  Widget build(BuildContext context) {
    final setVideoProvider = ref.read(videoProvider.notifier);
    final isDeletingVideo = ref.watch(videoProvider).isDeletingVideo;

    void onConfirmDelete() async {
      await setVideoProvider.deleteVideo(widget.path);
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }

    void showAlertDialog() {
      showDialog(
        context: context,
        barrierDismissible: !isDeletingVideo,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => !isDeletingVideo,
            child: AlertDialog(
              backgroundColor: bgSecondColor,
              title: TextWidget(
                text: "Are you sure you want to delete this video?",
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                maxLines: 2,
              ),
              content: isDeletingVideo
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : null,
              actions: isDeletingVideo
                  ? null // No buttons while deleting
                  : [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                        ),
                        onPressed: onConfirmDelete,
                        child: TextWidget(text: "Delete"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: TextWidget(text: "Cancel", color: Colors.black),
                      )
                    ],
            ),
          );
        },
      );
    }

    return IconButton(
        onPressed: showAlertDialog,
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
  const ShareVideo({
    super.key,
    required this.path,
  });
  final String path;

  @override
  Widget build(BuildContext context) {
    void shareFile() {
      Navigator.pop(context);
      Share.shareXFiles([XFile(path)]);
    }

    return IconButton(
      onPressed: shareFile,
      icon: Icon(
        Icons.share,
        color: Colors.blue,
      ),
    );
  }
}
