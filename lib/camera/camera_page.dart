import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/camera/data/camera_data.dart';
//import 'package:image/image.dart' as img;

import '../main.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {

  //When user selected another camera
  void selectCamera(CameraDescription cameraDescription) async {
    await camServ.onNewCameraSelected(cameraDescription).then((value) async {
      // Replace with the new controller
      if (mounted) {
        setState(() {
          camServ.controller = value;
        });
      }

      //Refresh page
      value.addListener(() {
        if (mounted) setState(() {});
      });

      //Setting default values
      await camServ.initCameraController(value);

      // Update the Boolean
      if (mounted) {
        setState(() {
          camServ.isCameraInitialized = camServ.controller!.value.isInitialized;
        });
      }
    });
  }

  //Refresh list of images when new photo was taken
  refreshImages() async {
    await camServ.refreshAlreadyCapturedImages().then((value) {
      if (value) {
        setState(() {});
      }
    });
  }

  //Initialise new camera
  void initCamera() async {
    await camServ.getPermissionStatus();

    /*
  1) Initializing a new camera controller,
      which is needed to start the camera screen
  2) Disposing the previous controller and replacing it with a new controller
      that has different properties when the user flips the camera view
   */
    if (camServ.isCameraPermissionGranted) {
      selectCamera(cameras[1]);
      await refreshImages();
    }
  }

  takeAndSaveImage() async {
    await camServ.takeAndSaveImage();
    await refreshImages();
  }

  @override
  void initState() {
    // Hide the status bar
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    initCamera();
    super.initState();
  }

  /*
  Release the memory when the camera is not active
   */
  @override
  void dispose() {
    camServ.controller?.dispose();
    super.dispose();
  }

  /*
  WidgetsBindingObserver give you to manage the lifecycle changes.
  Running the camera is considered a memory-hungry task,
  so we need to handle freeing up the memory resources, and when that occurs.
   */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = camServ.controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      selectCamera(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: camServ.isCameraPermissionGranted
            ? camServ.isCameraInitialized
                ? Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1 / camServ.controller!.value.aspectRatio,
                        child: Stack(
                          children: [
                            /*
                            Camera preview
                            */
                            CameraPreview(
                              camServ.controller!,
                              child: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints constraints) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (details) => camServ
                                      .onViewFinderTap(details, constraints),
                                );
                              }),
                            ),
                            /*
                            Photo mask
                            */
                            Visibility(
                              child: Center(
                                child: (camServ.imageFile != null)
                                    ? Image.file(
                                        camServ.imageFile as File,
                                        color: Colors.white.withOpacity(0.5),
                                        colorBlendMode: BlendMode.modulate,
                                        //width: 150,
                                        //height: 150,
                                      )
                                    : Container(),
                              ),
                              visible: camServ.isFaceMaskSelected,
                            ),
                            /*
                            Grid lines
                            */
                            Visibility(
                              child: Center(
                                child:
                                //Scaffold(
                                  //body:
                                  GridPaper(
                                    child: Container(),
                                    color: Colors.white,
                                    interval: 130,
                                    divisions: 1,
                                    subdivisions: 1,
                                  ),
                                //),
                              ),
                              visible: camServ.isGridSelected,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                20.0,
                                16.0,
                                20.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  /*
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, top: 16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  */
                                  //ZOOM
                                  Row(
                                    children: [
                                      /*
                                      Zoom control slider
                                      */
                                      Expanded(
                                        child: Slider(
                                          value: camServ.currentZoomLevel,
                                          min: camServ.minAvailableZoom,
                                          max: camServ.maxAvailableZoom,
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.white30,
                                          onChanged: (value) async {
                                            setState(() {
                                              camServ.currentZoomLevel = value;
                                            });
                                            await camServ.controller!
                                                .setZoomLevel(value);
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              camServ.currentZoomLevel
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /*
                                      Select another camera
                                      */
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            camServ.isCameraInitialized = false;
                                          });
                                          selectCamera(cameras[
                                              camServ.isRearCameraSelected
                                                  ? 1
                                                  : 0]);
                                          setState(() {
                                            camServ.isRearCameraSelected =
                                                !camServ.isRearCameraSelected;
                                          });
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              color: Colors.black38,
                                              size: 60,
                                            ),
                                            Icon(
                                              camServ.isRearCameraSelected
                                                  ? Icons.camera_front
                                                  : Icons.camera_rear,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        /*
                                        Select flash mode
                                        */
                                        onTap: () async {
                                          setState(() {
                                            camServ.isFlashSelected =
                                                !camServ.isFlashSelected;
                                          });
                                          camServ.isFlashSelected
                                              ? await camServ.controller!
                                                  .setFlashMode(
                                                  FlashMode.always,
                                                )
                                              : await camServ.controller!
                                                  .setFlashMode(
                                                  FlashMode.off,
                                                );
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            camServ.isRearCameraSelected
                                                ? Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.circle,
                                                        color: Colors.black38,
                                                        size: 60,
                                                      ),
                                                      Icon(
                                                        camServ.isFlashSelected
                                                            ? Icons.flash_on
                                                            : Icons.flash_off,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(
                                                    width: 60,
                                                  ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        /*
                                        Take photo
                                        */
                                        onTap: takeAndSaveImage,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              color: Colors.white38,
                                              size: 80,
                                            ),
                                            const Icon(
                                              Icons.circle,
                                              color: Colors.white,
                                              size: 65,
                                            ),
                                            Container(),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        /*
                                        Set mask mode
                                        */
                                        onTap: () {
                                          setState(() {
                                            camServ.isFaceMaskSelected =
                                                !camServ.isFaceMaskSelected;
                                          });
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              color: Colors.black38,
                                              size: 60,
                                            ),
                                            Icon(
                                              Icons.face,
                                              color: camServ.isFaceMaskSelected
                                                  ? Colors.blueGrey
                                                  : Colors.white,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        /*
                                        Set grid lines
                                        */
                                        onTap: () {
                                          setState(() {
                                            camServ.isGridSelected =
                                                !camServ.isGridSelected;
                                          });
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              color: Colors.black38,
                                              size: 60,
                                            ),
                                            Icon(
                                              Icons.grid_on_rounded,
                                              color: camServ.isGridSelected
                                                  ? Colors.blueGrey
                                                  : Colors.white,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    /*
                    Before camera initialisation
                    */
                    child: Text(
                      CameraData.loading,
                      style: TextStyle(color: Colors.black),
                    ),
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /*
                  Working with camera permission
                  */
                  Row(),
                  const Text(
                    CameraData.deniedPermission,
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
                      initCamera();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        CameraData.givePermission,
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
