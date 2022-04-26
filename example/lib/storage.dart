
import 'dart:async';
import 'dart:convert';

import 'package:dashboard/dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColoredDashboardItem extends DashboardItem {
  ColoredDashboardItem(
      {required this.color,
        required int width,
        required int height,
        required String identifier,
        int minWidth = 1,
        int minHeight = 1,
        int? maxHeight,
        int? maxWidth})
      : super(
      width: width,
      height: height,
      identifier: identifier,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      minWidth: minWidth,
      minHeight: minHeight);

  ColoredDashboardItem.fromMap(Map<String, dynamic> map)
      : color = Color(map["color"]),
        super.withLayout(map["item_id"], ItemLayout.fromMap(map["layout"]));

  Color color;

  @override
  Map<String, dynamic> toMap() {
    var sup = super.toMap();
    sup["color"] = color.value;
    return sup;
  }
}

class MyItemStorage extends DashboardItemStorageDelegate<ColoredDashboardItem> {
  late SharedPreferences _preferences;

  Map<String, dynamic>? _items;

  @override
  FutureOr<List<ColoredDashboardItem>> getAllItems(int slotCount) async {
    //await Future.delayed(const Duration(milliseconds: 1000));
    try {
      if (_items != null) {
        return _items!.values
            .map((value) => ColoredDashboardItem.fromMap(value))
            .toList();
      }

      _preferences = await SharedPreferences.getInstance();

      if (!_preferences.containsKey("layout_data")) {
        await _preferences.setString("layout_data", "{}");
      }

      var js = json.decode(_preferences.getString("layout_data")!);

      _items = js;

      return _items!.values
          .map((value) => ColoredDashboardItem.fromMap(value))
          .toList();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }

    // return [
    //   DashboardItem(
    //     identifier: "a",
    //     startX: 0,
    //     startY: 2,
    //     width: 2,
    //     height: 3,
    //   ),
    //   DashboardItem(
    //       identifier: "b",
    //       startX: 2,
    //       startY: 3,
    //       width: 2,
    //       height: 1,
    //       minWidth: 2),
    //   DashboardItem(
    //       identifier: "c",
    //       startX: 1,
    //       startY: 5,
    //       width: 3,
    //       height: 1,
    //       minWidth: 1,
    //       maxWidth: 3),
    //   DashboardItem(identifier: "d", startX: 3, startY: 2, width: 1, height: 1),
    //   DashboardItem(identifier: "e", startX: 2, startY: 5, width: 2, height: 6),
    //   DashboardItem(identifier: "f", startX: 0, startY: 5, width: 2, height: 1),
    //   DashboardItem(identifier: "g", startX: 1, startY: 6, width: 1, height: 3),
    // ];
  }

  @override
  FutureOr<void> onItemsUpdated(List<ColoredDashboardItem> items) async {
    for (var item in items) {
      _items![item.identifier] = item.toMap();
    }

    var js = json.encode(_items);

    await _preferences.setString("layout_data", js);
  }

  @override
  FutureOr<void> onItemsAdded(List<ColoredDashboardItem> items) async {
    for (var item in items) {
      _items![item.identifier] = item.toMap();
    }

    var js = json.encode(_items);

    await _preferences.setString("layout_data", js);
  }

  @override
  FutureOr<void> onItemsDeleted(List<ColoredDashboardItem> items) async {
    for (var item in items) {
      _items!.remove(item.identifier);
    }
    var js = json.encode(_items);
    await _preferences.setString("layout_data", js);
  }
}
