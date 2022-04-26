part of dashboard;

/// A dashboard consists of [DashboardItem]s.
/// [DashboardItem] holds item identifier([identifier]) and [layoutData].
///
class DashboardItem {
  DashboardItem(
      {int startX = 0,
      int startY = 0,
      required int width,
      required int height,
      int minWidth = 1,
      int minHeight = 1,
      int? maxHeight,
      int? maxWidth,
      required this.identifier})
      : layoutData = ItemLayout(
            startX: startX,
            startY: startY,
            width: width,
            height: height,
            maxHeight: maxHeight,
            maxWidth: maxWidth,
            minWidth: minWidth,
            minHeight: minHeight);

  DashboardItem.withLayout(this.identifier, this.layoutData);

  factory DashboardItem.fromMap(Map<String, dynamic> map) {
    return DashboardItem.withLayout(
        map["item_id"], ItemLayout.fromMap(map["layout"]));
  }

  ItemLayout layoutData;

  String identifier;

  Map<String, dynamic> toMap() {
    return {"item_id": identifier, "layout": layoutData.toMap()};
  }
}
