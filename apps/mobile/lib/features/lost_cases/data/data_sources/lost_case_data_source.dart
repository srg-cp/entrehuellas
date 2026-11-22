import '../../domain/entities/lost_case.dart';
import '../models/lost_case_dto.dart';

abstract interface class LostCaseDataSource {
  Future<LostCaseDto> publish(String owner, LostCaseDraft draft);
  Future<LostCaseDto?> readPublic(String id);
  Future<List<LostCaseDto>> listMine(String owner);

  /// One signed URL request for many photos; missing paths are omitted.
  Future<Map<String, Uri>> photoUris(List<String> paths);
  Future<void> delete(String owner, String id);
}

class CaseSourceFailure implements Exception {
  const CaseSourceFailure(this.kind);
  final CaseFailureKind kind;
}
