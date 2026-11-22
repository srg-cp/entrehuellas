import 'enum_parsing.dart';
import '../../domain/entities/case_kind.dart';
import 'dart:convert';
import '../../domain/entities/public_case_card.dart';

class PublicCasePageDto {
  const PublicCasePageDto(this.row);
  final Map<String, dynamic> row;
  List<Map<String, dynamic>> get items => (row['items'] as List)
      .map((v) => Map<String, dynamic>.from(v as Map))
      .toList();
  String? get nextCursor =>
      row['next_cursor'] == null ? null : jsonEncode(row['next_cursor']);

  /// Null for a row whose kind/status this build does not know yet.
  static PublicCaseCard? toEntity(Map<String, dynamic> r, Uri? cover) {
    final kind = enumByNameOrNull(PublicCaseKind.values, r['kind']);
    final status = enumByNameOrNull(PublicCaseStatus.values, r['status']);
    if (kind == null || status == null) return null;
    return PublicCaseCard(
      id: r['id'] as String,
      reportKind: r['report_kind'] as String? ?? 'own_loss',
      fromPet: r['source'] == CaseKind.lost.name,
      kind: kind,
      status: status,
      species: r['species'] as String,
      name: r['name'] as String,
      traits: r['traits'] as String,
      occurredAt: DateTime.parse(r['occurred_at'] as String),
      latitude: (r['latitude'] as num).toDouble(),
      longitude: (r['longitude'] as num).toDouble(),
      distanceMeters: (r['distance_meters'] as num?)?.round(),
      coverUri: cover,
    );
  }
}
