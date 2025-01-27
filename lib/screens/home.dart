import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/constants/widget_list.dart';
import 'package:video_player/widgets/comon_bg.dart';
import 'package:video_player/widgets/text.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  int _currentIndex = 0;

  void changeCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: ComonBg(),
        title: TextWidget(
          text: _currentIndex == 0 ? "All Videos" : "Folders",
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBar: ComonBg(
        height: 60.h,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: changeCurrentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 25.sp,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: "All Videos",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.folder,
              ),
              label: "Folders",
            ),
          ],
          elevation: 5,
        ),
      ),
      body: ComonBg(
          height: double.infinity.h,
          width: double.infinity.w,
          child: IndexedStack(index: _currentIndex, children: widgetList)),
    );
  }
}
