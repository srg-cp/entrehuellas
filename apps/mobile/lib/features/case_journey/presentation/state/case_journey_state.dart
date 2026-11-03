import '../../domain/entities/case_journey.dart';

class CaseJourneyState {
  const CaseJourneyState({
    required this.owner,
    required this.journey,
    this.refreshing = false,
    this.refreshFailed = false,
    this.notice = 0,
  });
  final String owner;
  final CaseJourney journey;
  final bool refreshing, refreshFailed;
  final int notice;
}
