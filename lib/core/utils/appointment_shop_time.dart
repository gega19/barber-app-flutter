import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/entities/appointment_entity.dart';

/// Instant de cita interpretado en la timezone de la barbería.
class AppointmentShopTime {
  AppointmentShopTime._();

  static bool _db = false;

  static void _ensureDb() {
    if (!_db) {
      tz_data.initializeTimeZones();
      _db = true;
    }
  }

  static const fallbackTz = 'America/Caracas';

  static String timezoneFor(AppointmentEntity a) {
    final bt = a.barber?.timezone?.trim();
    if (bt != null && bt.isNotEmpty) return bt;
    final rt = a.barberTimezone?.trim();
    if (rt != null && rt.isNotEmpty) return rt;
    return fallbackTz;
  }

  static List<int> _parseHm(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return [hour, minute];
  }

  static List<int> _parseYmd(String ymd) {
    final p = ymd.split('-');
    return [
      int.tryParse(p.isNotEmpty ? p[0] : '0') ?? 0,
      p.length > 1 ? int.tryParse(p[1]) ?? 1 : 1,
      p.length > 2 ? int.tryParse(p[2]) ?? 1 : 1,
    ];
  }

  /// Instante UTC del slot en la barbería.
  static DateTime utcInstant(AppointmentEntity a) {
    _ensureDb();
    final zoneName = timezoneFor(a);
    final loc = tz.getLocation(zoneName);
    final ymd = _parseYmd(a.dateYmd);
    final hm = _parseHm(a.time);
    final zdt = tz.TZDateTime(loc, ymd[0], ymd[1], ymd[2], hm[0], hm[1]);
    return zdt.toUtc();
  }
}
