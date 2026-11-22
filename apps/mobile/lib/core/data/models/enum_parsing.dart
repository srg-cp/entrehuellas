/// Server enums may gain values before the app updates. Unknown or missing
/// values become null instead of failing the whole read; callers decide how
/// to treat them (optional field, or skip the row). Never invent a value.
T? enumByNameOrNull<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
