import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/case_changes.dart';
import '../domain/use_cases/notify_case_changed.dart';

// Owned by ProviderScope; listeners are released by each screen ViewModel.
final caseChangesProvider = Provider((ref) {
  final changes = CaseChanges();
  ref.onDispose(changes.dispose);
  return changes;
});

final notifyCaseChangedProvider = Provider(
  (ref) => NotifyCaseChanged(ref.watch(caseChangesProvider)),
);
