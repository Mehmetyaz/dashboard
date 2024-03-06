part of '../dashboard_base.dart';

/// Edit mode settings.
/// It contains parameters related to gesture, animations, resizing.
class EditModeSettings {
  /// duration default is package:flutter/foundation.dart
  /// [kThemeAnimationDuration]
  EditModeSettings({
    this.resizeCursorSide = 10,
    this.paintBackgroundLines = true,
    this.fillEditingBackground = true,
    this.longPressEnabled = true,
    this.panEnabled = true,
    this.backgroundStyle = const EditModeBackgroundStyle(),
    this.curve = Curves.easeOut,
    Duration? duration,
    this.shrinkOnMove = true,
    this.draggableOutside = true,
    this.autoScroll = true,
  }) : duration = duration ?? kThemeAnimationDuration;

  /// If [draggableOutside] is true, items can be dragged outside the viewport.
  /// Else items can't be dragged outside the viewport.
  ///
  /// This only effects horizontal drag. To disable vertical drag set
  /// [autoScroll] to false also.
  final bool draggableOutside;

  /// If [autoScroll] is true, viewport will scroll automatically when item is
  /// dragged outside the viewport vertically.
  final bool autoScroll;

  /// Animation duration
  final Duration duration;

  /// Start resize or move with long press.
  final bool longPressEnabled;

  /// Start resize or move with pan.
  final bool panEnabled;

  /// Animation curve
  final Curve curve;

  /// Shrink items on moving if necessary.
  final bool shrinkOnMove;

  /// Resize side width. If pan/longPress start in side editing is resizing.
  final double resizeCursorSide;

  /// Paint background lines.
  final bool paintBackgroundLines;

  /// Fill editing item background.
  final bool fillEditingBackground;

  ///final bool paintItemForeground = false;

  /// Background style
  final EditModeBackgroundStyle backgroundStyle;
}
