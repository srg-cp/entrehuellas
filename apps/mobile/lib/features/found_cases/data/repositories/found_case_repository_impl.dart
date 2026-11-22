import 'dart:typed_data';
import '../../../../core/data_sources/photo_gallery_source.dart';
import '../../domain/entities/found_case.dart';
import '../../domain/repositories/found_case_repository.dart';
import '../data_sources/found_case_data_source.dart';

class FoundCaseRepositoryImpl implements FoundCaseRepository {
  const FoundCaseRepositoryImpl(this._source, this._gallery);
  final FoundCaseDataSource _source;
  final PhotoGallerySource _gallery;
  Future<T> _run<T>(Future<T> Function() work) async {
    try {
      return await work();
    } on FoundSourceFailure catch (e) {
      throw FoundFailure(e.kind);
    } on PhotoGalleryFailure catch (e) {
      throw FoundFailure(
        e.kind == PhotoGalleryFailureKind.invalidPhoto
            ? FoundFailureKind.photoInvalid
            : FoundFailureKind.gallery,
      );
    } catch (_) {
      throw const FoundFailure(FoundFailureKind.unavailable);
    }
  }

  @override
  Future<Uint8List?> choosePhoto(
    String owner,
    String id, {
    bool camera = false,
  }) => _run(() => _gallery.choose(owner, id, false, camera: camera));
  @override
  Future<Uint8List?> recoverPhoto(String owner, String id) =>
      _run(() => _gallery.recover(owner, id, false));
  @override
  Future<FoundPublication> publish(String owner, FoundCaseDraft d) =>
      _run(() async => (await _source.publish(owner, d)).publication());
  @override
  Future<PublicFoundCase?> readPublic(String id) => _run(() async {
    final dto = await _source.readPublic(id);
    if (dto == null) return null;
    final refs = dto.photoRefs;
    final uris = await _source.photoUris([for (final r in refs) r.path]);
    return dto.publicCase([
      for (final r in refs) FoundPhoto(r.id, uris[r.path]),
    ]);
  });
  @override
  Future<List<FoundPublication>> listMine(String owner) => _run(() async {
    final dtos = await _source.listMine(owner);
    final covers = await _source.photoUris(
      dtos.map((d) => d.coverPath).nonNulls.toList(),
    );
    return [
      for (final d in dtos)
        d.publication(
          coverUri: d.coverPath == null ? null : covers[d.coverPath],
        ),
    ];
  });
  @override
  Future<void> discard(String owner, String id) =>
      _run(() => _source.discard(owner, id));
  @override
  Future<List<PublicFoundCase>> listObservations(String id, bool community) =>
      _run(() async {
        final dtos = await _source.listObservations(id, community);
        final uris = await _source.photoUris([
          for (final dto in dtos)
            for (final r in dto.photoRefs) r.path,
        ]);
        return [
          for (final dto in dtos)
            dto.publicCase([
              for (final r in dto.photoRefs) FoundPhoto(r.id, uris[r.path]),
            ]),
        ];
      });
  @override
  Future<List<RecoverySearch>> listOpenSearches(String owner) => _run(
    () async => (await _source.listOpenSearches(owner))
        .map(
          (row) => RecoverySearch(
            id: row['id'] as String,
            community: row['community'] as bool,
            name: row['name'] as String,
            species: row['species'] as String,
            speciesDetail: row['species_detail'] as String?,
            size: row['size'] as String?,
            sex: row['sex'] as String?,
          ),
        )
        .toList(),
  );
  @override
  Future<void> resolveSearch(String owner, String id, bool community) =>
      _run(() => _source.resolveSearch(owner, id, community));
  @override
  Future<void> delete(String owner, String id) =>
      _run(() => _source.delete(owner, id));
}
