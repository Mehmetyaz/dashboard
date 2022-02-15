part of '../../dashboard.dart';

class ItemLayoutData {
  ItemLayoutData({
    required this.startX,
    required this.endX,
    required this.startY,
    required this.endY,
    this.additionalData,
    this.maxWidth,
    this.minWidth = 1,
    this.maxHeight,
    this.minHeight = 1,
  })  : width = endX - startX,
        height = endY - startY;

  ItemLayoutData.fromSWH(
      {required this.startX,
      required this.startY,
      required this.width,
      required this.height,
      this.additionalData,
      this.minWidth = 1,
      this.minHeight = 1,
      this.maxHeight,
      this.maxWidth})
      : endX = startX + width,
        endY = startY + height;

  factory ItemLayoutData.fromMap(Map<String, dynamic> map) {
    return ItemLayoutData.fromSWH(
        startX: map["s_X"],
        startY: map["s_Y"],
        width: map["w"],
        height: map["h"],
        maxHeight: map["max_H"],
        maxWidth: map["max_W"],
        minHeight: map["min_H"],
        minWidth: map["min_W"],
        additionalData: map["add"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "s_X": startX,
      "s_Y": startY,
      "w": width,
      "h": height,
      "min_W": minWidth,
      "min_H": minHeight,
      if (maxHeight != null) "max_H": maxHeight,
      if (maxWidth != null) "max_W": maxWidth,
      if (additionalData != null) "add": additionalData
    };
  }

  ///
  int startX, startY, endX, endY;

  ///
  int width, height;

  ///
  int minWidth, minHeight;

  int? maxWidth, maxHeight;


  Map<String, dynamic>? additionalData;
}
