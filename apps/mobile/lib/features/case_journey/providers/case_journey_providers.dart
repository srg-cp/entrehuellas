import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lost_cases/providers/lost_case_providers.dart';
import '../../found_cases/providers/found_case_providers.dart';
import '../domain/use_cases/read_case_journey.dart';

final readCaseJourneyProvider = Provider(
  (ref) => ReadCaseJourney(
    ref.watch(lostCaseRepositoryProvider),
    ref.watch(foundCaseRepositoryProvider),
  ),
);
