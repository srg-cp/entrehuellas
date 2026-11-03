import '../../domain/entities/case_timeline.dart';
import '../../domain/repositories/case_timeline_repository.dart';
import '../data_sources/case_timeline_source.dart';
import '../models/case_timeline_dto.dart';

class CaseTimelineRepositoryImpl implements CaseTimelineRepository {
  const CaseTimelineRepositoryImpl(this.source);
  final CaseTimelineSource source;
  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on TimelineFailure {
      rethrow;
    } on TimelineSourceFailure catch (e) {
      throw TimelineFailure(switch (e.code) {
        'forbidden' => TimelineIssue.forbidden,
        'invalid' => TimelineIssue.invalid,
        'conflict' => TimelineIssue.conflict,
        'closed' => TimelineIssue.closed,
        'transition' => TimelineIssue.transition,
        _ => TimelineIssue.unavailable,
      });
    } catch (_) {
      throw const TimelineFailure(TimelineIssue.unavailable);
    }
  }

  Map<String, dynamic> _target(TimelineTarget t) => {
    'p_source': t.community ? 'found' : 'lost',
    'p_case': t.id,
  };
  @override
  Future<bool> canRead(String owner, TimelineTarget target) => _run(
    () async =>
        await source.call(owner, 'can_read_case_timeline', _target(target))
            as bool,
  );
  @override
  Future<TimelinePage> read(
    String owner,
    TimelineTarget target,
    TimelineCursor? cursor,
  ) => _run(
    () async => CaseTimelineDto.page(
      await source.call(owner, 'read_case_timeline', {
        ..._target(target),
        'p_before_time': cursor?.time.toUtc().toIso8601String(),
        'p_before_key': cursor?.key,
        'p_limit': 20,
      }),
    ),
  );
}

class UnavailableCaseTimelineRepository implements CaseTimelineRepository {
  const UnavailableCaseTimelineRepository();
  @override
  Future<bool> canRead(String owner, TimelineTarget target) async => false;
  @override
  Future<TimelinePage> read(
    String owner,
    TimelineTarget target,
    TimelineCursor? cursor,
  ) async => throw const TimelineFailure(TimelineIssue.unavailable);
}
