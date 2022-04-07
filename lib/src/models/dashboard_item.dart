part of dashboard;

/// A dashboard consists of [DashboardItem]s.
/// [DashboardItem] holds item identifier([identifier]) and [layoutData].
///
class DashboardItem<T> {
  DashboardItem(
      {int startX = 0,
      int startY = 0,
      required int width,
      required int height,
      int minWidth = 1,
      int minHeight = 1,
      int? maxHeight,
      int? maxWidth,
      required this.identifier,
      this.data})
      : layoutData = ItemLayout(
            startX: startX,
            startY: startY,
            width: width,
            height: height,
            maxHeight: maxHeight,
            maxWidth: maxWidth,
            minWidth: minWidth,
            minHeight: minHeight);

  T? data;

  ItemLayout layoutData;

  String identifier;
}
