import '../../domain/entities/lost_case.dart';
import '../../domain/repositories/lost_case_repository.dart';
import '../data_sources/lost_case_data_source.dart';

class LostCaseRepositoryImpl implements LostCaseRepository {
  const LostCaseRepositoryImpl(this._source);
  final LostCaseDataSource _source;
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CaseSourceFailure catch (e) {
      throw CaseFailure(e.kind);
    } on CaseFailure {
      rethrow;
    } catch (_) {
      throw const CaseFailure(CaseFailureKind.unavailable);
    }
  }

  @override
  Future<PublishedLostCase> publish(String owner, LostCaseDraft draft) =>
      _run(() async => (await _source.publish(owner, draft)).toPublished());
  @override
  Future<List<PublishedLostCase>> listMine(String owner) => _run(() async {
    final dtos = await _source.listMine(owner);
    final covers = await _source.photoUris(
      dtos.map((dto) => dto.coverPath).nonNulls.toList(),
    );
    return [
      for (final dto in dtos)
        dto.toPublished(
          coverUri: dto.coverPath == null ? null : covers[dto.coverPath],
        ),
    ];
  });
  @override
  Future<PublicLostCase?> readPublic(String id) async {
    return _run(() async {
      final dto = await _source.readPublic(id);
      if (dto == null) return null;
      final refs = dto.photoRefs;
      final uris = await _source.photoUris([for (final r in refs) r.path]);
      return dto.toPublic([
        for (final r in refs) CasePhoto(id: r.id, uri: uris[r.path]),
      ]);
    });
  }

  @override
  Future<void> delete(String owner, String id) =>
      _run(() => _source.delete(owner, id));
}
