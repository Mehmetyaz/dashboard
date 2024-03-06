part of '../dashboard_base.dart';

/// Slot background builder.
abstract class SlotBackgroundBuilder<T extends DashboardItem> {
  SlotBackgroundBuilder();

  /// Create a builder with a function.
  static SlotBackgroundBuilder<T> withFunction<T extends DashboardItem>(
      Widget? Function(
              BuildContext context, T? item, int x, int y, bool editing)
          builder) {
    return _WithFunctionSlotBackgroundBuilder<T>(builder);
  }

  DashboardItemController<T>? _itemController;

  Widget _build(BuildContext context, int x, int y) {
    final layoutController = _itemController!._layoutController!;
    final i = layoutController._indexesTree[layoutController.getIndex([x, y])];

    T? item;

    if (i != null) {
      item = layoutController.itemController._items[i] as T;
    }

    return buildBackground(context, item, x, y, layoutController._isEditing) ??
        Container();
  }

  /// Build background widget.
  Widget? buildBackground(
      BuildContext context, T? item, int x, int y, bool editing);
}

class _WithFunctionSlotBackgroundBuilder<T extends DashboardItem>
    extends SlotBackgroundBuilder<T> {
  final Widget? Function(
      BuildContext context, T? item, int x, int y, bool editing) builder;

  _WithFunctionSlotBackgroundBuilder(this.builder);

  @override
  Widget? buildBackground(
      BuildContext context, T? item, int x, int y, bool editing) {
    return builder(context, item, x, y, editing);
  }
}
