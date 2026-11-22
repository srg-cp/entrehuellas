import 'dart:async';

import 'package:flutter_application_entrehuellas/core/presentation/state/event_date_time_draft.dart';
import 'package:flutter_application_entrehuellas/core/presentation/state/report_draft_coordinator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';

// Feature-independent editor: proves the contract of ReportDraftCoordinator
// (ADR-174) without lost/found specifics.

enum _Status { pending, sending }

class _Entry {
  const _Entry(this.id, this.status, {this.receipt});
  final String id;
  final _Status status;
  final String? receipt;
}

class _Conflict implements Exception {}

class _State implements ReportDraftState<_Status> {
  _State({
    required this.ownerId,
    required this.draftId,
    this.busy = false,
    this.dirty = false,
    this.dateTimeDraft = const EventDateTimeDraft(),
    this.submissionStatus,
    this.hasLockedDraft = false,
    this.receipt,
    this.latitude,
    this.longitude,
    this.place = '',
    this.issue,
  });
  @override
  final String ownerId, draftId;
  @override
  final bool busy, dirty, hasLockedDraft;
  @override
  final EventDateTimeDraft dateTimeDraft;
  @override
  final _Status? submissionStatus;
  final String? receipt;
  final double? latitude, longitude;
  final String place;
  final ReportDraftIssue? issue;
  @override
  bool get isConfirmed => receipt != null;
  @override
  bool get hasPublication => receipt != null;

  _State copyWith({
    bool? busy,
    bool? dirty,
    EventDateTimeDraft? dateTimeDraft,
    _Status? submissionStatus,
    bool clearSubmissionStatus = false,
    String? receipt,
    double? latitude,
    double? longitude,
    bool clearPoint = false,
    String? place,
    ReportDraftIssue? issue,
    bool clearIssue = false,
  }) => _State(
    ownerId: ownerId,
    draftId: draftId,
    busy: busy ?? this.busy,
    dirty: dirty ?? this.dirty,
    dateTimeDraft: dateTimeDraft ?? this.dateTimeDraft,
    submissionStatus: clearSubmissionStatus
        ? null
        : submissionStatus ?? this.submissionStatus,
    hasLockedDraft: hasLockedDraft,
    receipt: receipt ?? this.receipt,
    latitude: clearPoint ? null : latitude ?? this.latitude,
    longitude: clearPoint ? null : longitude ?? this.longitude,
    place: place ?? this.place,
    issue: clearIssue ? null : issue ?? this.issue,
  );
}

/// Controllable persistence: every call is recorded and can be held.
class _Ports {
  String owner = 'owner';
  var _ids = 0;
  _State? restore;
  final calls = <String>[];
  // Closed in tearDown.
  // ignore: close_sinks
  final queue = StreamController<List<_Entry>>.broadcast();
  bool holdSaves = false, holdCancels = false;
  final saveGates = <Completer<void>>[];
  final cancelGates = <Completer<void>>[];
  Object? saveError, cancelError;
  bool editable = true, discardable = true, release = true;

  _State next() => restore ?? _State(ownerId: owner, draftId: 'd${++_ids}');

  Future<void> save(_State value, String slot) async {
    calls.add('save $slot ${value.draftId}');
    if (holdSaves) {
      final gate = Completer<void>();
      saveGates.add(gate);
      await gate.future;
    }
    if (saveError != null) throw saveError!;
  }

  Future<void> cancel(String owner, String id) async {
    calls.add('cancel $owner $id');
    if (holdCancels) {
      final gate = Completer<void>();
      cancelGates.add(gate);
      await gate.future;
    }
    if (cancelError != null) throw cancelError!;
  }

  Future<void> remove(String owner, String slot, String id) async {
    calls.add('remove $owner $slot $id');
  }
}

