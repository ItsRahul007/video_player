import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/widgets/play_video.dart';
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
  File? myThumbnail;

  @override
  void initState() {
    super.initState();
    _getVideoThumbnail(widget.path);
  }

  Future<void> _getVideoThumbnail(String path) async {
    try {
      final Directory appDir = await getTemporaryDirectory();
      final String imagePath =
          "${appDir.path}/${widget.name.split(" ").join("_")}.jpeg";
      final File imageFile = File(imagePath);

      //! Check if file exists and is a valid image
      if (await imageFile.exists()) {
        try {
          //? Decode the image to verify it's valid
          await decodeImageFromList(await imageFile.readAsBytes());
          setState(() {
            myThumbnail = imageFile;
          });
        } catch (e) {
          //? If image is invalid, proceed to regenerate
          await _generateThumbnail(path, imageFile);
        }
      } else {
        //? File doesn't exist, generate thumbnail
        await _generateThumbnail(path, imageFile);
      }
    } catch (e) {
      print('Error handling thumbnail: $e');
    }
  }

  Future<void> _generateThumbnail(String path, File imageFile) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );

    // ignore: unnecessary_null_comparison
    if (uint8list != null) {
      final File file = await imageFile.writeAsBytes(uint8list);
      setState(() {
        myThumbnail = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0).r,
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => PlayVideo(path: widget.path));
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
                      color: Colors.white,
                    ),
                    child: myThumbnail != null
                        ? Image.file(myThumbnail!)
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
