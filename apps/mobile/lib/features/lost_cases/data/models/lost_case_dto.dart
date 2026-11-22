import '../../../../core/data/models/enum_parsing.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../domain/entities/lost_case.dart';

class LostCaseDto {
  const LostCaseDto(this.row);
  final Map<String, dynamic> row;
  String? get coverPath => row['cover_path'] as String?;

  /// Storage paths of the case photos, in display order.
  List<({String id, String path})> get photoRefs => [
    for (final photo
        in (row['photos'] as List? ?? const []).cast<Map<String, dynamic>>())
      (id: photo['id'] as String, path: photo['path'] as String),
  ];
  PublishedLostCase toPublished({Uri? coverUri}) => PublishedLostCase(
    id: row['id'] as String,
    ownerId: row['owner_id'] as String,
    petId: row['pet_id'] as String,
    status: row['status'] as String,
    coverUri: coverUri,
    petName: row['pet_name'] as String? ?? '',
  );
  PublicLostCase toPublic(List<CasePhoto> photos) => PublicLostCase(
    id: row['id'] as String,
    status: row['status'] as String,
    canResolve: row['can_resolve'] as bool? ?? false,
    occurredAt: DateTime.parse(row['occurred_at'] as String),
    latitude: (row['latitude'] as num).toDouble(),
    longitude: (row['longitude'] as num).toDouble(),
    fields: PetFields(
      name: row['pet_name'] as String,
      species: enumByNameOrNull(PetSpecies.values, row['species']),
      speciesDetail: row['species_detail'] as String?,
      size: enumByNameOrNull(PetSize.values, row['size']),
      sex: enumByNameOrNull(PetSex.values, row['sex']),
      ageMonths: row['age_months'] as int,
      traits: row['traits'] as String,
    ),
    photos: photos,
  );
}
