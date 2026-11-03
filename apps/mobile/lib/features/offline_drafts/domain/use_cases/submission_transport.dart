import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../lost_cases/domain/use_cases/publish_lost_case.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../../../found_cases/domain/use_cases/found_case_actions.dart';
import '../entities/local_report_draft.dart';
import '../entities/queued_report.dart';

/// Uses the same concrete product operations and receipt validation as the editors.
class SubmissionTransport {
  const SubmissionTransport(this._lostAction, this._foundAction);
  final PublishLostCase Function() _lostAction;
  final PublishFoundCase Function() _foundAction;
  PublishLostCase get lost => _lostAction();
  PublishFoundCase get found => _foundAction();

  LostCaseDraft _lost(LocalReportDraft d) => LostCaseDraft(
    id: d.id,
    petId: d.pet!.id,
    petVersion: d.pet!.version,
    occurredAt: d.instant!,
    latitude: d.latitude!,
    longitude: d.longitude!,
    placeReference: d.place,
    photoIds: d.selectedPhotos,
  );
  FoundCaseDraft _found(LocalReportDraft d) {
    final parts = d.slot.split(':');
    return FoundCaseDraft(
      id: d.id,
      reportKind: d.reportKind,
      targetId: {'community-search', 'independent-found'}.contains(d.slot)
          ? null
          : parts[2],
      communityTarget:
          {'community-search', 'independent-found'}.contains(d.slot)
          ? false
          : parts[1] == 'true',
      occurredAt: d.instant!,
      latitude: d.latitude!,
      longitude: d.longitude!,
      placeReference: d.place,
      species: d.species,
      speciesDetail: d.species == 'other' ? d.speciesDetail : null,
      size: d.size.isEmpty ? null : d.size,
      sex: d.sex.isEmpty ? null : d.sex,
      traits: d.traits,
      custody: d.custody.isEmpty ? null : d.custody,
      photos: d.photos,
    );
  }

  void validate(LocalReportDraft d) {
    if (d.owner.isEmpty ||
        !d.frozen ||
        d.instant == null ||
        d.latitude == null ||
        d.longitude == null) {
      throw const SubmissionFailure(SubmissionIssue.invalid);
    }
    if (d.slot == 'lost') {
      if (d.pet == null) {
        throw const SubmissionFailure(SubmissionIssue.invalid);
      }
      validateLostCasePet(d.pet);
      lost.validate(_lost(d), DateTime.now());
    } else if ({'community-search', 'independent-found'}.contains(d.slot) ||
        d.slot.startsWith('found:')) {
      if (!{'community-search', 'independent-found'}.contains(d.slot) &&
          d.slot.split(':').length != 3) {
        throw const SubmissionFailure(SubmissionIssue.invalid);
      }
      found.validate(_found(d), DateTime.now());
    } else {
      throw const SubmissionFailure(SubmissionIssue.invalid);
    }
  }

  Future<SubmissionReceipt> send(LocalReportDraft d) async {
    validate(d);
    if (d.slot == 'lost') {
      return SubmissionReceipt.lost(await lost(d.owner, _lost(d)));
    }
    if ({'community-search', 'independent-found'}.contains(d.slot) ||
        d.slot.startsWith('found:')) {
      return SubmissionReceipt.found(await found(d.owner, _found(d)));
    }
    throw const SubmissionFailure(SubmissionIssue.invalid);
  }
}
