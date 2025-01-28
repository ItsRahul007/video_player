import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoFile {
  final File file;
  final String path;
  final String name;
  final DateTime modified;

  VideoFile({
    required this.file,
    required this.path,
    required this.name,
    required this.modified,
  });

  // Add equality operator to help prevent duplicates
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoFile && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
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

  VideoProviderState copyWith({
    bool? isLoading,
    List<VideoFile>? videoFiles,
    List<Folders>? videoFolders,
  }) {
    return VideoProviderState(
      isLoading: isLoading ?? this.isLoading,
      videoFiles: videoFiles ?? this.videoFiles,
      videoFolders: videoFolders ?? this.videoFolders,
    );
  }
}

class VideoProvider extends StateNotifier<VideoProviderState> {
  VideoProvider()
      : super(VideoProviderState(
          isLoading: false,
          videoFiles: [],
          videoFolders: [],
        ));

  Future<void> getAllVideos() async {
    state = state.copyWith(isLoading: true);
    try {
      Directory rootDir = Directory('/storage/emulated/0');
      Map<String, Folders> foldersMap = {};
      Set<String> processedPaths = {}; // Track processed video paths

      await _scanDirectory(rootDir, foldersMap, processedPaths);

      List<Folders> foldersList = foldersMap.values.toList();
      // Create unified video list from folders without duplicates
      List<VideoFile> allVideos = foldersList
          .expand((folder) => folder.videoFiles)
          .toSet() // Remove duplicates using equality operator
          .toList();

      state = state.copyWith(
        videoFolders: foldersList,
        videoFiles: allVideos,
        isLoading: false,
      );
    } catch (e) {
      print('Error fetching videos: $e');
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> _scanDirectory(
    Directory directory,
    Map<String, Folders> foldersMap,
    Set<String> processedPaths,
  ) async {
    try {
      List<FileSystemEntity> entities = directory.listSync();
      for (var entity in entities) {
        if (entity is Directory) {
          if (!entity.path.contains('/Android/') &&
              !entity.path.split('/').last.startsWith('.')) {
            await _scanDirectory(entity, foldersMap, processedPaths);
          }
        } else if (entity is File) {
          String path = entity.path.toLowerCase();

          // Skip if already processed
          if (processedPaths.contains(path)) continue;

          if (path.endsWith('.mp4') ||
              path.endsWith('.mkv') ||
              path.endsWith('.mov') ||
              path.endsWith('.avi')) {
            VideoFile video = VideoFile(
              file: entity,
              path: path,
              name: path.split("/").last,
              modified: entity.lastModifiedSync(),
            );

            String directoryPath = entity.parent.path;
            if (!foldersMap.containsKey(directoryPath)) {
              foldersMap[directoryPath] = Folders(
                folderName: directoryPath.split("/").last,
                folderPath: directoryPath,
                videoFiles: [],
              );
            }

            foldersMap[directoryPath]!.videoFiles.add(video);
            processedPaths.add(path); // Mark as processed
          }
        }
      }
    } catch (e) {
      debugPrint('Skipping directory: ${directory.path}');
    }
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
