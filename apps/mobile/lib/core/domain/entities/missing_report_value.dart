/// Editors check an unfinished form with the same domain validator used for
/// publishing. Values the user has not entered yet are represented by these
/// markers, which the lost/found validators always reject as invalid fields
/// (date before 2000, non-finite coordinates). Never sent to the server.
abstract final class MissingReportValue {
  static final occurredAt = DateTime.utc(1999);
  static const coordinate = double.nan;
}
