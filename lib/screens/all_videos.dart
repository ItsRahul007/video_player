import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/providers/permission_provider.dart';
import 'package:video_player/widgets/single_video_file.dart';

class AllVideos extends ConsumerStatefulWidget {
  const AllVideos({super.key});

  @override
  ConsumerState<AllVideos> createState() => _AllVideosState();
}

class _AllVideosState extends ConsumerState<AllVideos> {
  @override
  void initState() {
    Future(() async {
      final permission = ref.watch(permissionProvider);
      if (!permission.havePermission) {
        ref.read(permissionProvider.notifier).manualRequestPermission();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
