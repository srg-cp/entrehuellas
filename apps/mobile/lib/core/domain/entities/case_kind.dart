/// The two publication families. [name] is the wire/route value
/// (`lost`, `found`) shared with SQL, deep links and local drafts.
enum CaseKind {
  lost,
  found;

  static CaseKind? tryParse(String? value) => switch (value) {
    'lost' => CaseKind.lost,
    'found' => CaseKind.found,
    _ => null,
  };

  /// Found reports are the community cases (`community: true` in targets).
  bool get isCommunity => this == CaseKind.found;

  static CaseKind fromCommunity(bool community) =>
      community ? CaseKind.found : CaseKind.lost;
}

/// Identity of one lost or found case.
typedef CaseRef = ({CaseKind kind, String id});

/// Route/feature target of a case where `community: true` means found.
/// Closure, journey and timeline share this single definition.
typedef CommunityCaseTarget = ({String id, bool community});
