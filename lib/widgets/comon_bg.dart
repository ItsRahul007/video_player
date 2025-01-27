import 'package:flutter/material.dart';
import 'package:video_player/constants/colors.dart';

class ComonBg extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;

  const ComonBg({super.key, this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgFirstColor, bgSecondColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      height: height,
      width: width,
      child: child,
    );
  }
}
