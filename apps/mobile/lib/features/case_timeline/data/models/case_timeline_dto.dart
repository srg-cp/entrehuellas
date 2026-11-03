import '../../domain/entities/case_timeline.dart';

class CaseTimelineDto {
  static DateTime date(Object? value) => DateTime.parse(value as String);
  static Map<String, dynamic> row(Object? value) =>
      Map<String, dynamic>.from(value as Map);
  static TimelinePage page(Object? value) {
    final r = row(value);
    final next = r['next'] == null ? null : row(r['next']);
    return TimelinePage(
      r['case_status'] as String,
      (r['items'] as List).map((value) {
        final e = row(value);
        return TimelineEvent(
          key: e['key'] as String,
          id: e['id'] as String,
          kind: e['kind'] as String,
          observedAt: date(e['observed_at']),
        );
      }).toList(),
      next == null
          ? null
          : TimelineCursor(date(next['time']), next['key'] as String),
    );
  }
}
