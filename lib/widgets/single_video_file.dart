import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:video_player/widgets/text.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

// ignore: must_be_immutable
class SingleVideoFile extends StatefulWidget {
  final String name;
  final String date;
  final String path;

  const SingleVideoFile({
    super.key,
    required this.name,
    required this.date,
    required this.path,
  });

  @override
  State<SingleVideoFile> createState() => _SingleVideoFileState();
}

class _SingleVideoFileState extends State<SingleVideoFile> {
  Uint8List? myThumbnail;

  @override
  void initState() {
    super.initState();
    _getVideoThumbnail(widget.path);
  }

  Future<void> _getVideoThumbnail(String path) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );

    setState(() {
      myThumbnail = uint8list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0).r,
      child: InkWell(
        onTap: () {
          //TODO: play the video when tapped
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5).r,
                      color: Colors.black,
                    ),
                    child: myThumbnail != null
                        ? Image.memory(myThumbnail!)
                        : SizedBox(),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 250.w,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: widget.name,
                            fontSize: 14.sp,
                            maxLines: 2,
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 4).r,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2).r,
                                color: const Color.fromARGB(255, 23, 74, 97),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4).r,
                                child: TextWidget(
                                  text: widget.date,
                                  fontSize: 10.sp,
                                ),
                              ))
                        ]),
                  )
                ],
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  size: 20.sp,
                  color: Colors.white,
                ))
          ],
        ),
      ),
    );
  }
}
