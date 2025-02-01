import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/widgets/text.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({super.key, required this.path, required this.name});
  final String path;
  final String name;

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late BetterPlayerController _betterPlayerController;
  double? videoWidth;
  double? videoHeight;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }

  void _initializeVideo() {
    BetterPlayerDataSource betterPlayerDataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.file, widget.path);

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        fit: BoxFit.contain,
        autoDetectFullscreenDeviceOrientation: true,
        autoPlay: true,
      ),
    );

    _betterPlayerController.setupDataSource(betterPlayerDataSource).then((_) {
      //! Video is initialized, now we can get the dimensions
      Size? videoSize =
          _betterPlayerController.videoPlayerController?.value.size;

      if (videoSize != null) {
        setState(() {
          videoWidth = videoSize.width;
          videoHeight = videoSize.height;
        });
        _betterPlayerController.enterFullScreen();
        _betterPlayerController
            .setOverriddenAspectRatio(videoSize.width / videoSize.height);
        if ((videoSize.width / videoSize.height) > 0.5625) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
            ),
            elevation: 5,
            title: TextWidget(
              text: widget.name,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              maxLines: 2,
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(8.0).r,
              child: BetterPlayer(
                controller: _betterPlayerController,
              ),
            ),
          )),
    );
  }
}
