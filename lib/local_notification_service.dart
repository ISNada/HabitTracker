import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init({bool initScheduled = false}) async {
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneName!));

    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
   // final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android,/*iOS: iOS*/);

    await _notifications.initialize(
        settings,
        onSelectNotification: (((payload) async {

        })
        ));
  }

  static Future _notificationsDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
          '123',
          'Adati',
          channelDescription: 'Remind about habit',
          importance: Importance.max
      ),
     // iOS: IOSNotificationDetails(),
    );
  }

  static Future cancelNotification({
    int id = 0,
  }) async => _notifications.cancel(id);

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload
  }) async => _notifications.show(id, title, body, await _notificationsDetails());

  static Future showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime sechuledDate,
    required List<int> days
  }) async => _notifications.zonedSchedule(id, title, body, _schduleWeekly(Time(sechuledDate.hour,sechuledDate.minute),days: days),await _notificationsDetails(),payload: payload,
      androidAllowWhileIdle: true,   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime).then((value) => {

  });

  static tz.TZDateTime _schduleDaily(Time time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime schduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if(schduleDate.isBefore(now)) {
      schduleDate = schduleDate.add(Duration(days: 1));
    }
    return schduleDate;
  }

  static tz.TZDateTime _schduleWeekly(Time time,{required List<int> days}) {

    tz.TZDateTime schduleDate = _schduleDaily(time);

    while(!days.contains(schduleDate.weekday)) {
      schduleDate = schduleDate.add(Duration(days: 1));
    }

    return schduleDate;
  }
}