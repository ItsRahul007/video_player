import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_video_player/providers/video_provider.dart';
import 'package:local_video_player/widgets/text.dart';

class NoVideos extends ConsumerWidget {
  const NoVideos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
        child: MaterialButton(
      color: const Color.fromARGB(255, 247, 247, 247),
      child: TextWidget(
        text: "Scan Videos",
        color: Colors.black87,
        fontSize: 16.sp,
      ),
      onPressed: () {
        ref.read(videoProvider.notifier).getAllVideos();
      },
    ));
  }
}
