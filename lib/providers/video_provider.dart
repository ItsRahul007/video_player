import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoFile {
  final File file;
  final String path;
  final String name;
  final DateTime modified;

  VideoFile(
      {required this.file,
      required this.path,
      required this.name,
      required this.modified});
}

class Folders {
  final String folderName;
  final String folderPath;
  final List<VideoFile> videoFiles;

  Folders({
    required this.folderName,
    required this.folderPath,
    required this.videoFiles,
  });
}

class VideoProviderState {
  final bool isLoading;
  final List<VideoFile> videoFiles;
  final List<Folders> videoFolders;

  VideoProviderState({
    required this.isLoading,
    required this.videoFiles,
    required this.videoFolders,
  });

  VideoProviderState copyWith(
      {bool? isLoading,
      List<VideoFile>? videoFiles,
      List<Folders>? videoFolders}) {
    return VideoProviderState(
        isLoading: isLoading ?? this.isLoading,
        videoFiles: videoFiles ?? this.videoFiles,
        videoFolders: videoFolders ?? this.videoFolders);
  }
}

class VideoProvider extends StateNotifier<VideoProviderState> {
  VideoProvider()
      : super(VideoProviderState(
            isLoading: false, videoFiles: [], videoFolders: []));

  Future<void> getAllVideos() async {
    state = state.copyWith(isLoading: true);
    try {
      // Get the root directory of the device
      Directory rootDir = Directory('/storage/emulated/0');
      final videos = await _scanDirectory(rootDir);
      state = state.copyWith(videoFiles: videos);
    } catch (e) {
      print('Error fetching videos: $e');
    }

    state = state.copyWith(isLoading: false);
  }

  Future<List<VideoFile>> _scanDirectory(Directory directory) async {
    List<VideoFile> videoFiles = [];
    try {
      List<FileSystemEntity> entities = directory.listSync();
      for (var entity in entities) {
        if (entity is Directory) {
          if (!entity.path.contains('/Android/') &&
              !entity.path.split('/').last.startsWith('.')) {
            videoFiles.addAll(await _scanDirectory(entity));
          }
        } else if (entity is File) {
          String path = entity.path.toLowerCase();
          if (path.endsWith('.mp4') ||
              path.endsWith('.mkv') ||
              path.endsWith('.mov') ||
              path.endsWith('.avi')) {
            VideoFile video = VideoFile(
                file: entity,
                path: path,
                name: path.split("/").last,
                modified: entity.lastModifiedSync());

            videoFiles.add(video);
            debugPrint("video path: $path");
          }
        }
      }
    } catch (e) {
      debugPrint('Skipping directory: ${directory.path}');
    }
    return videoFiles;
  }

  void init() async {
    await getAllVideos();
  }
}

final videoProvider =
    StateNotifierProvider<VideoProvider, VideoProviderState>((ref) {
  final controller = VideoProvider();
  controller.init();
  return controller;
});
