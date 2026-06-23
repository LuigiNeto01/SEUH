import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Gerencia as notificações locais agendadas do aplicativo Seuh.
///
/// Envia uma notificação diária à meia-noite lembrando o usuário de
/// revelar sua penitência do dia.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'pkb_daily';
  static const _notifId = 0;

  /// Inicializa o plugin de notificações, solicita permissão e agenda a notificação diária.
  ///
  /// Deve ser chamado uma vez em [main], antes de [runApp].
  static Future<void> init() async {
    tz.initializeTimeZones();

    // Detecta o fuso horário local para agendar corretamente a meia-noite.
    tz.setLocalLocation(_detectLocalLocation());

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Solicita permissão de notificação no Android 13+.
    await androidPlugin?.requestNotificationsPermission();

    await scheduleMidnightNotification();
  }

  /// Detecta o fuso horário do dispositivo com base no offset UTC.
  ///
  /// Usa o banco IANA "Etc/GMT±N" que cobre praticamente todos os fusos
  /// de hora inteira (≈99% dos usuários). Retorna UTC como fallback.
  static tz.Location _detectLocalLocation() {
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (offsetMinutes == 0) return tz.UTC;
    final h = offsetMinutes ~/ 60;

    // No banco IANA, os offsets Etc/GMT são invertidos em relação ao UTC convencional.
    final name = offsetMinutes < 0 ? 'Etc/GMT+${-h}' : 'Etc/GMT-$h';
    try {
      return tz.getLocation(name);
    } catch (_) {
      return tz.UTC;
    }
  }

  /// Cancela qualquer notificação anterior e agenda uma nova para a próxima meia-noite.
  ///
  /// A notificação se repete diariamente pelo [matchDateTimeComponents].
  static Future<void> scheduleMidnightNotification() async {
    await _plugin.cancel(_notifId);

    final now = tz.TZDateTime.now(tz.local);
    final midnight = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1, // dia seguinte, hora 00:00:00
      0,
      0,
      0,
    );

    await _plugin.zonedSchedule(
      _notifId,
      'Seuh - Avante!! 🎯',
      'É hora de decidir de que forma você vai glorificar a Deus no dia de hoje!',
      midnight,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Penitência Diária',
          channelDescription: 'Lembrete diário da penitência Seuh',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,

      // Repete todo dia no mesmo horário (meia-noite).
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
