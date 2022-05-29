import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:share_plus/share_plus.dart';

import 'data/videoplayer_data.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({Key? key}) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  final imagesPath = File('${camServ.directoryPhone.path}/images.txt');
  final patternVideo = Glob('${camServ.directoryPhone.path}/*.mp4');

  //final pattern = Glob('${camServ.directoryPhone.path}/*.jpg');

//  Stream<File> search(Directory dir) {
//    return Glob("*.mp4")
//        .list(root: dir.path)
//        .where((entity) => entity is File)
//        .cast<File>();
//  }

//  Future<bool> contains() async {
//    return patternVideo.listSync().isNotEmpty;
//  }

//  void initStorage() async {
//    await vidServ.getStoragePermission();
//    if (mounted) setState(() {});
//  }

  void selectVideo(String path) async {
    await vidServ.onNewVideoSelected(path).then((value) async {
      // Replace with the new controller
      if (mounted) {
        setState(() {
          vidServ.chewieController = value;
        });
      }

      value.addListener(() {
        if (mounted) setState(() {});
      });
    });
  }

  void initVideo() async {
    await vidServ.getStoragePermission();

    if (vidServ.isStoragePermissionGranted) {
      if (patternVideo.listSync().isNotEmpty) {
        setState(() {
          vidServ.isInitialised = true;
        });
        vidServ.initChewieController('${camServ.directoryPhone.path}/out.mp4');
        selectVideo('${camServ.directoryPhone.path}/out.mp4');
      } else {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    // Hide the status bar
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    initVideo();
    super.initState();
  }

  @override
  void dispose() {
    vidServ.chewieController.videoPlayerController.dispose();
    vidServ.chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: vidServ.isStoragePermissionGranted
            ? Column(
                children: [
                  //AspectRatio(
                  //aspectRatio: 1 / (MediaQuery.of(context).size.width / MediaQuery.of(context).size.height),
                  //child:
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          10.0,
                          20.0,
                          10.0,
                          0.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            patternVideo.listSync().isNotEmpty
                                ? AspectRatio(
                                    aspectRatio: 9 / 14,
                                    child: Chewie(
                                      controller: vidServ.chewieController,
                                    )
//                                    VideoItem(
//                                      VideoPlayerController.file(
//                                        File(
//                                            '${camServ.directoryPhone.path}/out.mp4'),
//                                      ),
//                                      false, //looping
//                                      false, //autoplay
//                                    ),
                                    )
                                : AspectRatio(
                                    aspectRatio: 9 / 14,
                                    child: Container(
                                      color: Colors.black,
                                      //margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          VideoPlayerData.noVideoFounded,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            Column(
                              //mainAxisAlignment: MainAxisAlignment.start,
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        VideoPlayerData.imagesSpeed,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: camServ.currentFPSLevel,
                                        min: camServ.minAvailableFPS,
                                        max: camServ.maxAvailableFPS,
                                        activeColor: Colors.black,
                                        inactiveColor: Colors.black26,
                                        onChanged: (value) async {
                                          setState(() {
                                            camServ.currentFPSLevel = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            camServ.currentFPSLevel
                                                    .toStringAsFixed(1) +
                                                'x',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                /*
                                Merge all available images to video
                                 */
                                ElevatedButton.icon(
                                  label: const Text(
                                    VideoPlayerData.mergeVideo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      fontSize: 30,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.call_merge,
                                    size: 30,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                  onPressed: () async {
                                    if (camServ.allFileList.isNotEmpty) {
                                      List<File> allFileList =
                                          camServ.allFileList;

                                      allFileList.sort((a, b) {
                                        int nameA = int.parse(a.path
                                            .split('/')
                                            .last
                                            .split('.')
                                            .first);
                                        int nameB = int.parse(b.path
                                            .split('/')
                                            .last
                                            .split('.')
                                            .first);
                                        return nameA.compareTo(nameB);
                                      });

//                                      final initialDateRange = DateTimeRange(
//                                        start: DateTime.now(),
//                                        end: DateTime.now().add(Duration(hours: 24 * 3)),
//                                      );
                                      final firstDate =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(allFileList.first.path
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .first));
                                      final lastDate =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(allFileList.last.path
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .first));
                                      final newDateRange =
                                          await showDateRangePicker(
                                        context: context,
                                        firstDate: firstDate,
                                        lastDate: lastDate,
                                        //initialDateRange: dateRange ?? initialDateRange,
                                      );

                                      if (newDateRange != null) {
                                        print('DATE DATE DATE - $newDateRange');
                                        var startSelectedTime = newDateRange
                                            .start.millisecondsSinceEpoch;

//                                        int endSelectedTime;
//                                        if (newDateRange.start == newDateRange.end) {
                                        int endSelectedTime = newDateRange.end
                                            .add(const Duration(hours: 24))
                                            .millisecondsSinceEpoch;
//                                        } else {
//                                          endSelectedTime =
//                                              newDateRange.end.millisecondsSinceEpoch;
//                                        }
                                        //endSelectedTime ??= startSelectedTime;
                                        //dateRange = newDateRange;

                                        await imagesPath.writeAsString('');
                                        for (var file in allFileList) {
                                          int checkDate = int.parse(file.path
                                              .split('/')
                                              .last
                                              .split('.')
                                              .first);
                                          if (checkDate >= startSelectedTime &&
                                              checkDate <= endSelectedTime) {
                                            await imagesPath.writeAsString(
                                                'file \'${file.path.split('/').last}\'\n',
                                                mode: FileMode.append);
                                            print(file.path.split('/').last);
                                          }
                                        }

                                        await vidServ.videoMerger(
                                            camServ.currentFPSLevel,
                                            camServ.directoryPhone.path);

                                        print(
                                            'PATH - ${camServ.directoryPhone.path}');
                                        print('MERGER!');

                                        if (vidServ.isInitialised) {
                                          selectVideo(
                                              '${camServ.directoryPhone.path}/out.mp4');
                                        } else {
                                          setState(() {
                                            vidServ.isInitialised = true;
                                          });
                                          vidServ.initChewieController(
                                              '${camServ.directoryPhone.path}/out.mp4');
                                          selectVideo(
                                              '${camServ.directoryPhone.path}/out.mp4');
                                        }
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            VideoPlayerData.noVideoToMerge,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
                                              fontSize: 17,
                                            ),
                                          ),
                                          duration: const Duration(
                                              milliseconds: 1500),
                                          width: 245.0,
                                          // Width of the SnackBar.
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                10.0, // Inner padding for SnackBar content.
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                /*
                                Share video
                                 */
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.share_outlined,
                                    size: 30,
                                  ),
                                  label: const Text(
                                    VideoPlayerData.shareVideo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      fontSize: 30,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                  onPressed: () {
                                    patternVideo.listSync().isNotEmpty
                                        ? Share.shareFiles([
                                            '${camServ.directoryPhone.path}/out.mp4'
                                          ])
                                        : ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                VideoPlayerData.noVideoToShare,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                ),
                                              ),
                                              duration: const Duration(
                                                  milliseconds: 1500),
                                              width: 220.0,
                                              // Width of the SnackBar.
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    10.0, // Inner padding for SnackBar content.
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  //),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(),
                  const Text(
                    VideoPlayerData.deniedPermission,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    onPressed: () {
                      initVideo();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        VideoPlayerData.givePermission,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
