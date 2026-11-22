/// Presentation-only map service configuration; contains no credentials or location.
class MapConfig {
  const MapConfig._();

  /// Defaults to CARTO Positron (ADR-104), so builds without MAP_TILE_URL
  /// keep the approved style and its attribution, and never load the OSM
  /// community tile servers whose policy excludes app traffic.
  static const tileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue:
        'https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png',
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
