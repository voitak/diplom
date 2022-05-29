import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_app/routes/router.gr.dart';
import 'package:flutter_app/captures/data/captures_data.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../captures/widgets/TestTile.dart';
import '../main.dart';

class CapturesPage extends StatefulWidget {
  CapturesPage({Key? key}) : super(key: key);

  @override
  State<CapturesPage> createState() => _CapturesPageState();
}

class _CapturesPageState extends State<CapturesPage> {
  refreshImages() async {
    await camServ.refreshAlreadyCapturedImages().then((value) {
      if (value) {
        camServ.isReverseSort ? camServ.reverseSort() : camServ.sort();
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    refreshImages();
    final tabsRouter = context.tabsRouter;
    tabsRouter.addListener(() {
      if (tabsRouter.activeIndex == 0) {
        refreshImages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              title: const Text(
                CapturesData.captures,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              backgroundColor: Colors.black,
              actions: [
                /*
                Select sort filter
                 */
                IconButton(
                  onPressed: () {
                    setState(() {
                      camServ.isReverseSort = !camServ.isReverseSort;
                    });
                    camServ.isReverseSort
                        ? camServ.reverseSort()
                        : camServ.sort();
                  },
                  icon: camServ.isReverseSort
                      ? Transform.rotate(
                          angle: 180 * 3.1415926 / 180,
                          child: const Icon(
                            Icons.filter_list,
                            size: 30,
                          ))
                      : const Icon(
                          Icons.filter_list,
                          size: 30,
                        ),
                )
              ],
            ),
            Visibility(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20.0,
                  20.0,
                  20.0,
                  0.0,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      //Get time of created notification
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'No photos yet founded.\n Tap on ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            WidgetSpan(child: Icon(Icons.camera_alt)),
                            TextSpan(
                              text: ' to make one.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              visible: camServ.allFileList.isEmpty,
            ),
            /*
            Show all available images
             */
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: List.generate(camServ.allFileList.length, (index) {
                return FocusedMenuHolder(
                    menuWidth: MediaQuery.of(context).size.width * 0.4,
                    animateMenuItems: false,
                    duration: const Duration(milliseconds: 200),
                    child: TestTile(
                      index,
                    ),
                    onPressed: () {},
                    menuItems: [
                      /*
                      Get taken time of selected image
                       */
                      FocusedMenuItem(
                        title: Text(
                          DateFormat('dd/MM/yyyy, HH:mm')
                              .format(DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(camServ.allFileList[index].path
                                      .split('/')
                                      .last
                                      .split('.')
                                      .first)))
                              .toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
                        onPressed: () {},
                      ),
                      /*
                      Share selected image
                       */
                      FocusedMenuItem(
                        title: const Text(CapturesData.share),
                        trailingIcon: const Icon(
                          Icons.share,
                        ),
                        onPressed: () {
                          Share.shareFiles(
                              [camServ.allFileList[index].path.toString()]);
                        },
                      ),
                      /*
                      Delete selected image
                       */
                      FocusedMenuItem(
                          title: const Text(CapturesData.delete),
                          trailingIcon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              camServ.allFileList[index].delete();
                              camServ.allFileList
                                  .remove(camServ.allFileList[index]);
                              if (camServ.allFileList.isNotEmpty) {
                                camServ.isReverseSort
                                    ? camServ.imageFile =
                                        camServ.allFileList.first
                                    : camServ.imageFile =
                                        camServ.allFileList.last;
                              } else {
                                camServ.imageFile = null;
                              }
                            });
                          }),
                    ]);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
