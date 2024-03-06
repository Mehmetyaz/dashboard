part of '../dashboard_base.dart';

@immutable
class _ViewportDelegate {
  _ViewportDelegate(
      {required this.constraints,
      required this.mainAxisSpace,
      required this.padding,
      required this.crossAxisSpace})
      : resolvedConstrains = BoxConstraints(
          maxHeight: constraints.maxHeight - padding.vertical,
          maxWidth: constraints.maxWidth - padding.horizontal,
        );

  @override
  bool operator ==(Object other) {
    return other is _ViewportDelegate &&
        constraints == other.constraints &&
        mainAxisSpace == other.mainAxisSpace &&
        padding == other.padding &&
        crossAxisSpace == other.crossAxisSpace;
  }

  final BoxConstraints constraints;
  final BoxConstraints resolvedConstrains;
  final EdgeInsets padding;
  final double mainAxisSpace, crossAxisSpace;

  @override
  int get hashCode =>
      Object.hash(mainAxisSpace, crossAxisSpace, crossAxisSpace, padding);
}
