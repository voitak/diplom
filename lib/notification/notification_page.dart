import 'dart:io';
//import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/notification/utils/notification_service.dart';

import 'data/notification_data.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isNotificationPermissionGranted = false;
  bool isSwitched = false;
  String time = 'NaN';

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      setState(() {
        isNotificationPermissionGranted = isAllowed;
      });
    });

    AwesomeNotifications().actionStream.listen(
      (notification) {
        if (notification.channelKey == 'schedule_channel' && Platform.isIOS) {
          AwesomeNotifications().getGlobalBadgeCounter().then(
                (value) =>
                    AwesomeNotifications().setGlobalBadgeCounter(value - 1),
              );
        }
      },
    );

    //Get info about created notification and time when it was set
    AwesomeNotifications().listScheduledNotifications().then((value) {
      var list = value.toList();
      if (list.isNotEmpty) {
        for (var test in list) {
          var parsedMap = test.schedule?.toMap();
          if (parsedMap!.isNotEmpty) {
            String hour = parsedMap['hour'].toString().padLeft(2, '0');
            String minute = parsedMap['minute'].toString().padLeft(2, '0');

            setState(() {
              time = hour + ':' + minute;
            });
          }
        }
        setState(() {
          isSwitched = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isNotificationPermissionGranted
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: const Text(
                    NotificationData.notificationAppBar,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  backgroundColor: Colors.black,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20.0,
                    10.0,
                    20.0,
                    0.0,
                  ),
                  child: Row(
                    /*
              Set on/aff notification
               */
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        NotificationData.notificationInfo,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Switch(
                        value: isSwitched,
                        onChanged: (value) async {
                          if (value) {
                            var list = await AwesomeNotifications()
                                .listScheduledNotifications();
                            for (var test in list) {
                              var parsedMap = test.schedule?.toMap();
                              if (parsedMap!.isNotEmpty) {
                                String hour = parsedMap['hour']
                                    .toString()
                                    .padLeft(2, '0');
                                String minute = parsedMap['minute']
                                    .toString()
                                    .padLeft(2, '0');

                                setState(() {
                                  time = hour + ':' + minute;
                                });
                                print('TIME - $time');
                              }
                            }
                          } else {
                            cancelScheduledNotifications();
                            setState(() {
                              time = 'NaN';
                            });
                          }
                          setState(() {
                            isSwitched = value;
                          });
                        },
                        activeTrackColor: Colors.black26,
                        activeColor: Colors.black,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Get time of created notification
                        Text(
                          'Daily notification set on: $time',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        /*
                  Create daily reminder on selected time
                   */
                        TextButton(
                          onPressed: () async {
                            NotificationTime? pickedSchedule =
                                await pickSchedule(context);

                            if (pickedSchedule != null) {
                              cancelScheduledNotifications();
                              createReminderNotification(pickedSchedule);
                              String hour = pickedSchedule.timeOfDay.hour
                                  .toString()
                                  .padLeft(2, '0');
                              String minute = pickedSchedule.timeOfDay.minute
                                  .toString()
                                  .padLeft(2, '0');

                              setState(() {
                                time = hour + ':' + minute;
                              });
                            }
                          },
                          child: const Text(
                            NotificationData.createNotificationInfo,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  visible: isSwitched,
                ),
//          Column(
//            children: [
//              TextButton(
//                onPressed: () async {
//                  NotificationTime? pickedSchedule =
//                      await pickSchedule(context);
//
//                  if (pickedSchedule != null) {
//                    cancelScheduledNotifications();
//                    createReminderNotification(pickedSchedule);
//                  }
//                },
//                child: const Text(
//                  'Create notification',
//                  style: TextStyle(
//                    color: Colors.teal,
//                    fontSize: 18,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//              ),
//
//              TextButton(
//                onPressed: () => cancelScheduledNotifications(),
//                child: const Text(
//                  'Cancel notification',
//                  style: TextStyle(
//                    color: Colors.teal,
//                    fontSize: 18,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//              ),
//
//              TextButton(
//                onPressed: () async {
//                  var list =
//                      await AwesomeNotifications().listScheduledNotifications();
//                  list.toList();
//                  for (var test in list) {
//                    var parsedMap = test.schedule?.toMap();
//                    ScaffoldMessenger.of(context).showSnackBar(
//                      SnackBar(
//                        content: Text(parsedMap!['hour'].toString() +
//                            ':' +
//                            parsedMap['minute'].toString()),
//                      ),
//                    );
//                  }
//                },
//                child: const Text(
//                  'Get info',
//                  style: TextStyle(
//                    color: Colors.teal,
//                    fontSize: 18,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//              )
//            ],
//          ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(),
                const Text(
                  NotificationData.deniedPermission,
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
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(NotificationData.dialogTitle),
                        content: const Text(NotificationData.dialogText),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              NotificationData.dialogDeny,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => AwesomeNotifications()
                                .requestPermissionToSendNotifications()
                                .then((_) {
                              AwesomeNotifications()
                                  .isNotificationAllowed()
                                  .then((isAllowed) {
                                setState(() {
                                  isNotificationPermissionGranted = isAllowed;
                                });
                              });
                              Navigator.pop(context);
                            }),
                            child: const Text(
                              NotificationData.dialogAllow,
                              style: TextStyle(
                                color: Colors.teal,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      NotificationData.givePermission,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
