import '../../../../core/domain/entities/missing_report_value.dart';
import '../../../offline_drafts/domain/entities/local_report_draft.dart';
import '../../../offline_drafts/providers/submission_queue_providers.dart';
import '../../../offline_drafts/domain/entities/queued_report.dart';
import '../../../offline_drafts/domain/entities/report_slot.dart';
import '../../../../core/presentation/state/report_draft_coordinator.dart';
import '../../../offline_drafts/providers/local_draft_providers.dart';
import '../state/case_local_draft.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import '../../domain/use_cases/publish_lost_case.dart';
import '../../../pets/providers/pet_providers.dart';
import '../../domain/entities/lost_case.dart';
import '../../providers/lost_case_providers.dart';
import '../state/case_editor_state.dart';
import 'case_read_view_model.dart';

final caseEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<CaseEditorViewModel, CaseEditorState>(
      CaseEditorViewModel.new,
      retry: (_, _) => null,
    );

class CaseEditorViewModel extends AsyncNotifier<CaseEditorState>
    with
        ReportDraftCoordinator<
          CaseEditorState,
          SubmissionStatus,
          QueuedReport
        > {
  CaseEditorViewModel({Duration? publicationTimeout})
    : _publicationTimeout = publicationTimeout;
  final Duration? _publicationTimeout;
  Duration get publicationTimeout =>
      _publicationTimeout ?? const Duration(seconds: 35);

  @override
  String get draftSlot => ReportSlot.lostValue;
  @override
  Future<void> saveLocalDraft(CaseEditorState value, String slot) =>
      ref.read(saveLocalDraftProvider)(caseLocalDraft(value));
  @override
  Future<void> removeLocalDraft(String owner, String slot, String id) =>
      ref.read(removeLocalDraftProvider)(owner, slot, id);
  @override
  Future<void> cancelLocalSubmission(String owner, String id) =>
      ref.read(cancelLocalSubmissionProvider)(owner, id);
  @override
  ProviderListenable<AsyncValue<List<QueuedReport>>> queuedReports(
    String owner,
  ) => queuedReportsProvider(owner);
  @override
  String queuedDraftId(QueuedReport entry) => entry.command.id;
  @override
  SubmissionStatus queuedStatus(QueuedReport entry) => entry.status;
  @override
  Object draftCheckpoint(CaseEditorState value) => caseCheckpointKey(value);
  @override
  CaseEditorState withBusy(CaseEditorState value, bool busy) =>
      value.copyWith(busy: busy);
  @override
  CaseEditorState withSubmissionStatus(
    CaseEditorState value,
    SubmissionStatus? status,
  ) => status == null
      ? value.copyWith(clearSubmissionStatus: true)
      : value.copyWith(submissionStatus: status);
  @override
  CaseEditorState? confirmedByQueue(CaseEditorState value, QueuedReport entry) {
    final receipt = entry.receipt;
    if (receipt == null) return null;
    return value.copyWith(
      stage: CaseEditorStage.confirmed,
      published: receipt.lost,
      dirty: false,
      busy: false,
      submissionStatus: entry.status,
      clearIssue: true,
    );
  }

  @override
  CaseEditorState withEventDetails(
    CaseEditorState value, {
    required EventDateTimeDraft dateTimeDraft,
    required bool dirty,
    double? latitude,
    double? longitude,
    bool clearPoint = false,
    String? placeReference,
  }) => value.copyWith(
    dateTimeDraft: dateTimeDraft,
    latitude: latitude,
    longitude: longitude,
    clearPoint: clearPoint,
    placeReference: placeReference,
    dirty: dirty,
    clearIssue: true,
  );
  @override
  CaseEditorState withDraftIssue(
    CaseEditorState value,
    ReportDraftIssue issue,
  ) => value.copyWith(issue: _failureOf(issue));
  @override
  bool hasDraftIssue(CaseEditorState value, ReportDraftIssue issue) =>
      value.issue == _failureOf(issue);
  @override
  CaseEditorState withoutIssue(CaseEditorState value) =>
      value.copyWith(clearIssue: true);
  @override
  bool isConflict(Object error) => error is SubmissionFailure;
  CaseFailureKind _failureOf(ReportDraftIssue issue) => switch (issue) {
    ReportDraftIssue.localStorage => CaseFailureKind.localStorage,
    ReportDraftIssue.conflict => CaseFailureKind.conflict,
  };

  // A frozen command is released only by publishing or by its own screen.
  @override
  bool canDiscardLocalDraft(CaseEditorState value) =>
      !value.busy && !value.hasLockedDraft;

  @override
  Future<CaseEditorState> build() async {
    final generation = nextDraftGeneration();
    final session = await ref.watch(caseSessionProvider.future);
    if (!ref.mounted || generation != draftGeneration) {
      throw const CaseFailure(CaseFailureKind.forbidden);
    }
    if (session == null) throw const CaseFailure(CaseFailureKind.forbidden);
    startDraftCoordination(session.userId);
    final local = await ref.read(readLocalDraftProvider)(
      session.userId,
      ReportSlot.lostValue,
    );
    if (local != null) return restoreCaseLocalDraft(local);
    final pets = await ref.read(listMyPetsProvider)(session.userId);
    return CaseEditorState(
      ownerId: session.userId,
      draftId: newEntityId(),
      pets: pets.where((p) => !p.isArchived).toList(),
    );
  }

  void retry() => ref.invalidateSelf();
  @override
  bool isEditable(CaseEditorState? value) =>
      value != null &&
      !state.isLoading &&
      !value.busy &&
      !{
        SubmissionStatus.pending,
        SubmissionStatus.sending,
      }.contains(value.submissionStatus) &&
      !value.loadingPhotos &&
      value.lockedDraft == null &&
      value.stage != CaseEditorStage.confirmed;
  Future<void> selectPet(String id) async {
    final current = state.asData?.value;
    if (!isEditable(current)) return;
    final pet = current!.pets.where((p) => p.id == id).firstOrNull;
    if (pet == null) return;
    final generation = draftGeneration;
    state = AsyncData(
      current.copyWith(
        pet: pet,
        photos: [],
        selectedPhotos: {},
        loadingPhotos: true,
        dirty: true,
        clearIssue: true,
      ),
    );
    try {
      final updatedPet = await ref.read(readPetProvider)(current.ownerId, id);
      final photos = await ref
          .read(managePetPhotosProvider)
          .list(current.ownerId, id);
      if (!isCurrentDraft(generation, current.ownerId)) return;
      state = AsyncData(
        state.requireValue.copyWith(
          pet: updatedPet,
          photos: photos.where((p) => p.ready).toList(),
          loadingPhotos: false,
        ),
      );
    } catch (_) {
      if (isCurrentDraft(generation, current.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            loadingPhotos: false,
            issue: CaseFailureKind.unavailable,
          ),
        );
      }
    }
  }

  void edit({
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
    String? placeReference,
  }) {
    final current = state.asData?.value;
    if (!isEditable(current)) return;
    state = AsyncData(
      current!.copyWith(
        occurredAt: occurredAt,
        latitude: latitude,
        longitude: longitude,
        placeReference: placeReference,
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  void togglePhoto(String id) {
    final current = state.asData?.value;
    if (!isEditable(current) || !current!.photos.any((p) => p.id == id)) return;
    final selected = {...current.selectedPhotos};
    if (!selected.remove(id)) selected.add(id);
    state = AsyncData(
      current.copyWith(selectedPhotos: selected, dirty: true, clearIssue: true),
    );
  }

  LostCaseDraft _draft(CaseEditorState current) {
    return LostCaseDraft(
      id: current.draftId,
      petId: current.pet?.id ?? '',
      petVersion: current.pet?.version ?? 0,
      occurredAt: current.occurredAt ?? MissingReportValue.occurredAt,
      latitude: current.latitude ?? MissingReportValue.coordinate,
      longitude: current.longitude ?? MissingReportValue.coordinate,
      placeReference: current.placeReference,
      photoIds: current.selectedPhotos.toList(),
    );
  }

  void preview() {
    final current = state.asData?.value;
    if (!isEditable(current)) return;
    try {
      validateLostCasePet(current!.pet);
      final draft = _draft(current);
      ref.read(publishLostCaseProvider).validate(draft, DateTime.now());
      state = AsyncData(
        current.copyWith(stage: CaseEditorStage.preview, clearIssue: true),
      );
    } catch (e) {
      state = AsyncData(
        current!.copyWith(
          issue: e is CaseFailure ? e.kind : CaseFailureKind.invalid,
          invalidFields: e is CaseFailure ? e.fields : {},
        ),
      );
    }
  }

  void backToForm() {
    final current = state.asData?.value;
    if (!isEditable(current)) return;
    state = AsyncData(
      current!.copyWith(stage: CaseEditorStage.form, clearIssue: true),
    );
  }

  Future<void> publish() async {
    final current = state.asData?.value;
    if (current == null ||
        state.isLoading ||
        current.busy ||
        // Background sync is transmitting this same command right now.
        current.submissionStatus == SubmissionStatus.sending ||
        current.stage != CaseEditorStage.preview) {
      return;
    }
    final generation = draftGeneration;
    final keep = ref.keepAlive();
    try {
      final draft = current.lockedDraft ?? _draft(current);
      state = AsyncData(
        current.copyWith(busy: true, lockedDraft: draft, clearIssue: true),
      );
      if (!await saveLocalCheckpoint(state.requireValue)) {
        if (isCurrentDraft(generation, current.ownerId)) {
          state = AsyncData(state.requireValue.copyWith(busy: false));
        }
        return;
      }
      if (!isCurrentDraft(generation, current.ownerId)) return;
      final result = await ref
          .read(dispatchQueuedReportsProvider)
          .send(
            caseLocalDraft(state.requireValue),
            isCurrent: () => isCurrentDraft(generation, current.ownerId),
            resolveRejected: current.lockedDraft == null,
          )
          .timeout(
            publicationTimeout,
            onTimeout: () => throw const CaseFailure(CaseFailureKind.timedOut),
          );
      if (!isCurrentDraft(generation, current.ownerId)) return;
      final published = result.lost!;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          published: published,
          stage: CaseEditorStage.confirmed,
          dirty: false,
          clearIssue: true,
        ),
      );
      ref.read(notifyPetChangedProvider)(current.ownerId, draft.petId);
      ref.invalidate(myCasesViewModelProvider);
    } catch (error) {
      final e = error is LocalDraftFailure
          ? const CaseFailure(CaseFailureKind.localStorage)
          : error is SubmissionFailure
          ? CaseFailure(
              error.issue == SubmissionIssue.conflict
                  ? CaseFailureKind.conflict
                  : CaseFailureKind.unavailable,
            )
          : error;
      if (isCurrentDraft(generation, current.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            clearLockedDraft:
                e is CaseFailure &&
                e.kind != CaseFailureKind.unavailable &&
                e.kind != CaseFailureKind.timedOut,
            issue: e is CaseFailure ? e.kind : CaseFailureKind.unavailable,
            invalidFields: e is CaseFailure ? e.fields : {},
          ),
        );
      }
    } finally {
      keep.close();
    }
  }
}
