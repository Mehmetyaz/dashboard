import 'dart:async';
import 'dart:convert';

import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColoredDashboardItem extends DashboardItem {
  ColoredDashboardItem(
      {this.color,
      required int width,
      required int height,
      required String identifier,
      this.data,
      int minWidth = 1,
      int minHeight = 1,
      int? maxHeight,
      int? maxWidth,
      int? startX,
      int? startY})
      : super(
            startX: startX,
            startY: startY,
            width: width,
            height: height,
            identifier: identifier,
            maxHeight: maxHeight,
            maxWidth: maxWidth,
            minWidth: minWidth,
            minHeight: minHeight);

  ColoredDashboardItem.fromMap(Map<String, dynamic> map)
      : color = map["color"] != null ? Color(map["color"]) : null,
        data = map["data"],
        super.withLayout(map["item_id"], ItemLayout.fromMap(map["layout"]));

  Color? color;

  String? data;

  @override
  Map<String, dynamic> toMap() {
    var sup = super.toMap();
    if (color != null) {
      sup["color"] = color?.value;
    }
    if (data != null) {
      sup["data"] = data;
    }
    return sup;
  }
}

class MyItemStorage extends DashboardItemStorageDelegate<ColoredDashboardItem> {
  late SharedPreferences _preferences;

  final List<int> _slotCounts = [4, 6, 8];

  final Map<int, List<ColoredDashboardItem>> _default = {
    4: <ColoredDashboardItem>[
      ColoredDashboardItem(
        height: 2,
        width: 3,
        startX: 0,
        startY: 1,
        minHeight: 2,
        identifier: "1",
        data: "description",
      ),
      ColoredDashboardItem(
          startX: 3,
          startY: 1,
          minHeight: 2,
          height: 2,
          width: 1,
          identifier: "2",
          data: "resize"),
      ColoredDashboardItem(
          startX: 0,
          startY: 0,
          width: 4,
          height: 1,
          identifier: "3",
          minWidth: 3,
          data: "welcome"),
      ColoredDashboardItem(
          startX: 1,
          startY: 3,
          minWidth: 2,
          minHeight: 2,
          height: 2,
          width: 3,
          identifier: "4",
          data: "transform"),
      ColoredDashboardItem(
          startX: 0,
          startY: 3,
          minHeight: 2,
          height: 2,
          width: 1,
          identifier: "5",
          data: "add"),
      ColoredDashboardItem(
          minWidth: 2,
          maxWidth: 2,
          maxHeight: 1,
          height: 1,
          width: 2,
          startX: 2,
          startY: 7,
          identifier: "6",
          data: "buy_mee"),
      ColoredDashboardItem(
          minWidth: 2,
          height: 1,
          width: 2,
          startX: 2,
          startY: 5,
          identifier: "7",
          data: "delete"),
      ColoredDashboardItem(
          minWidth: 2,
          height: 1,
          width: 2,
          startX: 0,
          startY: 5,
          identifier: "8",
          data: "refresh"),
      ColoredDashboardItem(
          minWidth: 3,
          height: 1,
          width: 3,
          startX: 0,
          startY: 6,
          identifier: "9",
          data: "info"),
      ColoredDashboardItem(
          startX: 3,
          startY: 6,
          height: 1,
          width: 1,
          identifier: "13",
          data: "pub"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "10", data: "github"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "11", data: "twitter"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "12", data: "linkedin")
    ],
    6: <ColoredDashboardItem>[
      ColoredDashboardItem(
        height: 2,
        width: 3,
        startX: 0,
        startY: 0,
        minHeight: 2,
        identifier: "1",
        data: "description",
      ),
      ColoredDashboardItem(
          startX: 3,
          startY: 0,
          minHeight: 2,
          height: 2,
          width: 1,
          identifier: "2",
          data: "resize"),
      ColoredDashboardItem(
          startX: 0,
          startY: 2,
          width: 5,
          height: 1,
          identifier: "3",
          minWidth: 3,
          data: "welcome"),
      ColoredDashboardItem(
          startX: 4,
          startY: 0,
          minWidth: 2,
          minHeight: 2,
          height: 2,
          width: 2,
          identifier: "4",
          data: "transform"),
      ColoredDashboardItem(
          startX: 5,
          startY: 2,
          minHeight: 2,
          height: 2,
          width: 1,
          identifier: "5",
          data: "add"),
      ColoredDashboardItem(
          minWidth: 2,
          maxWidth: 2,
          maxHeight: 1,
          height: 1,
          width: 2,
          startX: 4,
          startY: 4,
          identifier: "6",
          data: "buy_mee"),
      ColoredDashboardItem(
          minWidth: 2,
          height: 1,
          width: 2,
          startX: 0,
          startY: 4,
          identifier: "7",
          data: "delete"),
      ColoredDashboardItem(
          minWidth: 2,
          height: 1,
          width: 2,
          startX: 2,
          startY: 4,
          identifier: "8",
          data: "refresh"),
      ColoredDashboardItem(
          minWidth: 4,
          height: 1,
          width: 4,
          startX: 0,
          startY: 3,
          identifier: "9",
          data: "info"),
      ColoredDashboardItem(
          startX: 4,
          startY: 3,
          height: 1,
          width: 1,
          identifier: "13",
          data: "pub"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "10", data: "github"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "11", data: "twitter"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "12", data: "linkedin")
    ],
    8: <ColoredDashboardItem>[
      ColoredDashboardItem(
        height: 2,
        width: 3,
        startX: 0,
        startY: 0,
        minHeight: 2,
        identifier: "1",
        data: "description",
      ),
      ColoredDashboardItem(
          startX: 3,
          startY: 0,
          minHeight: 2,
          height: 2,
          width: 2,
          identifier: "2",
          data: "resize"),
      ColoredDashboardItem(
          startX: 2,
          startY: 2,
          width: 4,
          height: 1,
          identifier: "3",
          minWidth: 3,
          data: "welcome"),
      ColoredDashboardItem(
          startX: 5,
          startY: 0,
          minWidth: 2,
          minHeight: 2,
          height: 2,
          width: 2,
          identifier: "4",
          data: "transform"),
      ColoredDashboardItem(
          startX: 7,
          startY: 0,
          minHeight: 2,
          height: 2,
          width: 1,
          identifier: "5",
          data: "add"),
      ColoredDashboardItem(
          minWidth: 2,
          maxWidth: 2,
          maxHeight: 1,
          height: 1,
          width: 2,
          startX: 2,
          startY: 4,
          identifier: "6",
          data: "buy_mee"),
      ColoredDashboardItem(
          minWidth: 2,
          height: 1,
          width: 2,
          startX: 0,
          startY: 2,
          identifier: "7",
          data: "delete"),
      ColoredDashboardItem(
          minWidth: 2,
          height: 1,
          width: 2,
          startX: 6,
          startY: 2,
          identifier: "8",
          data: "refresh"),
      ColoredDashboardItem(
          minWidth: 3,
          height: 1,
          width: 4,
          startX: 0,
          startY: 3,
          identifier: "9",
          data: "info"),
      ColoredDashboardItem(
          startX: 6,
          startY: 3,
          height: 2,
          width: 2,
          identifier: "13",
          data: "pub"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "10", data: "github"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "11", data: "twitter"),
      ColoredDashboardItem(
          height: 1, width: 2, identifier: "12", data: "linkedin")
    ]
  };

