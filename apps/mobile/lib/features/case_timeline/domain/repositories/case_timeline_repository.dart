import '../entities/case_timeline.dart';

abstract interface class CaseTimelineRepository {
  Future<bool> canRead(String owner, TimelineTarget target);
  Future<TimelinePage> read(
    String owner,
    TimelineTarget target,
    TimelineCursor? cursor,
  );
}
