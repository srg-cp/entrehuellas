import '../../../../core/domain/entities/missing_report_value.dart';
import '../../../offline_drafts/domain/entities/local_report_draft.dart';
import '../../../offline_drafts/providers/submission_queue_providers.dart';
import '../../../offline_drafts/domain/entities/queued_report.dart';
import '../../../../core/presentation/state/report_draft_coordinator.dart';
import '../../../offline_drafts/providers/local_draft_providers.dart';
import '../state/found_local_draft.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import 'recovery_case_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/found_case.dart';
import '../../providers/found_case_providers.dart';
import '../state/found_editor_state.dart';
import 'found_read_view_model.dart';

final foundEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<FoundEditorViewModel, FoundEditorState>(
      FoundEditorViewModel.new,
      dependencies: [foundEditorContextProvider],
      retry: (_, _) => null,
    );

class FoundEditorViewModel extends AsyncNotifier<FoundEditorState>
    with
        ReportDraftCoordinator<
          FoundEditorState,
          SubmissionStatus,
          QueuedReport
        > {
  FoundEditorViewModel({Duration? operationTimeout})
    : _operationTimeout = operationTimeout ?? const Duration(seconds: 90);
  final Duration _operationTimeout;
  bool get communitySearch =>
      ref.read(foundEditorContextProvider).communitySearch;
  String _slot = '';

  @override
  String get draftSlot => _slot;
  @override
  Future<void> saveLocalDraft(FoundEditorState value, String slot) =>
      ref.read(saveLocalDraftProvider)(foundLocalDraft(value, slot));
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
  Object draftCheckpoint(FoundEditorState value) => foundCheckpointKey(value);
  @override
  FoundEditorState withBusy(FoundEditorState value, bool busy) =>
      value.copyWith(busy: busy);
  @override
  FoundEditorState withSubmissionStatus(
    FoundEditorState value,
    SubmissionStatus? status,
  ) => status == null
      ? value.copyWith(clearSubmissionStatus: true)
      : value.copyWith(submissionStatus: status);
  @override
  FoundEditorState? confirmedByQueue(
    FoundEditorState value,
    QueuedReport entry,
  ) {
    final receipt = entry.receipt;
    if (receipt == null) return null;
    return value.copyWith(
      stage: FoundStage.confirmed,
      published: receipt.found,
      dirty: false,
      busy: false,
      submissionStatus: entry.status,
      clearIssue: true,
    );
  }

  @override
  FoundEditorState withEventDetails(
    FoundEditorState value, {
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
  FoundEditorState withDraftIssue(
    FoundEditorState value,
    ReportDraftIssue issue,
  ) => value.copyWith(issue: _failureOf(issue));
  @override
  bool hasDraftIssue(FoundEditorState value, ReportDraftIssue issue) =>
      value.issue == _failureOf(issue);
  @override
  FoundEditorState withoutIssue(FoundEditorState value) =>
      value.copyWith(clearIssue: true);
  @override
  bool isConflict(Object error) => error is SubmissionFailure;
  FoundFailureKind _failureOf(ReportDraftIssue issue) => switch (issue) {
    ReportDraftIssue.localStorage => FoundFailureKind.localStorage,
    ReportDraftIssue.conflict => FoundFailureKind.conflict,
  };

  // An attempted command may exist on the server: release it there first.
  @override
  Future<bool> releaseBeforeDiscard(FoundEditorState value) async =>
      !value.attempted || await _performDiscard(alreadyBusy: true);

  @override
  Future<FoundEditorState> build() async {
    final generation = nextDraftGeneration();
    final session = await ref.watch(foundSessionProvider.future);
    if (!ref.mounted || generation != draftGeneration) {
      throw const FoundFailure(FoundFailureKind.forbidden);
    }
    if (session == null) throw const FoundFailure(FoundFailureKind.forbidden);
    final context = ref.watch(foundEditorContextProvider);
    _slot = foundDraftSlot(context);
    startDraftCoordination(session.userId);
    final local = await ref.read(readLocalDraftProvider)(session.userId, _slot);
    if (local != null) return restoreFoundLocalDraft(local, context);
    final target = context.communitySearch
        ? null
        : await ref.watch(readRecoverySearchProvider)(
            context.targetId ?? '',
            context.communityTarget,
          );
    final value = FoundEditorState(
      ownerId: session.userId,
      draftId: newEntityId(),
      communitySearch: context.communitySearch,
      reportKind: context.independentFound
          ? 'independent_found'
          : context.communitySearch
          ? 'possible_loss'
          : 'sighting',
      target: target,
    );
    return target == null
        ? value
        : value.copyWith(
            targetId: target.id,
            communityTarget: target.community,
            species: target.species,
            speciesDetail: target.speciesDetail,
            size: target.size,
            sex: target.sex,
          );
  }

  void retry() => ref.invalidateSelf();
  @override
  bool isEditable(FoundEditorState? v) =>
      v != null &&
      !state.isLoading &&
      !v.busy &&
      !{
        SubmissionStatus.pending,
        SubmissionStatus.sending,
      }.contains(v.submissionStatus) &&
      v.lockedDraft == null &&
      v.issue != FoundFailureKind.targetClosed &&
      v.stage != FoundStage.confirmed;
  void chooseObservation(String kind) {
    final value = state.asData?.value;
    if (!isEditable(value) ||
        value!.communitySearch ||
        !{'sighting', 'with_reporter'}.contains(kind)) {
      return;
    }
    state = AsyncData(
      value.copyWith(
        reportKind: kind,
        custody: kind == 'with_reporter' ? 'with_me' : 'not_with_me',
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  void edit({
    String? species,
    String? speciesDetail,
    String? size,
    String? sex,
    String? traits,
    String? custody,
    String? placeReference,
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
  }) {
    final v = state.asData?.value;
    if (!isEditable(v)) return;
    state = AsyncData(
      v!.copyWith(
        species: species,
        speciesDetail: species != null && species != 'other'
            ? ''
            : speciesDetail,
        size: size,
        sex: sex,
        traits: traits,
        custody: custody,
        placeReference: placeReference,
        occurredAt: occurredAt,
        latitude: latitude,
        longitude: longitude,
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  Future<void> choosePhoto({bool camera = false, bool recover = false}) async {
    final v = state.asData?.value;
    if (!isEditable(v) || v!.photos.length >= 3) return;
    final g = draftGeneration;
    state = AsyncData(v.copyWith(busy: true, clearIssue: true));
    try {
      final action = ref.read(chooseFoundPhotoProvider);
      final bytes = recover
          ? await action.recover(v.ownerId, v.draftId)
          : await action(v.ownerId, v.draftId, camera: camera);
      if (!isCurrentDraft(g, v.ownerId)) return;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          photos: bytes == null
              ? v.photos
              : [...v.photos, FoundPhotoDraft(newEntityId(), bytes)],
          dirty: v.dirty || bytes != null,
        ),
      );
    } catch (e) {
      if (isCurrentDraft(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is FoundFailure ? e.kind : FoundFailureKind.gallery,
          ),
        );
      }
    }
  }

  void removePhoto(String id) {
    final v = state.asData?.value;
    if (!isEditable(v)) return;
    state = AsyncData(
      v!.copyWith(
        photos: v.photos.where((p) => p.id != id).toList(),
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  FoundCaseDraft _draft(FoundEditorState v) => FoundCaseDraft(
    id: v.draftId,
    reportKind: v.reportKind,
    targetId: v.targetId,
    communityTarget: v.communityTarget,
    occurredAt: v.occurredAt ?? MissingReportValue.occurredAt,
    latitude: v.latitude ?? MissingReportValue.coordinate,
    longitude: v.longitude ?? MissingReportValue.coordinate,
    placeReference: v.placeReference,
    species: v.species,
    speciesDetail: v.species == 'other' ? v.speciesDetail : null,
    size: v.size.isEmpty ? null : v.size,
    sex: v.sex.isEmpty ? null : v.sex,
    traits: v.traits,
    custody: v.custody.isEmpty ? null : v.custody,
    photos: v.photos,
  );
  void preview() {
    final v = state.asData?.value;
    if (!isEditable(v)) return;
    try {
      ref.read(publishFoundCaseProvider).validate(_draft(v!), DateTime.now());
      state = AsyncData(
        v.copyWith(stage: FoundStage.preview, clearIssue: true),
      );
    } catch (e) {
      state = AsyncData(
        v!.copyWith(
          issue: e is FoundFailure ? e.kind : FoundFailureKind.invalid,
          invalidFields: e is FoundFailure ? e.fields : {},
        ),
      );
    }
  }

  void backToForm() {
    final v = state.asData?.value;
    if (!isEditable(v)) return;
    state = AsyncData(v!.copyWith(stage: FoundStage.form, clearIssue: true));
  }

  Future<void> publish() async {
    final v = state.asData?.value;
    if (v == null ||
        state.isLoading ||
        v.busy ||
        // Background sync is transmitting this same command right now.
        v.submissionStatus == SubmissionStatus.sending ||
        v.issue == FoundFailureKind.targetClosed ||
        v.stage != FoundStage.preview) {
      return;
    }
    final g = draftGeneration, keep = ref.keepAlive();
    final d = v.lockedDraft ?? _draft(v);
    state = AsyncData(
      v.copyWith(busy: true, lockedDraft: d, attempted: true, clearIssue: true),
    );
    try {
      if (!await saveLocalCheckpoint(state.requireValue)) {
        if (isCurrentDraft(g, v.ownerId)) {
          state = AsyncData(state.requireValue.copyWith(busy: false));
        }
        return;
      }
      if (!isCurrentDraft(g, v.ownerId)) return;
      final result = await ref
          .read(dispatchQueuedReportsProvider)
          .send(
            foundLocalDraft(state.requireValue, _slot),
            isCurrent: () => isCurrentDraft(g, v.ownerId),
            resolveRejected: v.lockedDraft == null,
          )
          .timeout(
            _operationTimeout,
            onTimeout: () =>
                throw const FoundFailure(FoundFailureKind.timedOut),
          );
      if (!isCurrentDraft(g, v.ownerId)) return;
      final published = result.found!;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          stage: FoundStage.confirmed,
          published: published,
          dirty: false,
          clearIssue: true,
        ),
      );
      ref.invalidate(myFoundCasesViewModelProvider);
      if (d.targetId != null) {
        ref.invalidate(
          recoveryCaseViewModelProvider((d.targetId!, d.communityTarget)),
        );
      }
    } catch (error) {
      final e = error is LocalDraftFailure
          ? const FoundFailure(FoundFailureKind.localStorage)
          : error is SubmissionFailure
          ? FoundFailure(
              error.issue == SubmissionIssue.conflict
                  ? FoundFailureKind.conflict
                  : FoundFailureKind.unavailable,
            )
          : error;
      if (isCurrentDraft(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is FoundFailure ? e.kind : FoundFailureKind.unavailable,
            clearLock:
                e is FoundFailure &&
                {
                  FoundFailureKind.invalid,
                  FoundFailureKind.photoInvalid,
                  FoundFailureKind.photos,
                  FoundFailureKind.draftLimit,
                  FoundFailureKind.targetClosed,
                  FoundFailureKind.blocked,
                }.contains(e.kind),
          ),
        );
      }
    } finally {
      keep.close();
    }
  }

  // The frozen request can only be released after the server confirms no active case exists.
  Future<bool> discard() => _performDiscard();

  Future<bool> _performDiscard({bool alreadyBusy = false}) async {
    final v = state.asData?.value;
    if (v == null ||
        (v.busy && !alreadyBusy) ||
        v.stage == FoundStage.confirmed) {
      return false;
    }
    if (!v.attempted) return true;
    final cancel = ref.read(cancelLocalSubmissionProvider);
    final g = draftGeneration, keep = ref.keepAlive();
    state = AsyncData(v.copyWith(busy: true, clearIssue: true));
    try {
      await cancel(v.ownerId, v.draftId);
      if (!isCurrentDraft(g, v.ownerId)) return false;
      await ref
          .read(discardFoundDraftProvider)(v.ownerId, v.draftId)
          .timeout(
            _operationTimeout,
            onTimeout: () =>
                throw const FoundFailure(FoundFailureKind.timedOut),
          );
      if (!isCurrentDraft(g, v.ownerId)) return false;
      state = AsyncData(state.requireValue.copyWith(busy: false, dirty: false));
      ref.invalidate(myFoundCasesViewModelProvider);
      return true;
    } catch (e) {
      if (isCurrentDraft(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is SubmissionFailure
                ? FoundFailureKind.conflict
                : e is FoundFailure
                ? e.kind
                : FoundFailureKind.unavailable,
          ),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }
}
