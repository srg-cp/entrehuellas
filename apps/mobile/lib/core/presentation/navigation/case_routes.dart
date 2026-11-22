import '../../domain/entities/case_kind.dart';

/// Detail route of a lost (`/home/cases`) or found (`/home/found-cases`) case.
String caseDetailRoute(CaseKind kind, String id) =>
    '/home/${kind == CaseKind.lost ? 'cases' : 'found-cases'}/$id';
