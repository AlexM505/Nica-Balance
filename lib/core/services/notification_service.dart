import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Inicializa los ajustes de notificación para Android e iOS
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Managua')); 
   
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize( settings: initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'Recordatorios Diarios',
      description: 'Canal para recordar registrar los gastos diarios',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // ─── CANAL 2: ALERTAS DE PRESUPUESTOS (NUEVO) ───
    const AndroidNotificationChannel budgetChannel = AndroidNotificationChannel(
      'budget_alert_channel',
      'Alertas de Presupuestos',
      description: 'Canal para notificar advertencias de límites y sobregiros de presupuestos',
      importance: Importance.max, // Máxima importancia para desplegar el Banner superior (Heads-up)
      playSound: true,
      enableVibration: true,
    );

    // await _notificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //       AndroidFlutterLocalNotificationsPlugin
    //     >()
    //     ?.createNotificationChannel(channel);

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
      await androidImplementation.createNotificationChannel(budgetChannel); // Registramos el nuevo canal
    }
  }

  ///Dispara una alerta push instantánea (Heads-up) en tiempo real
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'budget_alert_channel',
      'Alertas de Presupuestos',
      channelDescription: 'Canal para notificar advertencias de límites y sobregiros de presupuestos',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true, // Fuerza a que se muestre en iOS aunque la app esté abierta
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  /// Programa una notificación que se repetirá todos los días a una hora específica
  static Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await cancelDailyReminder();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Recordatorios Diarios',
      channelDescription: 'Canal para recordar registrar los gastos diarios',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id: 100,
      title: '¿Olvidaste registrar tus gastos?',
      body: 'Mantén tus finanzas al día. Te toma menos de un minuto registrar tus movimientos de hoy.',
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancela de forma definitiva el recordatorio diario
  static Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(id:100);
  }

  /// Calcula la próxima ocurrencia exacta de la hora solicitada
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}