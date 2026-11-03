import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../case_timeline/providers/case_timeline_providers.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../case_timeline/domain/entities/case_timeline.dart';
import '../state/case_journey_state.dart';
import '../../providers/case_journey_providers.dart';
import '../../domain/entities/case_journey.dart';

final caseJourneyViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<CaseJourneyViewModel, CaseJourneyState, JourneyTarget>(
      CaseJourneyViewModel.new,
      retry: (_, _) => null,
    );

class CaseJourneyViewModel extends AsyncNotifier<CaseJourneyState> {
  CaseJourneyViewModel(this.target);
  final JourneyTarget target;
  int _generation = 0;
  @override
  Future<CaseJourneyState> build() async {
    _generation++;
    final session = await ref.watch(timelineSessionProvider.future);
    if (session == null) throw const FoundFailure(FoundFailureKind.forbidden);
    return CaseJourneyState(
      owner: session.userId,
      journey: await ref.watch(readCaseJourneyProvider)(session.userId, target),
    );
  }

  void retry() => ref.invalidateSelf();

  Future<void> refresh() async {
    final previous = state.asData?.value;
    if (previous == null || state.isLoading || previous.refreshing) return;
    final generation = _generation;
    state = AsyncData(
      CaseJourneyState(
        owner: previous.owner,
        journey: previous.journey,
        refreshing: true,
        notice: previous.notice,
      ),
    );
    try {
      final result = await ref.read(readCaseJourneyProvider)(
        previous.owner,
        target,
      );
      if (!ref.mounted ||
          generation != _generation ||
          state.asData?.value.owner != previous.owner) {
        return;
      }
      state = AsyncData(
        CaseJourneyState(
          owner: previous.owner,
          journey: result,
          notice: previous.notice,
        ),
      );
    } catch (error, trace) {
      if (!ref.mounted ||
          generation != _generation ||
          state.asData?.value.owner != previous.owner) {
        return;
      }
      final forbidden =
          error is FoundFailure && error.kind == FoundFailureKind.forbidden ||
          error is TimelineFailure && error.issue == TimelineIssue.forbidden ||
          error is CaseFailure && error.kind == CaseFailureKind.forbidden;
      state = forbidden
          ? AsyncError(error, trace)
          : AsyncData(
              CaseJourneyState(
                owner: previous.owner,
                journey: previous.journey,
                refreshFailed: true,
                notice: previous.notice + 1,
              ),
            );
    }
  }
}
