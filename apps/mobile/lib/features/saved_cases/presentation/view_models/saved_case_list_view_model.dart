import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/failures/saved_case_failure.dart';
import '../../providers/saved_cases_providers.dart';
import '../state/saved_case_list_state.dart';
import '../../../offline_cases/providers/case_cache_providers.dart';

final savedCaseListViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      SavedCaseListViewModel,
      SavedCaseListState
    >(SavedCaseListViewModel.new, retry: (_, _) => null);

class SavedCaseListViewModel extends AsyncNotifier<SavedCaseListState> {
  int _generation = 0;
  bool _failedAppend = false;
  @override
  Future<SavedCaseListState> build() async {
    _generation++;
    ref.onDispose(() => _generation++);
    final session = await ref.watch(savedCasesSessionProvider.future);
    if (session == null) {
      throw const SavedCaseFailure(SavedCaseFailureKind.forbidden);
    }
    try {
      final page = await ref.read(listSavedCasesProvider)(session.userId);
      return SavedCaseListState(
        owner: session.userId,
        items: page.items,
        cursor: page.cursor,
      );
    } on SavedCaseFailure catch (error) {
      if (error.kind != SavedCaseFailureKind.unavailable) rethrow;
      final local = await ref
          .read(listCachedCasesProvider)
          ?.call(session.userId);
      if (local == null || local.isEmpty) rethrow;
      return SavedCaseListState(
        owner: session.userId,
        items: const [],
        offline: true,
      );
    }
  }

  Future<void> refresh() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    if (!current.busy) await _load(current, false);
  }

  Future<void> more() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null || current.busy || current.cursor == null) return;
    await _load(current, true);
  }

  Future<void> retry() => _failedAppend ? more() : refresh();
  Future<void> _load(SavedCaseListState old, bool append) async {
    final generation = ++_generation;
    _failedAppend = append;
    state = AsyncData(
      SavedCaseListState(
        owner: old.owner,
        items: old.items,
        cursor: old.cursor,
        refreshing: !append,
        appending: append,
        noticeId: old.noticeId,
        offline: old.offline,
      ),
    );
    try {
      final page = await ref.read(listSavedCasesProvider)(
        old.owner,
        cursor: append ? old.cursor : null,
      );
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      if (append && page.cursor == old.cursor) {
        throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
      }
      state = AsyncData(
        SavedCaseListState(
          owner: old.owner,
          items: append
              ? [
                  ...old.items,
                  ...page.items.where(
                    (item) => !old.items.any((prior) => prior.key == item.key),
                  ),
                ]
              : page.items,
          cursor: page.cursor,
          noticeId: old.noticeId,
        ),
      );
    } catch (_) {
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        SavedCaseListState(
          owner: old.owner,
          items: old.items,
          cursor: old.cursor,
          failed: true,
          offline: old.offline,
          notice:
              'No pudimos consultar tus casos guardados. Puedes reintentar.',
          noticeId: old.noticeId + 1,
        ),
      );
    }
  }
}
