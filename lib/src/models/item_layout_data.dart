part of '../dashboard_base.dart';

class ItemLayout {
  ItemLayout(
      {int? startX,
      int? startY,
      required this.width,
      required this.height,
      this.minWidth = 1,
      this.minHeight = 1,
      this.maxHeight,
      this.maxWidth})
      : assert(minWidth <= width),
        assert(minHeight <= height),
        assert(maxHeight == null || maxHeight >= height),
        assert(maxWidth == null || maxWidth >= width),
        _haveLocation = startX != null || startY != null,
        startX = startX ?? 0,
        startY = startY ?? 0;

  ItemLayout._(
      {required this.startX,
      required this.startY,
      required this.width,
      required this.height,
      this.minWidth = 1,
      this.minHeight = 1,
      this.maxHeight,
      this.maxWidth,
      required bool haveLocation})
      : _haveLocation = haveLocation,
        assert(minWidth <= width),
        assert(minHeight <= height),
        assert(maxHeight == null || maxHeight >= height),
        assert(maxWidth == null || maxWidth >= width);

  factory ItemLayout.fromMap(Map<String, dynamic> map) {
    return ItemLayout(
        startX: map["s_X"],
        startY: map["s_Y"],
        width: map["w"],
        height: map["h"],
        maxHeight: map["max_H"],
        maxWidth: map["max_W"],
        minHeight: map["min_H"],
        minWidth: map["min_W"]);
  }

  Map<String, dynamic> toMap() {
    return {
      if (_haveLocation) "s_X": startX,
      if (_haveLocation) "s_Y": startY,
      "w": width,
      "h": height,
      "min_W": minWidth,
      "min_H": minHeight,
      if (maxHeight != null) "max_H": maxHeight,
      if (maxWidth != null) "max_W": maxWidth,
    };
  }

  @override
  String toString() {
    return "startX: $startX , startY: $startY , width: $width , height: $height";
  }

  bool _haveLocation;

  ///
  final int startX, startY;

  ///
  final int width, height;

  ///
  final int minWidth, minHeight;

  final int? maxWidth, maxHeight;

  ItemLayout copyWithDimension({int? width, int? height}) {
    return ItemLayout._(
        startX: startX,
        startY: startY,
        width: width ?? this.width,
        height: height ?? this.height,
        minHeight: minHeight,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        minWidth: minWidth,
        haveLocation: _haveLocation);
  }

  ItemLayout copyWithStarts({int? startX, int? startY}) {
    var x = startX ?? this.startX;
    var y = startY ?? this.startY;
    return ItemLayout._(
        startX: x,
        startY: y,
        width: width,
        height: height,
        minHeight: minHeight,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        minWidth: minWidth,
        haveLocation: _haveLocation);
  }
}
