import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/widgets/custom_controls.dart';
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

  final BetterPlayerConfiguration _betterPlayerConfiguration =
      BetterPlayerConfiguration(
    fit: BoxFit.contain,
    autoPlay: true,
    fullScreenByDefault: true,
    allowedScreenSleep: false, // Prevent screen from sleeping
    controlsConfiguration: BetterPlayerControlsConfiguration(
      playerTheme: BetterPlayerTheme.custom,
      customControlsBuilder: (controller, onPlayerVisibilityChanged) =>
          CustomControls(
        controller: controller,
        onControlsVisibilityChanged: onPlayerVisibilityChanged,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.path,
    );

    _betterPlayerController = BetterPlayerController(
      _betterPlayerConfiguration,
      betterPlayerDataSource: betterPlayerDataSource,
    );
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
