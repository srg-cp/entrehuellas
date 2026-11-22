/// Server status values of a lost/found case. Kept as text in entities so a
/// new server state never breaks parsing; compare through these constants.
abstract final class CaseStatus {
  static const active = 'active';
  static const resolved = 'resolved';
}
