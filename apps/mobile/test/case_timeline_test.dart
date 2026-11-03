import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/domain/entities/case_timeline.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/domain/repositories/case_timeline_repository.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/domain/use_cases/timeline_actions.dart';

class FakeTimeline implements CaseTimelineRepository {
  bool deny = false;
  @override
  Future<bool> canRead(String owner, TimelineTarget target) async => !deny;
  @override
  Future<TimelinePage> read(
    String owner,
    TimelineTarget target,
    TimelineCursor? cursor,
  ) async {
    if (deny) throw const TimelineFailure(TimelineIssue.forbidden);
    return TimelinePage('active', [], null);
  }
}

void main() {
  test('Lifecycle history still requires an authenticated reader', () async {
    final repo = FakeTimeline();
    expect(
      await ReadTimelineAccess(repo)('', (id: 'case', community: false)),
      false,
    );
    await expectLater(
      Future.sync(
        () => ReadCaseTimeline(repo)('', (id: 'case', community: false)),
      ),
      throwsA(isA<TimelineFailure>()),
    );
    expect(
      (await ReadCaseTimeline(repo)('owner', (
        id: 'case',
        community: false,
      ))).items,
      isEmpty,
    );
  });
}
