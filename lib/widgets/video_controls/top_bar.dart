import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.name,
    required this.isScreenRoated,
    this.isContent = false,
  });

  final String name;
  final bool isScreenRoated;
  final bool isContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16.w, vertical: isScreenRoated ? 8.h : 30.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: isScreenRoated ? 10.sp : 18.sp,
            ),
            onPressed: () {
              //! check why is this not working perfectly
              if (isContent) {
                SystemNavigator.pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: isScreenRoated ? 8.sp : 18.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
