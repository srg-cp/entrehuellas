typedef TimelineTarget = ({String id, bool community});

enum TimelineIssue {
  unavailable,
  forbidden,
  invalid,
  conflict,
  closed,
  transition,
}

class TimelineFailure implements Exception {
  const TimelineFailure(this.issue);
  final TimelineIssue issue;
}

class TimelineCursor {
  const TimelineCursor(this.time, this.key);
  final DateTime time;
  final String key;
}

class TimelineEvent {
  const TimelineEvent({
    required this.key,
    required this.id,
    required this.kind,
    required this.observedAt,
  });
  final String key, id, kind;
  final DateTime observedAt;
}

class TimelinePage {
  TimelinePage(this.caseStatus, List<TimelineEvent> items, this.next)
    : items = List.unmodifiable(items);
  final String caseStatus;
  final List<TimelineEvent> items;
  final TimelineCursor? next;
}
