import '../../domain/entities/case_timeline.dart';

class CaseTimelineState {
  const CaseTimelineState({
    required this.owner,
    required this.page,
    this.busy = false,
    this.failure,
    this.notice = 0,
  });
  final String owner;
  final TimelinePage page;
  final bool busy;
  final TimelineIssue? failure;
  final int notice;
}

String timelineFailureLabel(TimelineIssue issue) =>
    issue == TimelineIssue.forbidden
    ? 'No tienes acceso a este historial.'
    : 'No pudimos consultar el historial. Reintenta.';
