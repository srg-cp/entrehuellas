import '../../domain/entities/found_case.dart';
import '../models/found_case_dto.dart';

class FoundSourceFailure implements Exception {
  const FoundSourceFailure(this.kind);
  final FoundFailureKind kind;
}

abstract interface class FoundCaseDataSource {
  Future<FoundCaseDto> publish(String owner, FoundCaseDraft draft);
  Future<FoundCaseDto?> readPublic(String id);

  /// One signed URL request for many photos; missing paths are omitted.
  Future<Map<String, Uri>> photoUris(List<String> paths);
  Future<List<FoundCaseDto>> listMine(String owner);
  Future<void> discard(String owner, String id);
  Future<List<FoundCaseDto>> listObservations(String id, bool community);
  Future<List<Map<String, dynamic>>> listOpenSearches(String owner);
  Future<void> resolveSearch(String owner, String id, bool community);
  Future<void> delete(String owner, String id);
}
