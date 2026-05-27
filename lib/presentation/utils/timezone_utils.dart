import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class TimezoneUtils {
  static bool _initialized = false;

  /// Initializes the timezone database. Should be called in main().
  static Future<void> initialize() async {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
  }

  /// Converts a UTC DateTime to a specific timezone.
  static DateTime toTimezone(DateTime utcDateTime, String timezoneName) {
    if (!_initialized) {
      throw StateError('TimezoneUtils has not been initialized. Call initialize() first.');
    }
    
    try {
      final location = tz.getLocation(timezoneName);
      final tzDateTime = tz.TZDateTime.from(utcDateTime, location);
      return tzDateTime;
    } catch (e) {
      // Fallback to local time if timezone is not found
      return utcDateTime.toLocal();
    }
  }

  /// Converts a timezone-specific DateTime to local DateTime.
  static DateTime toLocalTime(DateTime dateTime, String sourceTimezone) {
    if (!_initialized) {
      throw StateError('TimezoneUtils has not been initialized. Call initialize() first.');
    }

    try {
      final location = tz.getLocation(sourceTimezone);
      
      // If the dateTime is already considered UTC, we treat it as being in the source timezone
      // Example: 10:00 AM in America/Bogota -> We want to know what time that is locally
      
      // We construct a TZDateTime using the year, month, day, hour, minute of the original dateTime
      // but explicitly state it belongs to the source timezone.
      final tzDateTime = tz.TZDateTime(
        location,
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );

      // Now we ask Dart to convert this specific point in time to the local device time
      return tzDateTime.toLocal();
    } catch (e) {
      return dateTime.toLocal();
    }
  }
}
