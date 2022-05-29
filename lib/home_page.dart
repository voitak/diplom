import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/routes/router.gr.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: [
        //PostsRouter(),
        CapturesRouter(),
        CameraRouter(),
        NotificationPage(),
        VideoPlayerRouter()
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return SalomonBottomBar(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          selectedItemColor: Colors.black,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.person,
                size: 30,
              ),
              title: Text(''),
              //Text('${tabsRouter.activeIndex}'),
            ),
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.camera_alt,
                size: 30,
              ),
              title: Text(''),
            ),
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.alarm_add_outlined,
                size: 30,
              ),
              title: Text(''),
            ),
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.play_arrow,
                size: 30,
              ),
              title: Text(''),
            ),
          ],
        );
      },
    );
  }
}
