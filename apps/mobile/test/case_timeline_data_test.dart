import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/data/models/case_timeline_dto.dart';

void main() {
  test('Lifecycle timeline decodes without private evidence', () {
    final page = CaseTimelineDto.page({
      'case_status': 'active',
      'items': [
        {
          'key': 'published',
          'id': 'published',
          'kind': 'published',
          'observed_at': '2026-10-29T12:00:00Z',
          'received_at': '2026-10-29T12:00:00Z',
          'is_late': false,
          'comment': '',
          'has_photo': false,
          'review_state': 'unreviewed',
          'revision': 0,
        },
      ],
      'next': null,
    });
    expect(page.items.single.kind, 'published');
    expect(page.next, isNull);
  });
}
