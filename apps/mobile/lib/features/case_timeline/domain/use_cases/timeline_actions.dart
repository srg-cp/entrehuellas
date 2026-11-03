import '../entities/case_timeline.dart';
import '../repositories/case_timeline_repository.dart';

class ReadTimelineAccess {
  const ReadTimelineAccess(this.repository);
  final CaseTimelineRepository repository;
  Future<bool> call(String owner, TimelineTarget target) =>
      owner.isEmpty ? Future.value(false) : repository.canRead(owner, target);
}

class ReadCaseTimeline {
  const ReadCaseTimeline(this.repository);
  final CaseTimelineRepository repository;
  Future<TimelinePage> call(
    String owner,
    TimelineTarget target, [
    TimelineCursor? cursor,
  ]) {
    if (owner.isEmpty) throw const TimelineFailure(TimelineIssue.forbidden);
    return repository.read(owner, target, cursor);
  }
}
