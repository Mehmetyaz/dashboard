part of '../dashboard_base.dart';

/// In edit mode, dashboard background are painted with lines and a rect if
/// any items is editing.
///
/// The lines show where the slots begin and end, along with the
/// [verticalSpace] and the [horizontalSpace].
///
/// Filling shows the actual location of the editing item. This pan/move also
/// shows where the item will go when released. It is recommended not to use
/// very obscure colors to reflect the sense of editing well.
class EditModeBackgroundStyle {
  /// in default lines are dual.
  const EditModeBackgroundStyle(
      {this.dualLineVertical = true,
      this.dualLineHorizontal = true,
      this.lineWidth = 0.7,
      this.lineColor = Colors.black54,
      this.fillColor = Colors.black38,
      this.outherRadius = 8});

  @override
  bool operator ==(Object other) {
    return other is EditModeBackgroundStyle &&
        dualLineVertical == other.dualLineVertical &&
        dualLineHorizontal == other.dualLineHorizontal &&
        lineWidth == other.lineWidth &&
        lineColor == other.lineColor &&
        fillColor == other.fillColor;
  }

  final double outherRadius;

  /// Editing item background filling color.
  final Color fillColor;

  /// If [dualLineVertical] lines draw exactly slots ends and starts vertically.
  /// Else only one line draw center of the horizontalSpace.
  final bool dualLineVertical;

  /// If [dualLineVertical] lines draw exactly slots ends and starts
  /// horizontally.
  /// Else only one line draw center of the verticalSpace.
  final bool dualLineHorizontal;

  /// Line thickness.
  final double lineWidth;

  /// Line color
  final Color lineColor;

  @override
  int get hashCode => Object.hash(
      fillColor, dualLineVertical, dualLineHorizontal, lineWidth, lineColor);
}

// class EditModeForegroundStyle {
//   const EditModeForegroundStyle(
//       {this.fillColor = Colors.black26,
//       this.innerRadius = 8,
//       this.outherRadius = 8,
//       this.shadowColor = Colors.white24,
//       this.shadowElevation = 4,
//       this.shadowTransparentOccluder = true,
//       this.sideWidth});
//
//   ///
//   final double? sideWidth;
//   final Color fillColor;
//   final double innerRadius, outherRadius;
//   final Color shadowColor;
//   final bool shadowTransparentOccluder;
//   final double shadowElevation;
// }
