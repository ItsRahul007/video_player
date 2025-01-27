import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/screens/home.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(427, 950),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            title: 'Video Player',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(
                      color: Colors.white), // Set default text color to white
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey,
                ),
                useMaterial3: true,
                primaryColor: Colors.transparent),
            home: const Home(),
          );
        });
  }
}
