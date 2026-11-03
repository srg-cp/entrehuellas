import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import 'local_report_draft.dart';

enum SubmissionStatus { pending, sending, failed, published }

enum SubmissionIssue {
  unavailable,
  conflict,
  invalid,
  forbidden,
  blocked,
  closed,
  photo,
  rateLimited,
  busy,
}

class SubmissionReceipt {
  const SubmissionReceipt.lost(this.lost) : found = null;
  const SubmissionReceipt.found(this.found) : lost = null;
  final PublishedLostCase? lost;
  final FoundPublication? found;
  String get id => lost?.id ?? found!.id;
}

class QueuedReport {
  const QueuedReport({
    required this.command,
    required this.status,
    required this.attempts,
    required this.createdAt,
    required this.nextAttemptAt,
    this.issue,
    this.receipt,
    this.claim,
  });
  final LocalReportDraft command;
  final SubmissionStatus status;
  final int attempts;
  final DateTime createdAt, nextAttemptAt;
  final SubmissionIssue? issue;
  final SubmissionReceipt? receipt;
  final String? claim;
}

class SubmissionFailure implements Exception {
  const SubmissionFailure(this.issue);
  final SubmissionIssue issue;
}
