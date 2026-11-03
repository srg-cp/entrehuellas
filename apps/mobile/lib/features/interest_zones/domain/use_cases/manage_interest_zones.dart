import '../entities/interest_zone.dart';
import '../entities/zone_point.dart';
import '../failures/zone_failure.dart';
import '../repositories/interest_zone_repository.dart';

class ListInterestZones {
  const ListInterestZones(this.repository);
  final InterestZoneRepository repository;
  Future<List<InterestZone>> call(String ownerId) async {
    if (ownerId.isEmpty) throw const ZoneFailure(ZoneFailureKind.signedOut);
    final zones = await repository.list(ownerId);
    if (zones.any((zone) => zone.ownerId != ownerId)) {
      throw const ZoneFailure(ZoneFailureKind.unavailable);
    }
    return List.unmodifiable(zones);
  }
}

class SaveInterestZone {
  const SaveInterestZone(this.repository);
  final InterestZoneRepository repository;
  Future<InterestZone> call(String ownerId, ZoneDraft draft) async {
    if (ownerId.isEmpty) throw const ZoneFailure(ZoneFailureKind.signedOut);
    final enteredName = draft.name.trim();
    if (enteredName.runes.length > 60) {
      throw const ZoneFailure(ZoneFailureKind.invalidName);
    }
    final point = ZonePoint(draft.latitude, draft.longitude);
    if (draft.radiusMeters < 100 || draft.radiusMeters > 50000) {
      throw const ZoneFailure(ZoneFailureKind.invalidRadius);
    }
    // Keep the existing server contract and deterministic retry payload while
    // allowing the user to select a point without typing a name.
    final name = enteredName.isEmpty
        ? 'Ubicación (${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)})'
        : enteredName;
    final zone = await repository.save(ownerId, draft.copyWith(name: name));
    if (zone.ownerId != ownerId || zone.id != draft.id) {
      throw const ZoneFailure(ZoneFailureKind.unavailable);
    }
    return zone;
  }
}

class DeleteInterestZone {
  const DeleteInterestZone(this.repository);
  final InterestZoneRepository repository;
  Future<void> call(String ownerId, InterestZone zone) {
    if (ownerId.isEmpty) throw const ZoneFailure(ZoneFailureKind.signedOut);
    if (zone.ownerId != ownerId) {
      throw const ZoneFailure(ZoneFailureKind.unavailable);
    }
    return repository.delete(ownerId, zone);
  }
}
