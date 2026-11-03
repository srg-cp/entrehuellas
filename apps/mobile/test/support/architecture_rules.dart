/// The legacy constructor declaration is allowed, but using it is forbidden.
bool usesRetiredEntryCurtain(String code) => RegExp(
  r'\bCoverReveal(?:\s*\.\s*\w+)?\s*\((?!\s*\{)|\bCoverReveal\s*\.\s*new\b|\bstartCovered\b',
).hasMatch(code);

bool crossesFeatureBoundary(String source, String target) {
  final feature = RegExp(r'/features/([^/]+)/');
  final origin = feature.firstMatch(source)?.group(1);
  final destination = feature.firstMatch(target)?.group(1);
  if (source.contains('/core/') && destination != null) return true;
  return origin != null &&
      destination != null &&
      origin != destination &&
      (target.contains('/presentation/') || target.contains('/data/'));
}
