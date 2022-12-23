part of dashboard;

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
    //this.paintItemForeground = true,
    this.shrinkOnMove = true,
  }) : duration = duration ?? kThemeAnimationDuration;

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
//final EditModeForegroundStyle foregroundStyle;
}
