import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import 'event_date_time_draft.dart';

/// Fields of a report editor state read by [ReportDraftCoordinator].
///
/// [St] is the submission status of the queued command. The coordinator only
/// compares it; the feature owns its meaning.
abstract interface class ReportDraftState<St> {
  String get ownerId;
  String get draftId;
  bool get busy;
  bool get dirty;
  EventDateTimeDraft get dateTimeDraft;
  St? get submissionStatus;

  /// Exact command frozen after an ambiguous publication.
  bool get hasLockedDraft;

  /// The server confirmed the publication; the local draft is obsolete.
  bool get isConfirmed;

  /// This editor already received its publication receipt.
  bool get hasPublication;
}

/// Local draft failures that each feature maps to its own failure kind.
enum ReportDraftIssue { localStorage, conflict }

/// Shared coordination of a report editor with its local draft, the offline
/// submission queue and the publication receipt (ADR-174).
///
/// The feature ViewModel supplies its persistence ports and state transitions;
/// the coordinator keeps the concurrency contract in a single place:
/// - each [build] starts a generation ([nextDraftGeneration]); asynchronous
///   work only applies its result while [isCurrentDraft] holds;
/// - every operation that awaits holds `ref.keepAlive()` until it finishes;
/// - each meaningful change is saved locally, and a confirmed publication
///   removes its draft;
/// - the queue entry of the edited command updates its status, and a queued
///   receipt confirms the editor.
///
/// Core cannot depend on features, so [St] (submission status) and [Q] (queued
/// command) stay generic and are read through the hooks below.
mixin ReportDraftCoordinator<S extends ReportDraftState<St>, St, Q>
    on AsyncNotifier<S> {
  int _generation = 0;
  List<Q> _queueSnapshot = const [];
  Object? _checkpointKey;
  void Function()? _stopObserving;

  // Persistence ports, injected by the feature through its providers.

  /// Persisted editor context. Must stay stable while the draft is edited.
  @protected
  String get draftSlot;
  @protected
  Future<void> saveLocalDraft(S value, String slot);
  @protected
  Future<void> removeLocalDraft(String owner, String slot, String id);
  @protected
  Future<void> cancelLocalSubmission(String owner, String id);
  @protected
  ProviderListenable<AsyncValue<List<Q>>> queuedReports(String owner);
  @protected
  String queuedDraftId(Q entry);
  @protected
  St queuedStatus(Q entry);

  // State of the feature.

  /// Identity of the persisted content; equal keys skip a local save.
  @protected
  Object draftCheckpoint(S value);

  /// Whether the user can change form fields right now.
  @protected
  bool isEditable(S? value);
  @protected
  S withBusy(S value, bool busy);

  /// Null [status] clears the queue status.
  @protected
  S withSubmissionStatus(S value, St? status);

  /// Confirmed editor for an [entry] that carries its receipt, or null when
  /// the queue has not confirmed it yet.
  @protected
  S? confirmedByQueue(S value, Q entry);

  /// Copies report details, clearing the issue. Null coordinates keep the
  /// current point unless [clearPoint] is set.
  @protected
  S withEventDetails(
    S value, {
    required EventDateTimeDraft dateTimeDraft,
    required bool dirty,
    double? latitude,
    double? longitude,
    bool clearPoint = false,
    String? placeReference,
  });
  @protected
  S withDraftIssue(S value, ReportDraftIssue issue);
  @protected
  bool hasDraftIssue(S value, ReportDraftIssue issue);
  @protected
  S withoutIssue(S value);

  /// Extra guard of [discardLocalDraft] besides the expected id.
  @protected
  bool canDiscardLocalDraft(S value) => !value.busy;

  /// Runs after the local submission is cancelled and before the draft is
  /// removed. False stops the discard; the hook reports its own failure.
  @protected
  Future<bool> releaseBeforeDiscard(S value) async => true;

  /// Current generation, captured by asynchronous work before awaiting.
  @protected
  int get draftGeneration => _generation;

  /// Starts a generation. Call first in [build].
  @protected
  int nextDraftGeneration() => ++_generation;

  /// Results apply only to the generation and account that requested them.
  @protected
  bool isCurrentDraft(int generation, String owner) =>
      ref.mounted &&
      generation == _generation &&
      !state.isLoading &&
      state.asData?.value.ownerId == owner;

  /// Observes local checkpoints and the queue of [owner]. Call in [build]
  /// once the session is known and before the first await on local data.
  @protected
  void startDraftCoordination(String owner) {
    _observeDraft();
    _observeQueue(owner);
  }

  void _observeQueue(String owner) {
    _queueSnapshot = const [];
    final generation = _generation;
    ref.listen<AsyncValue<List<Q>>>(queuedReports(owner), (previous, next) {
      if (generation != _generation || next.isLoading || next.hasError) return;
      _queueSnapshot = next.asData?.value ?? const [];
      _applyQueue(generation, owner);
    });
  }

  void _applyQueue(int generation, String owner) {
    if (!isCurrentDraft(generation, owner)) return;
    final value = state.requireValue;
    if (value.busy || value.hasPublication) return;
    final entry = _queueSnapshot
        .where((e) => queuedDraftId(e) == value.draftId)
        .firstOrNull;
    if (entry == null) {
      if (value.submissionStatus != null) {
        state = AsyncData(withSubmissionStatus(value, null));
      }
      return;
    }
    final confirmed = confirmedByQueue(value, entry);
    if (confirmed != null) {
      state = AsyncData(confirmed);
    } else if (value.submissionStatus != queuedStatus(entry)) {
      state = AsyncData(withSubmissionStatus(value, queuedStatus(entry)));
    }
  }

  void _observeDraft() {
    _checkpointKey = null;
    _stopObserving?.call();
    final generation = _generation;
    _stopObserving = listenSelf((previous, next) {
      if (generation != _generation) return;
      scheduleMicrotask(() {
        if (ref.mounted) {
          _applyQueue(generation, next.asData?.value.ownerId ?? '');
        }
      });
      final value = next.asData?.value;
      if (next.isLoading || value == null) return;
      final key = draftCheckpoint(value);
      if (_checkpointKey == key) return;
      _checkpointKey = key;
      if (value.isConfirmed) {
        unawaited(
          removeLocalDraft(value.ownerId, draftSlot, value.draftId).catchError((
            Object _,
          ) {
            // The receipt remains confirmed. An undeleted exact command is safe to replay.
          }),
        );
      } else {
        unawaited(saveLocalCheckpoint(value));
      }
    });
  }

  /// Saves [value] when it has unsaved content or a frozen command. A failure
  /// marks the local storage issue only if the state still matches [value].
  @protected
  Future<bool> saveLocalCheckpoint(S value) async {
    if (!value.dirty && !value.hasLockedDraft) return true;
    final generation = _generation;
    final slot = draftSlot;
    final keep = ref.keepAlive();
    try {
      await saveLocalDraft(value, slot);
      return true;
    } catch (_) {
      if (isCurrentDraft(generation, value.ownerId) &&
          draftCheckpoint(state.requireValue) == draftCheckpoint(value)) {
        state = AsyncData(
          withDraftIssue(state.requireValue, ReportDraftIssue.localStorage),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }

  Future<bool> saveForLater() async {
    final value = state.asData?.value;
    if (value == null || state.isLoading) return false;
    final generation = _generation;
    final saved = await saveLocalCheckpoint(value);
    if (saved &&
        isCurrentDraft(generation, value.ownerId) &&
        hasDraftIssue(state.requireValue, ReportDraftIssue.localStorage)) {
      state = AsyncData(withoutIssue(state.requireValue));
    }
    return saved;
  }

  /// Cancels the queued command and removes the draft [expectedId]; on
  /// success the editor restarts empty.
  Future<bool> discardLocalDraft(String expectedId) async {
    final value = state.asData?.value;
    if (value == null ||
        value.draftId != expectedId ||
        !canDiscardLocalDraft(value)) {
      return false;
    }
    final generation = _generation;
    final slot = draftSlot;
    final keep = ref.keepAlive();
    state = AsyncData(withBusy(value, true));
    try {
      await cancelLocalSubmission(value.ownerId, value.draftId);
      if (!isCurrentDraft(generation, value.ownerId)) return false;
      if (!await releaseBeforeDiscard(value)) return false;
      if (!isCurrentDraft(generation, value.ownerId)) return false;
      if (!state.requireValue.busy) {
        state = AsyncData(withBusy(state.requireValue, true));
      }
      await removeLocalDraft(value.ownerId, slot, value.draftId);
      if (!isCurrentDraft(generation, value.ownerId)) return false;
      ref.invalidateSelf();
      return true;
    } catch (error) {
      if (isCurrentDraft(generation, value.ownerId)) {
        state = AsyncData(
          withDraftIssue(
            withBusy(state.requireValue, false),
            isConflict(error)
                ? ReportDraftIssue.conflict
                : ReportDraftIssue.localStorage,
          ),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }

  /// Whether a discard failure means the queued command changed.
  @protected
  bool isConflict(Object error);

  /// Restores report fields without changing animal data or photos.
  void restoreReportDetails({
    required String ownerId,
    required EventDateTimeDraft dateTime,
    required double? latitude,
    required double? longitude,
    required String placeReference,
  }) {
    final current = state.asData?.value;
    if (!isEditable(current) || current!.ownerId != ownerId) return;
    final hasDetails =
        dateTime.date != null ||
        dateTime.hour != null ||
        latitude != null ||
        longitude != null ||
        placeReference.isNotEmpty;
    state = AsyncData(
      withEventDetails(
        current,
        dateTimeDraft: dateTime,
        latitude: latitude,
        longitude: longitude,
        clearPoint: latitude == null && longitude == null,
        placeReference: placeReference,
        dirty: current.dirty || hasDetails,
      ),
    );
  }

  void chooseDate(DateTime date) {
    final current = state.asData?.value;
    if (!isEditable(current)) return;
    state = AsyncData(
      withEventDetails(
        current!,
        dateTimeDraft: current.dateTimeDraft.withDate(date),
        dirty: true,
      ),
    );
  }

  void chooseTime(int hour, int minute) {
    final current = state.asData?.value;
    if (!isEditable(current)) return;
    state = AsyncData(
      withEventDetails(
        current!,
        dateTimeDraft: current.dateTimeDraft.withTime(hour, minute),
        dirty: true,
      ),
    );
  }
}
