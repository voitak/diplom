import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

class NotificationTime {
  final TimeOfDay timeOfDay;

  NotificationTime({
    required this.timeOfDay,
  });
}

//Pick new time for notification
Future<NotificationTime?> pickSchedule(BuildContext context) async {
  TimeOfDay? timeOfDay;
  DateTime now = DateTime.now();

  timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(
          const Duration(minutes: 1),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
            ),
          ),
          child: child!,
        );
      });

  if (timeOfDay != null) {
    return NotificationTime(timeOfDay: timeOfDay);
  }

  return null;
}

//Create daily reminder
Future<void> createReminderNotification(
    NotificationTime notificationSchedule) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'scheduled_channel',
      title: 'Time for selfie',
      body: 'It\'s daily reminder to take selfie',
      notificationLayout: NotificationLayout.Default,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'MARK_DONE',
        label: 'Mark Done',
      ),
    ],
    schedule: NotificationCalendar(
      hour: notificationSchedule.timeOfDay.hour,
      minute: notificationSchedule.timeOfDay.minute,
      second: 0,
      millisecond: 0,
      repeats: true,
    ),
  );
}

//Cancel created daily reminder
Future<void> cancelScheduledNotifications() async {
  await AwesomeNotifications().cancelAllSchedules();
}
