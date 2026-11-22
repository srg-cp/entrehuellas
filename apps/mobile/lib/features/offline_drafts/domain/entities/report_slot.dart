/// Editor context of a local draft. The persisted text form ([value]) is a
/// stable storage contract: `lost`, `community-search`, `independent-found`
/// or `found:<community>:<targetId>`.
sealed class ReportSlot {
  const ReportSlot();

  static const lostValue = 'lost';
  static const communitySearchValue = 'community-search';
  static const independentFoundValue = 'independent-found';

  /// Returns null for any text not produced by [value].
  static ReportSlot? tryParse(String raw) {
    switch (raw) {
      case lostValue:
        return const LostReportSlot();
      case communitySearchValue:
        return const CommunitySearchSlot();
      case independentFoundValue:
        return const IndependentFoundSlot();
    }
    final parts = raw.split(':');
    if (parts.length == 3 &&
        parts[0] == 'found' &&
        (parts[1] == 'true' || parts[1] == 'false') &&
        parts[2].isNotEmpty) {
      return FoundTargetSlot(targetId: parts[2], community: parts[1] == 'true');
    }
    return null;
  }

  String get value;

  /// True for every slot published as a found/sighting report.
  bool get isFound => this is! LostReportSlot;
}

final class LostReportSlot extends ReportSlot {
  const LostReportSlot();
  @override
  String get value => ReportSlot.lostValue;
}

/// Search for an unregistered animal, published as a found report.
final class CommunitySearchSlot extends ReportSlot {
  const CommunitySearchSlot();
  @override
  String get value => ReportSlot.communitySearchValue;
}

final class IndependentFoundSlot extends ReportSlot {
  const IndependentFoundSlot();
  @override
  String get value => ReportSlot.independentFoundValue;
}

/// Sighting linked to an existing case; [community] marks a found case.
final class FoundTargetSlot extends ReportSlot {
  const FoundTargetSlot({required this.targetId, required this.community});
  final String targetId;
  final bool community;
  @override
  String get value => 'found:$community:$targetId';
}
