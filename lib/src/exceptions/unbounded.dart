part of '../dashboard_base.dart';

/// Unbounded exception
class Unbounded implements Exception {
  /// Create with constraints and axis.
  Unbounded({required this.constraints, required this.axis});

  static void check(Axis axis, BoxConstraints constraints) {
    if (axis == Axis.vertical && !constraints.hasBoundedWidth) {
      throw Unbounded(constraints: constraints, axis: axis);
    }
    if (axis == Axis.horizontal && !constraints.hasBoundedHeight) {
      throw Unbounded(constraints: constraints, axis: axis);
    }
  }

  final BoxConstraints constraints;
  final Axis axis;

  @override
  String toString() {
    return "Unbounded ${axis == Axis.vertical ? "width" : "height"}\n"
        "BoxConstrains: $constraints";
  }
}
