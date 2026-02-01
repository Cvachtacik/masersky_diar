import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifikacie {
  Notifikacie._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _inicializovane = false;

  static Future<void> inicializuj() async {
    if (_inicializovane) return;

    tz.initializeTimeZones();
    final lokalnaZonaInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(lokalnaZonaInfo.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: ios,
    );

    // ✅ flutter_local_notifications v20: používa "settings:"
    await _plugin.initialize(
      settings: initSettings,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _inicializovane = true;
  }

  static int noveIdNotifikacie() {
    final rnd = Random();
    return rnd.nextInt(1 << 30);
  }

  static Future<void> naplanujNotifikaciu({
    required int idNotifikacie,
    required DateTime casNotifikacie,
    required String titulok,
    required String text,
  }) async {
    await inicializuj();
    if (casNotifikacie.isBefore(DateTime.now())) return;

    final detaily = NotificationDetails(
      android: AndroidNotificationDetails(
        'terminy_kanal',
        'Termíny',
        channelDescription: 'Pripomienky na masážne termíny',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    final tzCas = tz.TZDateTime.from(casNotifikacie, tz.local);

    await _plugin.zonedSchedule(
      id: idNotifikacie,
      title: titulok,
      body: text,
      scheduledDate: tzCas,
      notificationDetails: detaily,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> zrusNotifikaciu(int idNotifikacie) async {
    await inicializuj();
    await _plugin.cancel(id: idNotifikacie);
  }
}
