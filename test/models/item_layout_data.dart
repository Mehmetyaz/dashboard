import 'package:dashboard/dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("item_layout_data", () {
    var item = ItemLayoutData(
        startX: 0,
        endX: 5,
        startY: 0,
        endY: 4,
        additionalData: {"a": 5, "b": 4});
    expect(item.width, 5);
    expect(item.height, 4);
    expect(item.additionalData, {"a": 5, "b": 4});

    var item2 = ItemLayoutData.fromSWH(
        startX: 0,
        startY: 0,
        width: 5,
        height: 4,
        additionalData: {"a": 5, "b": 4});
    expect(item2.endX, 5);
    expect(item2.endY, 4);
    expect(item2.additionalData, {"a": 5, "b": 4});
  });

  test("item_layout_data_db_integrations", () {
    var item = ItemLayoutData(
        startX: 0,
        endX: 5,
        startY: 0,
        endY: 4,
        additionalData: {"a": 5, "b": 4});

    var itemMap = item.toMap();

    expect(itemMap, {
      "s_X": 0,
      "s_Y": 0,
      "w": 5,
      "h": 4,
      "add": {"a": 5, "b": 4}
    });

    var nItem = ItemLayoutData.fromMap(itemMap);

    expect(nItem.width, 5);
    expect(nItem.height, 4);
    expect(nItem.endX, 5);
    expect(nItem.endY, 4);
    expect(nItem.additionalData, {"a": 5, "b": 4});
  });
}
