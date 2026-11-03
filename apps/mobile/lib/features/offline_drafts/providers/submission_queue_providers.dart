import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lost_cases/providers/lost_case_providers.dart';
import '../../found_cases/providers/found_case_providers.dart';
import '../domain/use_cases/submission_transport.dart';
import '../domain/use_cases/dispatch_queued_reports.dart';
import 'local_draft_providers.dart';

final submissionTransportProvider = Provider(
  (ref) => SubmissionTransport(
    () => ref.read(publishLostCaseProvider),
    () => ref.read(publishFoundCaseProvider),
  ),
);
final dispatchQueuedReportsProvider = Provider(
  (ref) => DispatchQueuedReports(
    ref.watch(localDraftRepositoryProvider),
    ref.watch(submissionTransportProvider),
  ),
);
final queuedReportsProvider = StreamProvider.autoDispose.family(
  (ref, String owner) =>
      ref.watch(localDraftRepositoryProvider).watchQueue(owner),
  retry: (_, _) => null,
);
