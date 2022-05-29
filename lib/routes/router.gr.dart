// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

import '../camera/camera_page.dart' as _i3;
import '../captures/captures_page.dart' as _i2;
import '../home_page.dart' as _i1;
import '../notification/notification_page.dart' as _i4;
import '../videoplayer/video_player_page.dart' as _i5;

class AppRouter extends _i6.RootStackRouter {
  AppRouter([_i7.GlobalKey<_i7.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    HomeRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.HomePage());
    },
    CapturesRouter.name: (routeData) {
      final args = routeData.argsAs<CapturesRouterArgs>(
          orElse: () => const CapturesRouterArgs());
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: _i2.CapturesPage(key: args.key));
    },
    CameraRouter.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.CameraPage());
    },
    NotificationPage.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.NotificationPage());
    },
    VideoPlayerRouter.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.VideoPlayer());
    }
  };

  @override
  List<_i6.RouteConfig> get routes => [
        _i6.RouteConfig(HomeRoute.name, path: '/', children: [
          _i6.RouteConfig(CapturesRouter.name,
              path: 'captures', parent: HomeRoute.name),
          _i6.RouteConfig(CameraRouter.name,
              path: 'camera', parent: HomeRoute.name),
          _i6.RouteConfig(NotificationPage.name,
              path: 'notification', parent: HomeRoute.name),
          _i6.RouteConfig(VideoPlayerRouter.name,
              path: 'video', parent: HomeRoute.name)
        ])
      ];
}

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i6.PageRouteInfo<void> {
  const HomeRoute({List<_i6.PageRouteInfo>? children})
      : super(HomeRoute.name, path: '/', initialChildren: children);

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i2.CapturesPage]
class CapturesRouter extends _i6.PageRouteInfo<CapturesRouterArgs> {
  CapturesRouter({_i7.Key? key})
      : super(CapturesRouter.name,
            path: 'captures', args: CapturesRouterArgs(key: key));

  static const String name = 'CapturesRouter';
}

class CapturesRouterArgs {
  const CapturesRouterArgs({this.key});

  final _i7.Key? key;

  @override
  String toString() {
    return 'CapturesRouterArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.CameraPage]
class CameraRouter extends _i6.PageRouteInfo<void> {
  const CameraRouter() : super(CameraRouter.name, path: 'camera');

  static const String name = 'CameraRouter';
}

/// generated route for
/// [_i4.NotificationPage]
class NotificationPage extends _i6.PageRouteInfo<void> {
  const NotificationPage() : super(NotificationPage.name, path: 'notification');

  static const String name = 'NotificationPage';
}

/// generated route for
/// [_i5.VideoPlayer]
class VideoPlayerRouter extends _i6.PageRouteInfo<void> {
  const VideoPlayerRouter() : super(VideoPlayerRouter.name, path: 'video');

  static const String name = 'VideoPlayerRouter';
}
