import 'dart:async';

import '../entities/case_kind.dart';

/// A confirmed mutation of one case. [lifecycle] marks status changes
/// (closure, recovery); otherwise it is new activity on an open case.
typedef CaseChange = ({CaseKind kind, String id, bool lifecycle});

/// Scope-owned notifications after confirmed case mutations. Screens that show
/// the case refresh themselves, so callers never need to know which features
/// display it.
class CaseChanges {
  final _events = StreamController<CaseChange>.broadcast(sync: true);
  Stream<CaseChange> get changes => _events.stream;
  void notify(CaseChange change) => _events.add(change);
  Future<void> dispose() => _events.close();
}
