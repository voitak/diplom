import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../data/videoplayer_data.dart';

class VideoPlayerService {
  late ChewieController chewieController;
  late VideoPlayerController videoPlayerController;

  //Images by date selected by user
  late DateTimeRange dateRange;

  bool looping = false;
  bool autoplay = false;

  bool isStoragePermissionGranted = false;
  bool isInitialised = false;

  void initChewieController(String path) {
    videoPlayerController = VideoPlayerController.file(File(path));
    chewieController = ChewieController(videoPlayerController: videoPlayerController,
      aspectRatio: 9 / 15,
      autoInitialize: true,
      autoPlay: autoplay,
      looping: looping,
      errorBuilder: (context, errorMessage) {
        return const Center(
          child: Text(
            VideoPlayerData.noVideoFounded,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  //Set new video on video player
  Future<ChewieController> onNewVideoSelected(String path) async {
    //final previousVideoController =  videoPlayerController;
    final previousChewieController = chewieController;
    //final previousVideoController =  VideoPlayerController.file(File(path));
    //final previousCameraController = controller;

    videoPlayerController.dispose();
    videoPlayerController = VideoPlayerController.file(File(path));

    final ChewieController newChewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 9 / 15,
      autoInitialize: true,
      autoPlay: autoplay,
      looping: looping,
      errorBuilder: (context, errorMessage) {
        return const Center(
          child: Text(
            VideoPlayerData.noVideoFounded,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

    // Dispose the previous controller
    previousChewieController.dispose();

    return newChewieController;
  }


  //Get info about storage permission. If not granted then request.
  getStoragePermission() async {
    await Permission.storage.request();
    var status = await Permission.storage.status;

    if (status.isGranted) {
      print('Storage Permission: GRANTED');
      isStoragePermissionGranted = true;
    } else {
      print('Storage Permission: DENIED');
    }
  }

  //Merge images to video
  Future<void> videoMerger(double fps, String path) async {
    print('PATH - $path');
    //-c:v libx264
    String command = '-r $fps -f concat -i $path/images.txt -y $path/out.mp4';
    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('SUCCESS');
      } else if (ReturnCode.isCancel(returnCode)) {
        print('CANCEL'); //

      } else {
        print(
            'ERROR - ${await session}\n ${await session.getFailStackTrace()}'); //
        FFmpegKitConfig.enableLogCallback((log) {
          final message = log.getMessage();
          print(message);
        });
      }
    });
  }
}


