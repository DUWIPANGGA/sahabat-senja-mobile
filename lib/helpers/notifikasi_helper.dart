import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifikasiHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(settings);
  }

  static Future showNotif(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'jadwal_obat_channel',
      'Jadwal Obat',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notifDetails,
    );
  }
}
