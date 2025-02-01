import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({super.key, required this.path});
  final String path;

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
  }

  //TODO: first make a method to check the video width. And call this method in init state
  //TODO: based on the video width show the video on landscape or in protrate

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox());
  }
}
