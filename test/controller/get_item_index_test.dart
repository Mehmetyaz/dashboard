import 'package:dashboard/dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var dbIC = DashboardItemController(items: []);
  var dbC = DashboardLayoutController();
  dbC.attach(
      slideToTop: true,
      shrinkToPlace: true,
      axis: Axis.vertical,
      itemController: dbIC,
      slotCount: 4);
  test("get_index_vertical", () {
    var res = dbC.getItemIndexes(
        const ItemLayout(startX: 0, startY: 0, width: 2, height: 2));
    expect(res, [0, 1, 4, 5]);
  });

  test("get_index_horizontal", () {
    var res = dbC.getItemIndexes(
        const ItemLayout(startX: 0, startY: 0, width: 2, height: 2));
    expect(res, [0, 1, 4, 5]);
  });

  test("overflow", () {
    var dbIC = DashboardItemController(
      items: [
        DashboardItem(
            identifier: "1", startX: 0, startY: 0, width: 3, height: 2),
        DashboardItem(
            identifier: "2", startX: 3, startY: 0, width: 3, height: 1),
        DashboardItem(
            identifier: "3", startX: 7, startY: 1, width: 2, height: 1),
        DashboardItem(
            identifier: "4", startX: 6, startY: 2, width: 3, height: 1),
        DashboardItem(
            identifier: "5", startX: 4, startY: 3, width: 3, height: 2)
      ],
    );

    var db = DashboardLayoutController();

    db.attach(
        slideToTop: true,
        shrinkToPlace: true,
        slotCount: 9,
        itemController: dbIC,
        axis: Axis.vertical);

    var o = db.getOverflows(
        const ItemLayout(startX: 3, width: 4, startY: 1, height: 3));

    expect(o, [6, 3]);

    var nLoc = db.tryMount(
        12, const ItemLayout(startX: 3, width: 4, startY: 1, height: 3), "id");

    expect(nLoc!.startX, 3);
    expect(nLoc.startY, 1);
    expect(nLoc.width, 3);
    expect(nLoc.height, 2);
  });

  test("overflow2", () {
    var dbIC = DashboardItemController(items: [
      DashboardItem(identifier: "1", startX: 0, startY: 0, width: 3, height: 2),
      DashboardItem(identifier: "2", startX: 3, startY: 0, width: 3, height: 1),
      DashboardItem(identifier: "3", startX: 5, startY: 1, width: 2, height: 1),
      DashboardItem(identifier: "4", startX: 6, startY: 2, width: 3, height: 1),
      DashboardItem(identifier: "5", startX: 4, startY: 3, width: 3, height: 2)
    ]);

    var db = DashboardLayoutController();

    db.attach(
        slideToTop: true,
        shrinkToPlace: true,
        axis: Axis.vertical,
        itemController: dbIC,
        slotCount: 9);

    var o = db.getOverflows(
        const ItemLayout(startX: 3, width: 4, startY: 1, height: 3));

    expect(o, [5, 3]);

    var nLoc = db.tryMount(
        12, const ItemLayout(startX: 3, width: 4, startY: 1, height: 3), "id");

    expect(nLoc!.startX, 3);
    expect(nLoc.startY, 1);
    expect(nLoc.width, 2);
    expect(nLoc.height, 2);
  });
}
