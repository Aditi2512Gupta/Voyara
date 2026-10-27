class DailyForecastModel {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final String icon;

  const DailyForecastModel({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.icon,
  });

  /// Parses OpenWeatherMap 5-day / 3-hour forecast response JSON
  /// and groups items into daily summaries based on the destination's local timezone.
  static List<DailyForecastModel> parseForecastList(Map<String, dynamic> json) {
    final rawList = json['list'] as List?;
    if (rawList == null || rawList.isEmpty) {
      return [];
    }

    // Timezone offset in seconds from UTC (default to 0 if not provided)
    final timezoneOffsetSeconds =
        (json['city']?['timezone'] as num?)?.toInt() ?? 0;
    final timezoneOffset = Duration(seconds: timezoneOffsetSeconds);

    // Group items by local calendar day (DateTime with hour/min/sec set to 0)
    final Map<DateTime, List<Map<String, dynamic>>> groupedByDay = {};

    for (final item in rawList) {
      if (item is! Map<String, dynamic>) continue;

      final dt = (item['dt'] as num?)?.toInt();
      if (dt == null) continue;

      final utcTime =
          DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true);
      final localTime = utcTime.add(timezoneOffset);
      final dayKey = DateTime(localTime.year, localTime.month, localTime.day);

      groupedByDay.putIfAbsent(dayKey, () => []).add({
        'localHour': localTime.hour,
        'temp': (item['main']?['temp'] as num?)?.toDouble() ?? 0.0,
        'tempMin': (item['main']?['temp_min'] as num?)?.toDouble() ??
            (item['main']?['temp'] as num?)?.toDouble() ??
            0.0,
        'tempMax': (item['main']?['temp_max'] as num?)?.toDouble() ??
            (item['main']?['temp'] as num?)?.toDouble() ??
            0.0,
        'condition': (item['weather'] as List?)?.isNotEmpty == true
            ? (item['weather'][0]?['main']?.toString() ?? 'Clear')
            : 'Clear',
        'icon': (item['weather'] as List?)?.isNotEmpty == true
            ? (item['weather'][0]?['icon']?.toString() ?? '01d')
            : '01d',
      });
    }

    // Sort days chronologically
    final sortedDays = groupedByDay.keys.toList()..sort();

    final List<DailyForecastModel> result = [];

    for (final day in sortedDays) {
      final entries = groupedByDay[day]!;
      if (entries.isEmpty) continue;

      double minTemp = entries.first['tempMin'] as double;
      double maxTemp = entries.first['tempMax'] as double;

      for (final e in entries) {
        final tMin = e['tempMin'] as double;
        final tMax = e['tempMax'] as double;
        if (tMin < minTemp) minTemp = tMin;
        if (tMax > maxTemp) maxTemp = tMax;
      }

      // Pick representative weather for the day:
      // Prefer mid-day entry (closest to 12:00 or 15:00), or the first daytime entry.
      Map<String, dynamic> representative = entries.first;
      int minDiffFromNoon = 24;

      for (final e in entries) {
        final hour = e['localHour'] as int;
        final diff = (hour - 12).abs();
        if (diff < minDiffFromNoon) {
          minDiffFromNoon = diff;
          representative = e;
        }
      }

      result.add(DailyForecastModel(
        date: day,
        minTemp: minTemp,
        maxTemp: maxTemp,
        condition: representative['condition'] as String,
        icon: representative['icon'] as String,
      ));
    }

    return result;
  }
}
