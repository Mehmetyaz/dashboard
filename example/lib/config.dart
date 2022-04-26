import 'package:flutter/material.dart';

class DashboardConfig {
  DashboardConfig({
    required this.slotCount,
    required this.padding,
    required this.horizontalSpace,
    required this.verticalSpace,
    required this.shrinkToPlace,
    required this.slideToTop,
    required this.slotAspectRatio,
  });

  factory DashboardConfig.fromMap(Map<String, dynamic> map) {
    return DashboardConfig(
        slotCount: map["slotCount"],
        padding: EdgeInsets.only(
          right: map["padding_right"],
          left: map["padding_left"],
          top: map["padding_top"],
          bottom: map["padding_bottom"],
        ),
        horizontalSpace: map["horizontalSpace"],
        verticalSpace: map["verticalSpace"],
        shrinkToPlace: map["shrinkToPlace"],
        slideToTop: map["slideToTop"],
        slotAspectRatio: map["slotAspectRatio"]);
  }

  int slotCount;

  double verticalSpace, horizontalSpace;

  EdgeInsets padding;

  bool shrinkToPlace, slideToTop;

  double slotAspectRatio;

  Map<String, dynamic> toMap() => {
        "slotCount": slotCount,
        "verticalSpace": verticalSpace,
        "horizontalSpace": horizontalSpace,
        "shrinkToPlace": shrinkToPlace,
        "slideToTop": slideToTop,
        "slotAspectRatio": slotAspectRatio,
        "padding_top": padding.top,
        "padding_bottom": padding.bottom,
        "padding_left": padding.left,
        "padding_right": padding.right
      };
}
