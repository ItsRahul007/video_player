import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_video_player/screens/home.dart';
import 'package:local_video_player/screens/play_video.dart';
import 'package:receive_intent/receive_intent.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? currentVideoPath;
  String? currentVideoName;
  bool openedFromIntent = false;

  @override
  void initState() {
    super.initState();
    _handleIncomingIntent();
  }

  Future<void> _handleIncomingIntent() async {
    final receivedIntent = await ReceiveIntent.getInitialIntent();
    if (!mounted) return;

    if (receivedIntent?.data != null) {
      openedFromIntent = true; // Set flag when opened from intent
      _handleVideo(receivedIntent!.data!);
    }

    ReceiveIntent.receivedIntentStream.listen((Intent? intent) {
      if (intent?.data != null) {
        openedFromIntent = true; // Set flag when opened from intent
        _handleVideo(intent!.data!);
      }
    });
  }

  void _handleVideo(String path) {
    String name = path.split('/').last;
    setState(() {
      currentVideoPath = path;
      currentVideoName = name;
    });

    print("currentVideoPath: $currentVideoPath");
  }

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
                  color: Colors.white,
                ), // Set default text color to white
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
              primaryColor: Colors.transparent,
            ),
            home: PopScope(
              canPop: !openedFromIntent,
              onPopInvoked: (didPop) {
                if (openedFromIntent) {
                  SystemNavigator.pop();
                }
              },
              child: Scaffold(
                body: currentVideoPath != null && currentVideoName != null
                    ? PlayVideo(
                        path: currentVideoPath!,
                        name: currentVideoName!,
                        isContent: true,
                      )
                    : const Home(),
              ),
            ),
          );
        });
  }
}
