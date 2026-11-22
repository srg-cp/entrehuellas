import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../lost_cases/domain/use_cases/publish_lost_case.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../../../found_cases/domain/use_cases/found_case_actions.dart';
import '../entities/local_report_draft.dart';
import '../entities/queued_report.dart';
import '../entities/report_slot.dart';

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
    final slot = ReportSlot.tryParse(d.slot);
    return FoundCaseDraft(
      id: d.id,
      reportKind: d.reportKind,
      targetId: slot is FoundTargetSlot ? slot.targetId : null,
      communityTarget: slot is FoundTargetSlot && slot.community,
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
    switch (ReportSlot.tryParse(d.slot)) {
      case LostReportSlot():
        if (d.pet == null) {
          throw const SubmissionFailure(SubmissionIssue.invalid);
        }
        validateLostCasePet(d.pet);
        lost.validate(_lost(d), DateTime.now());
      case CommunitySearchSlot() || IndependentFoundSlot() || FoundTargetSlot():
        found.validate(_found(d), DateTime.now());
      case null:
        throw const SubmissionFailure(SubmissionIssue.invalid);
    }
  }

  Future<SubmissionReceipt> send(LocalReportDraft d) async {
    validate(d);
    // validate() already rejected unknown slots.
    return ReportSlot.tryParse(d.slot) is LostReportSlot
        ? SubmissionReceipt.lost(await lost(d.owner, _lost(d)))
        : SubmissionReceipt.found(await found(d.owner, _found(d)));
  }
}
