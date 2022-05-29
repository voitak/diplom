import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/routes/router.gr.dart';
import 'package:camera/camera.dart';
import 'package:flutter_app/videoplayer/utils/videoplayer_service.dart';
import 'package:path_provider/path_provider.dart';

import 'camera/utils/camera_service.dart';

List<CameraDescription> cameras = [];
//Camera Service Initialise
CameraService camServ = CameraService();
//Video Service Initialise
VideoPlayerService vidServ = VideoPlayerService();

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    //Initialising scheduled notification channel
    AwesomeNotifications().initialize(
      '',
      [
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled Notifications',
          channelDescription: '',
          importance: NotificationImportance.High,
        ),
      ],
    );
    //Getting cameras
    cameras = await availableCameras();
    //Getting phone directory
    camServ.directoryPhone = (Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory())!;
  } on CameraException catch (e) {
    print('ERROR: $e');
  }
  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  AppWidget({Key? key}) : super(key: key);
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Memories',
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
