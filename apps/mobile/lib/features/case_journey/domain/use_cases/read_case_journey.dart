import '../../../lost_cases/domain/repositories/lost_case_repository.dart';
import '../../../found_cases/domain/repositories/found_case_repository.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../entities/case_journey.dart';

/// Aggregates existing authorized projections; never publishes private evidence.
class ReadCaseJourney {
  const ReadCaseJourney(this.lost, this.found);
  final LostCaseRepository lost;
  final FoundCaseRepository found;
  Future<CaseJourney> call(String owner, JourneyTarget target) async {
    if (owner.isEmpty) throw const FoundFailure(FoundFailureKind.forbidden);
    final JourneyPoint origin;
    final JourneyCaseSummary summary;
    if (target.community) {
      final value = await found.readPublic(target.id);
      if (value == null || value.reportKind != 'possible_loss') {
        throw const FoundFailure(FoundFailureKind.forbidden);
      }
      origin = JourneyPoint(
        id: value.id,
        time: value.occurredAt,
        latitude: value.latitude,
        longitude: value.longitude,
      );
      summary = JourneyCaseSummary(
        traits: value.traits,
        photoUri: value.photos.where((p) => p.uri != null).firstOrNull?.uri,
      );
    } else {
      final value = await lost.readPublic(target.id);
      if (value == null) throw const FoundFailure(FoundFailureKind.forbidden);
      origin = JourneyPoint(
        id: value.id,
        time: value.occurredAt,
        latitude: value.latitude,
        longitude: value.longitude,
      );
      summary = JourneyCaseSummary(
        name: value.fields.name,
        traits: value.fields.traits ?? '',
        photoUri: value.photos.where((p) => p.uri != null).firstOrNull?.uri,
      );
    }
    if (origin.id != target.id) {
      throw const FoundFailure(FoundFailureKind.forbidden);
    }
    final notices = await found.listObservations(target.id, target.community);
    final points = <String, JourneyPoint>{};
    for (final notice in notices) {
      if (notice.targetId != target.id ||
          notice.communityTarget != target.community ||
          !{'sighting', 'with_reporter'}.contains(notice.reportKind)) {
        throw const FoundFailure(FoundFailureKind.forbidden);
      }
      final point = JourneyPoint(
        id: notice.id,
        time: notice.occurredAt,
        latitude: notice.latitude,
        longitude: notice.longitude,
        inCustody: notice.reportKind == 'with_reporter',
      );
      points[point.key] = point;
    }
    final ordered = points.values.toList()
      ..sort((a, b) {
        final time = a.time.compareTo(b.time);
        return time == 0 ? a.key.compareTo(b.key) : time;
      });
    return CaseJourney(
      target: target,
      origin: origin,
      points: ordered,
      summary: summary,
    );
  }
}