final _portsProvider = Provider<_Ports>((ref) => throw UnimplementedError());
final _queueProvider = StreamProvider.autoDispose.family<List<_Entry>, String>(
  (ref, owner) => ref.watch(_portsProvider).queue.stream,
);
final _editorProvider = AsyncNotifierProvider.autoDispose<_Editor, _State>(
  _Editor.new,
);

class _Editor extends AsyncNotifier<_State>
    with ReportDraftCoordinator<_State, _Status, _Entry> {
  _Ports get _ports => ref.read(_portsProvider);

  @override
  Future<_State> build() async {
    final generation = nextDraftGeneration();
    final ports = ref.watch(_portsProvider);
    await Future<void>.value();
    if (generation != draftGeneration) throw StateError('stale');
    startDraftCoordination(ports.owner);
    return ports.next();
  }

  @override
  String get draftSlot => 'slot-A';
  @override
  Future<void> saveLocalDraft(_State value, String slot) =>
      _ports.save(value, slot);
  @override
  Future<void> removeLocalDraft(String owner, String slot, String id) =>
      _ports.remove(owner, slot, id);
  @override
  Future<void> cancelLocalSubmission(String owner, String id) =>
      _ports.cancel(owner, id);
  @override
  ProviderListenable<AsyncValue<List<_Entry>>> queuedReports(String owner) =>
      _queueProvider(owner);
  @override
  String queuedDraftId(_Entry entry) => entry.id;
  @override
  _Status queuedStatus(_Entry entry) => entry.status;
  @override
  Object draftCheckpoint(_State v) => (
    v.draftId,
    v.dateTimeDraft.date,
    v.dateTimeDraft.hour,
    v.dateTimeDraft.minute,
    v.latitude,
    v.longitude,
    v.place,
    v.isConfirmed,
  );
  @override
  bool isEditable(_State? value) =>
      value != null &&
      !value.busy &&
      _ports.editable &&
      value.submissionStatus != _Status.sending;
  @override
  _State withBusy(_State value, bool busy) => value.copyWith(busy: busy);
  @override
  _State withSubmissionStatus(_State value, _Status? status) => status == null
      ? value.copyWith(clearSubmissionStatus: true)
      : value.copyWith(submissionStatus: status);
  @override
  _State? confirmedByQueue(_State value, _Entry entry) => entry.receipt == null
      ? null
      : value.copyWith(
          receipt: entry.receipt,
          submissionStatus: entry.status,
          dirty: false,
          clearIssue: true,
        );
  @override
  _State withEventDetails(
    _State value, {
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
    place: placeReference,
    dirty: dirty,
    clearIssue: true,
  );
  @override
  _State withDraftIssue(_State value, ReportDraftIssue issue) =>
      value.copyWith(issue: issue);
  @override
  bool hasDraftIssue(_State value, ReportDraftIssue issue) =>
      value.issue == issue;
  @override
  _State withoutIssue(_State value) => value.copyWith(clearIssue: true);
  @override
  bool isConflict(Object error) => error is _Conflict;
  @override
  bool canDiscardLocalDraft(_State value) =>
      super.canDiscardLocalDraft(value) && _ports.discardable;
  @override
  Future<bool> releaseBeforeDiscard(_State value) async {
    _ports.calls.add('release ${value.draftId}');
    return _ports.release;
  }
}

void main() {
  late _Ports ports;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<_State>> subscription;

  _State read() => container.read(_editorProvider).requireValue;
  _Editor editor() => container.read(_editorProvider.notifier);

  setUp(() async {
    ports = _Ports();
    container = ProviderContainer(
      overrides: [_portsProvider.overrideWithValue(ports)],
    );
    subscription = container.listen(_editorProvider, (_, _) {});
    await container.read(_editorProvider.future);
  });
  tearDown(() async {
    await ports.queue.close();
    container.dispose();
  });

  test(
    'saves each new checkpoint once and removes it once confirmed',
    () async {
      expect(ports.calls, isEmpty, reason: 'An untouched editor is not saved.');
      editor().chooseDate(DateTime(2026, 1, 2));
      await pumpEventQueue();
      expect(ports.calls, ['save slot-A d1']);

      // Same checkpoint (only the queue status changes): no second save.
      ports.queue.add([const _Entry('d1', _Status.pending)]);
      await pumpEventQueue();
      expect(read().submissionStatus, _Status.pending);
      expect(ports.calls, ['save slot-A d1']);

      ports.queue.add([
        const _Entry('d1', _Status.pending, receipt: 'published-1'),
      ]);
      await pumpEventQueue();
      expect(read().isConfirmed, isTrue);
      expect(read().dirty, isFalse);
      expect(ports.calls, ['save slot-A d1', 'remove owner slot-A d1']);
    },
  );

  test('queue status follows only the edited command', () async {
    ports.queue.add([const _Entry('other', _Status.sending)]);
    await pumpEventQueue();
    expect(read().submissionStatus, isNull);

    ports.queue.add([const _Entry('d1', _Status.sending)]);
    await pumpEventQueue();
    expect(read().submissionStatus, _Status.sending);

    ports.queue.addError(StateError('queue unavailable'));
    await pumpEventQueue();
    expect(read().submissionStatus, _Status.sending, reason: 'Errors keep it.');

    ports.queue.add(const []);
    await pumpEventQueue();
    expect(read().submissionStatus, isNull);
  });

  test('a busy editor ignores queue updates until it is idle again', () async {
    ports.holdCancels = true;
    final discard = editor().discardLocalDraft('d1');
    expect(read().busy, isTrue);
    ports.queue.add([const _Entry('d1', _Status.pending)]);
    await pumpEventQueue();
    expect(read().submissionStatus, isNull);

    ports.cancelError = _Conflict();
    ports.cancelGates.single.complete();
    expect(await discard, isFalse);
    await pumpEventQueue();
    // Leaving busy re-applies the latest queue snapshot.
    expect(read().busy, isFalse);
    expect(read().submissionStatus, _Status.pending);
  });

  test('a slow save of an old generation never marks the new one', () async {
    ports.holdSaves = true;
    editor().chooseDate(DateTime(2026, 1, 2));
    await pumpEventQueue();
    final stale = read();
    // The rebuilt editor restores identical content: only the generation differs.
    ports.restore = stale;
    container.invalidate(_editorProvider);
    await container.read(_editorProvider.future);
    await pumpEventQueue();
    expect(ports.saveGates, hasLength(2));

    ports.saveGates.first.completeError(StateError('disk full'));
    await pumpEventQueue();
    expect(read().issue, isNull);

    ports.saveGates.last.completeError(StateError('disk full'));
    await pumpEventQueue();
    expect(read().issue, ReportDraftIssue.localStorage);
  });

  test('pending operations keep the autoDispose editor alive', () async {
    ports.holdSaves = true;
    editor().chooseDate(DateTime(2026, 1, 2));
    await pumpEventQueue();
    subscription.close();
    await pumpEventQueue();
    expect(container.exists(_editorProvider), isTrue);

    ports.saveGates.single.complete();
    await pumpEventQueue();
    expect(container.exists(_editorProvider), isFalse);
  });

  test(
    'saveForLater reports a storage failure and clears it on retry',
    () async {
      ports.saveError = StateError('disk full');
      editor().chooseTime(9, 30);
      await pumpEventQueue();
      expect(read().issue, ReportDraftIssue.localStorage);

      expect(await editor().saveForLater(), isFalse);
      expect(read().issue, ReportDraftIssue.localStorage);

      ports.saveError = null;
      expect(await editor().saveForLater(), isTrue);
      expect(read().issue, isNull);
      expect(read().dateTimeDraft.hour, 9);
    },
  );

  test(
    'discard cancels, releases and removes in order, then restarts',
    () async {
      editor().chooseDate(DateTime(2026, 1, 2));
      await pumpEventQueue();
      ports.calls.clear();

      expect(await editor().discardLocalDraft('another-draft'), isFalse);
      expect(ports.calls, isEmpty);

      expect(await editor().discardLocalDraft('d1'), isTrue);
      expect(ports.calls, [
        'cancel owner d1',
        'release d1',
        'remove owner slot-A d1',
      ]);
      final restarted = await container.read(_editorProvider.future);
      expect(restarted.draftId, 'd2');
      expect(restarted.dirty, isFalse);
    },
  );

  test('discard maps failures and keeps the draft when refused', () async {
    ports.cancelError = _Conflict();
    expect(await editor().discardLocalDraft('d1'), isFalse);
    expect(read().issue, ReportDraftIssue.conflict);
    expect(read().busy, isFalse);

    ports.cancelError = StateError('disk');
    expect(await editor().discardLocalDraft('d1'), isFalse);
    expect(read().issue, ReportDraftIssue.localStorage);

    ports
      ..cancelError = null
      ..release = false
      ..calls.clear();
    expect(await editor().discardLocalDraft('d1'), isFalse);
    expect(ports.calls, ['cancel owner d1', 'release d1']);
    expect(read().draftId, 'd1');

    ports
      ..discardable = false
      ..calls.clear();
    expect(await editor().discardLocalDraft('d1'), isFalse);
    expect(ports.calls, isEmpty);
  });

  test('a second discard while busy is refused', () async {
    ports.holdCancels = true;
    final first = editor().discardLocalDraft('d1');
    expect(await editor().discardLocalDraft('d1'), isFalse);
    expect(ports.calls, ['cancel owner d1']);
    ports.cancelGates.single.complete();
    expect(await first, isTrue);
  });

  test('a discard of an old generation neither removes nor restarts', () async {
    ports.holdCancels = true;
    final discard = editor().discardLocalDraft('d1');
    await pumpEventQueue();
    container.invalidate(_editorProvider);
    final rebuilt = await container.read(_editorProvider.future);
    ports.cancelGates.single.complete();
    expect(await discard, isFalse);
    expect(ports.calls, ['cancel owner d1']);
    expect(read().draftId, rebuilt.draftId);
  });

  test('date, time and report details respect the editable guard', () async {
    ports.editable = false;
    editor().chooseDate(DateTime(2026, 1, 2));
    editor().chooseTime(9, 30);
    expect(read().dirty, isFalse);
    expect(read().dateTimeDraft.date, isNull);

    ports.editable = true;
    editor().chooseDate(DateTime(2026, 1, 2, 23, 59));
    editor().chooseTime(9, 30);
    expect(read().dateTimeDraft.value, DateTime(2026, 1, 2, 9, 30));
    expect(read().dirty, isTrue);

    editor().restoreReportDetails(
      ownerId: 'someone-else',
      dateTime: const EventDateTimeDraft(),
      latitude: 1,
      longitude: 2,
      placeReference: 'Parque',
    );
    expect(read().place, isEmpty);

    editor().restoreReportDetails(
      ownerId: 'owner',
      dateTime: const EventDateTimeDraft(),
      latitude: -12,
      longitude: -77,
      placeReference: 'Parque',
    );
    expect(
      (read().latitude, read().longitude, read().place),
      (-12.0, -77.0, 'Parque'),
    );
    editor().restoreReportDetails(
      ownerId: 'owner',
      dateTime: const EventDateTimeDraft(),
      latitude: null,
      longitude: null,
      placeReference: '',
    );
    expect(read().latitude, isNull, reason: 'No coordinates clear the point.');
  });

  test('restoring empty details keeps an untouched editor clean', () async {
    editor().restoreReportDetails(
      ownerId: 'owner',
      dateTime: const EventDateTimeDraft(),
      latitude: null,
      longitude: null,
      placeReference: '',
    );
    expect(read().dirty, isFalse);
    await pumpEventQueue();
    expect(ports.calls, isEmpty);
  });
}
