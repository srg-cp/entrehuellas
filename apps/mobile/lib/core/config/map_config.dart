/// Presentation-only map service configuration; contains no credentials or location.
class MapConfig {
  const MapConfig._();
  static const tileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static bool get usesCarto =>
      Uri.tryParse(tileUrl)?.host == 'basemaps.cartocdn.com';

  /// Native retina keeps the same geographic tile and request count.
  /// Leave other providers' URL contracts untouched (no emulated retina).
  static String nativeRetinaTemplate(String template) {
    if (Uri.tryParse(template)?.host != 'basemaps.cartocdn.com' ||
        template.contains('{r}') ||
        template.contains('@2x')) {
      return template;
    }
    return template.replaceFirst(RegExp(r'\.png(?=\?|$)'), '{r}.png');
  }

  static String get displayTileUrl => nativeRetinaTemplate(tileUrl);
}
