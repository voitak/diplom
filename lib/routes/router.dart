import 'package:auto_route/auto_route.dart';
import 'package:flutter_app/camera/camera_page.dart';
import 'package:flutter_app/captures/captures_page.dart';
import 'package:flutter_app/home_page.dart';
import 'package:flutter_app/notification/notification_page.dart';
import 'package:flutter_app/videoplayer/video_player_page.dart';



//flutter pub run build_runner build --delete-conflicting-outputs
@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AutoRoute(path: '/', page: HomePage, children: [
      AutoRoute(
        path: 'captures',
        name: 'CapturesRouter',
        page: CapturesPage,
      ),
      AutoRoute(
        path: 'camera',
        name: 'CameraRouter',
        page: CameraPage,
      ),
      AutoRoute(
        path: 'notification',
        name: 'NotificationPage',
        page: NotificationPage,
      ),
      AutoRoute(
        path: 'video',
        name: 'VideoPlayerRouter',
        page: VideoPlayer,
      )
    ]),
  ],
)
class $AppRouter {}
