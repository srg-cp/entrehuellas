import '../../../../core/domain/entities/public_case_card.dart';

class SavedCaseListState {
  SavedCaseListState({
    required this.owner,
    required List<PublicCaseCard> items,
    this.cursor,
    this.refreshing = false,
    this.appending = false,
    this.failed = false,
    this.notice,
    this.noticeId = 0,
    this.offline = false,
  }) : items = List.unmodifiable(items);
  final String owner;
  final bool offline;
  final List<PublicCaseCard> items;
  final String? cursor, notice;
  final bool refreshing, appending, failed;
  final int noticeId;
  bool get busy => refreshing || appending;
}
