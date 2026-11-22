import '../../domain/entities/case_match.dart';
import '../../domain/use_cases/case_match_actions.dart';

class CaseMatchDto {
  static final _revision = RegExp(r'^[0-9a-f]{32}$');

  static Map<String, dynamic> _map(Object? value) => value is Map
      ? Map<String, dynamic>.from(value)
      : throw const MatchFailure(MatchIssue.unavailable);

  static MatchReference reference(Object? row) {
    final m = _map(row);
    final r = MatchReference(m['source'] as String, m['id'] as String);
    validateMatchReference(r);
    return r;
  }

  static List<MatchSearch> searches(Object? value) {
    if (value is! List || value.length > 100) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
    return [
      for (final row in value)
        if (_map(row) case final r)
          MatchSearch(
            reference(r['ref']),
            r['name'] as String,
            r['species'] as String,
          ),
    ];
  }

  static CaseMatchResult result(Object? value) {
    if (value is! Map) throw const MatchFailure(MatchIssue.unavailable);
    final r = _map(value);
    final pending = r['pendingPhotos'];
    if (r['model'] != 'clip-vit-b32-d15189d-q8-v1' ||
        r['complete'] is! bool ||
        pending is! int ||
        pending < 0 ||
        pending > 303 ||
        r['candidates'] is! List ||
        (r['candidates'] as List).length > 5 ||
        !_revision.hasMatch(r['revision'] as String)) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
    return CaseMatchResult(
      anchor: reference(r['anchor']),
      revision: r['revision'] as String,
      model: r['model'] as String,
      pendingPhotos: r['pendingPhotos'] as int,
      complete: r['complete'] as bool,
      candidates: [for (final c in r['candidates'] as List) _candidate(c)],
    );
  }

  static CaseMatchCandidate _candidate(Object? value) {
    final c = _map(value);
    final distance = c['distanceMeters'], days = c['daysApart'];
    if (distance is! int ||
        distance < 0 ||
        days is! int ||
        days < 0 ||
        !{null, 'confirmed', 'dismissed'}.contains(c['review']) ||
        !_revision.hasMatch(c['revision'] as String)) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
    return CaseMatchCandidate(
      reference: reference(c['ref']),
      revision: c['revision'] as String,
      name: c['name'] as String,
      distanceMeters: distance,
      daysApart: days,
      review: c['review'] as String?,
    );
  }
}
