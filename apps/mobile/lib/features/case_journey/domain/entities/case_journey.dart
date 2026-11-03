typedef JourneyTarget = ({String id, bool community});

class JourneyCaseSummary {
  const JourneyCaseSummary({this.name = '', this.traits = '', this.photoUri});
  final String name, traits;
  final Uri? photoUri;
}

class JourneyPoint {
  const JourneyPoint({
    required this.id,
    required this.time,
    required this.latitude,
    required this.longitude,
    this.inCustody = false,
  });
  final String id;
  final DateTime time;
  final double latitude, longitude;
  final bool inCustody;
  String get key => 'public:$id';
}

class CaseJourney {
  CaseJourney({
    required this.target,
    required this.origin,
    required List<JourneyPoint> points,
    this.summary = const JourneyCaseSummary(),
  }) : points = List.unmodifiable(points);
  final JourneyTarget target;
  final JourneyPoint origin;
  final JourneyCaseSummary summary;
  final List<JourneyPoint> points;
  DateTime? get latest => points.isEmpty ? null : points.last.time;
  String get countLabel {
    if (points.isEmpty) return 'Sin avistamientos';
    final sightingsOnly = points.every((point) => !point.inCustody);
    final noun = sightingsOnly
        ? (points.length == 1 ? 'avistamiento' : 'avistamientos')
        : (points.length == 1 ? 'aviso' : 'avisos');
    return '${points.length} $noun';
  }
}
