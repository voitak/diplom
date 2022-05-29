import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

class CameraService {
  CameraController? controller;

  //Recent image
  File? imageFile;
  //All images
  List<File> allFileList = [];
  //Phone directory
  late Directory directoryPhone;

  //Understand whether the camera is initialized and refresh the UI accordingly
  bool isCameraInitialized = false;

  //Rear camera - true, front camera - false
  bool isRearCameraSelected = false;
  //Flash on - true, flash off - false
  bool isFlashSelected = false;
  //Mask on - true, mask off - false
  bool isFaceMaskSelected = false;
  //Grid lines on - true, grid lines off - false
  bool isGridSelected = false;

  //Reverse sort - true, default sort - false
  bool isReverseSort = false;

  bool isCameraPermissionGranted = false;
  //bool isStoragePermissionGranted = false;

  //Zoom
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentZoomLevel = 1.0;

  //Image FPS
  double minAvailableFPS = 0.5;
  double maxAvailableFPS = 30.0;
  double currentFPSLevel = 1.0;

  //Resolution
  ResolutionPreset currentResolutionPreset = ResolutionPreset.ultraHigh;


  //Get info about camera permission. If not granted then request.
  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      print('Camera Permission: GRANTED');
      isCameraPermissionGranted = true;
    } else {
      print('Camera Permission: DENIED');
    }
  }

  //Default sort of images
  void sort() {
    allFileList.sort((a, b) {
      int nameA = int.parse(a.path.split('/').last.split('.').first);
      int nameB = int.parse(b.path.split('/').last.split('.').first);
      return nameA.compareTo(nameB);
    });
  }

  //Reverse sort of images
  void reverseSort() {
    allFileList.sort((a, b) {
      int nameA = int.parse(a.path.split('/').last.split('.').first);
      int nameB = int.parse(b.path.split('/').last.split('.').first);
      return -1 * nameA.compareTo(nameB);
    });
  }

  //Getting images and refresh recent image
  Future<bool> refreshAlreadyCapturedImages() async {
    directoryPhone.createSync(recursive: true);
    List<FileSystemEntity>? fileList = await directoryPhone.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    for (var file in fileList) {
      if (file.path.contains('.jpg')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    }

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];

      imageFile = File('${directoryPhone.path}/$recentFileName');
      //allFileList.sort();
    } else {
      imageFile = null;
    }

    return fileNames.isNotEmpty;
  }


  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  void resetCameraValues() async {
    currentZoomLevel = 1.0;
  }

  //When user selected another camera
  Future<CameraController> onNewCameraSelected(
      CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    resetCameraValues();

    return cameraController;
  }

  initCameraController(CameraController cameraController) async {
    // Initialize controller
    try {
      await cameraController.initialize();
      //Set zoom level
      await Future.wait([
        cameraController
            .getMaxZoomLevel()
            .then((value) => maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
  }

  //Setting focus on camera
  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  //Take and save image to phone directory
  takeAndSaveImage() async {
    XFile? rawImage = await takePicture();
    List<int> imageBytes = await rawImage!.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);
    img.Image fixedImage = img.flipHorizontal(originalImage!);

    File imageFileBeforeFlip = File(rawImage.path);

//    File imageFile = await imageFileBeforeFlip.writeAsBytes(
//      img.encodeJpg(fixedImage),
//      flush: true,
//    );

    File imageFile;
    isRearCameraSelected
        ? imageFile = imageFileBeforeFlip
        : imageFile = await imageFileBeforeFlip.writeAsBytes(
            img.encodeJpg(fixedImage),
            flush: true,
          );

    //DateTime now = DateTime.now();
    //String formattedDate = 'img-${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}-${now.hour.toString().padLeft(2,'0')}-${now.minute.toString().padLeft(2,'0')}';
    //.millisecondsSinceEpoch;

    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    directory?.createSync(recursive: true);

    String fileFormat = imageFile.path.split('.').last;

    String fileName = imageFile.path.split(Platform.pathSeparator).last;

    print("FILENAME - $fileName\n");
    print("FILENAME 2 - $currentUnix\n");
    print("FILEFORMAT - $fileFormat\n");

    await imageFile.copy(
      '${directory?.path}/$currentUnix.$fileFormat',
    );
  }
}
