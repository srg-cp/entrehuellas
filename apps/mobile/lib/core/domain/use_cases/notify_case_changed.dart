import '../entities/case_kind.dart';
import '../services/case_changes.dart';

class NotifyCaseChanged {
  const NotifyCaseChanged(this._changes);
  final CaseChanges _changes;
  void call(CaseKind kind, String id, {bool lifecycle = false}) =>
      _changes.notify((kind: kind, id: id, lifecycle: lifecycle));
}