  Map<int, Map<String, ColoredDashboardItem>>? _localItems;
  @override
  FutureOr<List<ColoredDashboardItem>> getAllItems(int slotCount) {
    try {
      if (_localItems != null) {
        return _localItems![slotCount]!.values.toList();
      }

      return Future.microtask(() async {
        _preferences = await SharedPreferences.getInstance();

        if (!_preferences.containsKey("layout_data_$slotCount")) {
          _localItems = {
            for (var s in _slotCounts)
              s: _default[s]!
                  .asMap()
                  .map((key, value) => MapEntry(value.identifier, value))
          };

          for (var s in _slotCounts) {
            await _preferences.setString(
                "layout_data_$s",
                json.encode(_default[s]!.asMap().map((key, value) =>
                    MapEntry(value.identifier, value.toMap()))));
          }
        }

        var js = json.decode(_preferences.getString("layout_data_$slotCount")!);

        if (js.isEmpty) {
          await _preferences.setString(
              "layout_data_$slotCount",
              json.encode(_default[slotCount]!.asMap().map(
                  (key, value) => MapEntry(value.identifier, value.toMap()))));
          js = json.decode(_preferences.getString("layout_data_$slotCount")!);
        }

        return js!.values
            .map<ColoredDashboardItem>(
                (value) => ColoredDashboardItem.fromMap(value))
            .toList();
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  FutureOr<void> onItemsUpdated(
      List<ColoredDashboardItem> items, int slotCount) async {
    var itemsForSlot = itemsFor(slotCount) ??
        _default[slotCount]!
            .asMap()
            .map((key, value) => MapEntry(value.identifier, value));
    _localItems ??= {};
    _localItems![slotCount] ??= _default[slotCount]!
        .asMap()
        .map((key, value) => MapEntry(value.identifier, value));

    for (var item in items) {
      itemsForSlot[item.identifier] = item;
      _localItems?[slotCount]?[item.identifier] = item;
    }

    var js = json
        .encode(itemsForSlot.map((key, value) => MapEntry(key, value.toMap())));

    await _preferences.setString("layout_data_$slotCount", js);
  }

  @override
  FutureOr<void> onItemsAdded(
      List<ColoredDashboardItem> items, int slotCount) async {
    for (var s in _slotCounts) {
      var itemsForSlot = itemsFor(s) ??
          _default[s]!
              .asMap()
              .map((key, value) => MapEntry(value.identifier, value));

      _localItems ??= {};
      _localItems![s] ??= _default[s]!
          .asMap()
          .map((key, value) => MapEntry(value.identifier, value));

      for (var i in items) {
        itemsForSlot[i.identifier] = i;
        _localItems![s]?[i.identifier] = i;
      }

      await _preferences.setString(
          "layout_data_$s",
          json.encode(
              itemsForSlot.map((key, value) => MapEntry(key, value.toMap()))));
    }
  }

  @override
  FutureOr<void> onItemsDeleted(
      List<ColoredDashboardItem> items, int slotCount) async {
    for (var s in _slotCounts) {
      var itemsForSlot = itemsFor(s)!;

      _localItems![s] ??= _default[s]!
          .asMap()
          .map((key, value) => MapEntry(value.identifier, value));

      for (var i in items) {
        itemsForSlot.remove(i.identifier);
        _localItems![s]?.remove(i.identifier);
      }

      await _preferences.setString(
          "layout_data_$s",
          json.encode(
              itemsForSlot.map((key, value) => MapEntry(key, value.toMap()))));
    }
  }

  Future<void> clear() async {
    for (var s in _slotCounts) {
      _localItems?[s]?.clear();
      await _preferences.remove("layout_data_$s");
    }
  }

  @override
  bool get layoutsBySlotCount => true;

  @override
  bool get cacheItems => true;
}
