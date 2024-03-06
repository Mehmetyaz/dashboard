import 'dart:async';
import 'dart:convert';

import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColoredDashboardItem extends DashboardItem {
  ColoredDashboardItem(
      {this.color,
      required super.width,
      required super.height,
      required super.identifier,
      this.data,
      super.minWidth,
      super.minHeight,
      super.maxHeight,
      super.maxWidth,
      super.startX,
      super.startY});

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

        var init = _preferences.getBool("init") ?? false;

        if (!init) {
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

          await _preferences.setBool("init", true);
        }

        var js = json.decode(_preferences.getString("layout_data_$slotCount")!);

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
    _setLocal();

    for (var item in items) {
      _localItems?[slotCount]?[item.identifier] = item;
    }

    var js = json.encode(_localItems![slotCount]!
        .map((key, value) => MapEntry(key, value.toMap())));

    await _preferences.setString("layout_data_$slotCount", js);
  }

  @override
  FutureOr<void> onItemsAdded(
      List<ColoredDashboardItem> items, int slotCount) async {
    _setLocal();
    for (var s in _slotCounts) {
      for (var i in items) {
        _localItems![s]?[i.identifier] = i;
      }

      await _preferences.setString(
          "layout_data_$s",
          json.encode(_localItems![s]!
              .map((key, value) => MapEntry(key, value.toMap()))));
    }
  }

  @override
  FutureOr<void> onItemsDeleted(
      List<ColoredDashboardItem> items, int slotCount) async {
    _setLocal();
    for (var s in _slotCounts) {
      for (var i in items) {
        _localItems![s]?.remove(i.identifier);
      }

      await _preferences.setString(
          "layout_data_$s",
          json.encode(_localItems![s]!
              .map((key, value) => MapEntry(key, value.toMap()))));
    }
  }

  Future<void> clear() async {
    for (var s in _slotCounts) {
      _localItems?[s]?.clear();
      await _preferences.remove("layout_data_$s");
    }
    _localItems = null;
    await _preferences.setBool("init", false);
  }

  _setLocal() {
    _localItems ??= {
      for (var s in _slotCounts)
        s: _default[s]!
            .asMap()
            .map((key, value) => MapEntry(value.identifier, value))
    };
  }

  @override
  bool get layoutsBySlotCount => true;

  @override
  bool get cacheItems => true;
}
