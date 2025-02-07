import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_video_player/constants/colors.dart';
import 'package:local_video_player/providers/video_provider.dart';
import 'package:local_video_player/widgets/options.dart';
import 'package:popover/popover.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.video,
  });

  final VideoFile video;

  @override
  Widget build(BuildContext context) {
    void onThreeDotClick() {
      showPopover(
        context: context,
        bodyBuilder: (context) => Options(
          video: video,
        ),
        width: 150.w,
        height: 60.h,
        direction: PopoverDirection.left,
        backgroundColor: bgSecondColor,
        arrowHeight: 15,
        arrowWidth: 20,
      );
    }

    return GestureDetector(
      onTap: onThreeDotClick,
      child: Icon(
        Icons.more_vert,
        size: 25.sp,
        color: Colors.white,
      ),
    );
  }
}
