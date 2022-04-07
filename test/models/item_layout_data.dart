import 'package:dashboard/dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("item_layout_data", () {
    var item = const ItemLayout(
      startX: 0,
      width: 5,
      startY: 0,
      height: 4,
    );
    expect(item.width, 5);
    expect(item.height, 4);

    var item2 = const ItemLayout(startX: 0, startY: 0, width: 5, height: 4);
    expect(item2.width, 5);
    expect(item2.height, 4);
  });

  test("item_layout_data_db_integrations", () {
    var item = const ItemLayout(startX: 0, width: 5, startY: 0, height: 4);

    var itemMap = item.toMap();

    expect(itemMap, {"s_X": 0, "s_Y": 0, "w": 5, "h": 4});

    var nItem = ItemLayout.fromMap(itemMap);

    expect(nItem.width, 5);
    expect(nItem.height, 4);
  });
}
