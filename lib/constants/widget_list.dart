import 'package:flutter/material.dart';
import 'package:video_player/screens/all_videos.dart';
import 'package:video_player/screens/folders.dart';

const List<Widget> widgetList = [
  AllVideos(),
  Folders(),
];

const List<String> monthAbbreviations = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

const List<double> speedList = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
