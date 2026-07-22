part of '../dashboard_base.dart';

class _DashboardStack<T extends DashboardItem> extends StatefulWidget {
  const _DashboardStack({
    super.key,
    required this.editModeSettings,
    required this.offset,
    required this.dashboardController,
    required this.itemBuilder,
    required this.cacheExtend,
    required this.maxScrollOffset,
    required this.onScrollStateChange,
    required this.shouldCalculateNewDimensions,
    required this.itemStyle,
    required this.emptyPlaceholder,
    required this.slotBackground,
    this.itemDecorator,
    this.isSliver = false,
  });

  final bool isSliver;
  final Widget? emptyPlaceholder;
  final ViewportOffset offset;
  final _DashboardLayoutController<T> dashboardController;
  final double cacheExtend;
  final EditModeSettings editModeSettings;
  final SlotBackgroundBuilder<T>? slotBackground;
  final double maxScrollOffset;
  final void Function(bool scrollable) onScrollStateChange;

  ///
  final DashboardItemBuilder<T> itemBuilder;

  final ItemStyle itemStyle;

  final void Function() shouldCalculateNewDimensions;
  final DashboardItemDecorator<T>? itemDecorator;

  @override
  State<_DashboardStack<T>> createState() => _DashboardStackState<T>();
}

class _DashboardStackState<T extends DashboardItem>
    extends State<_DashboardStack<T>> {
  ViewportOffset get viewportOffset => widget.offset;

  _ViewportDelegate get viewportDelegate =>
      widget.dashboardController._viewportDelegate;

  double get pixels => viewportOffset.pixels;

  double get width => viewportDelegate.resolvedConstrains.maxWidth;

  double get height => viewportDelegate.resolvedConstrains.maxHeight;

  @override
  void didUpdateWidget(covariant _DashboardStack<T> old) {
    _widgetsMap.clear();
    super.didUpdateWidget(old);
  }

  @override
  void didChangeDependencies() {
    _widgetsMap.clear();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _widgetsMap.clear();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildPositioned(List list) {
    final String id = list[2];
    final _ItemCurrentLayout layout = list[0];
    final _ItemCurrentPosition cp = layout._currentPosition(
      viewportDelegate: viewportDelegate,
      slotEdge: slotEdge,
      verticalSlotEdge: verticalSlotEdge,
    );

    final bool isEditing = widget.dashboardController.isEditing;
    final bool isDragging = widget.dashboardController.editSession?.editing.id == id;
    final T? item = widget.dashboardController.itemController._items[id];

    Widget childWidget = list[1];
    if (item != null && widget.itemDecorator != null) {
      childWidget = widget.itemDecorator!(
        context,
        item,
        childWidget,
        isEditing,
        isDragging,
      );
    }

    if (!isEditing && (!widget.dashboardController.animateEverytime || !layout._change)) {
      return Positioned(
        key: ValueKey(id),
        left: cp.x,
        top: cp.y,
        width: cp.width,
        height: cp.height,
        child: RepaintBoundary(
          key: ValueKey('rb_$id'),
          child: childWidget,
        ),
      );
    }

    return _DashboardItemWidget(
      style: widget.itemStyle,
      key: _keys[id]!,
      itemGlobalPosition: cp,
      itemCurrentLayout: layout,
      id: id,
      editModeSettings: widget.editModeSettings,
      offset: viewportOffset,
      layoutController: widget.dashboardController,
      itemDecorator: null,
      child: RepaintBoundary(child: childWidget),
    );
  }

  late double slotEdge;
  late double verticalSlotEdge;
  final Map<String, List> _widgetsMap = <String, List>{};

  void addWidget(String id) {
    var i = widget.dashboardController.itemController._items[id];
    var l = widget.dashboardController._layouts![i!.identifier]!;
    i.layoutData = l.asLayout();

    final itemWidget = widget.itemBuilder(i);
    final bool useMaterial = (widget.itemStyle.elevation != null && widget.itemStyle.elevation! > 0) ||
        widget.itemStyle.color != null ||
        widget.itemStyle.shape != null ||
        (widget.itemStyle.type != null && widget.itemStyle.type != MaterialType.transparency);

    _widgetsMap[id] = [
      l,
      DashboardItemWidget(
        item: i,
        child: useMaterial
            ? Material(
                elevation: widget.itemStyle.elevation ?? 0.0,
                type: widget.itemStyle.type ?? MaterialType.card,
                shape: widget.itemStyle.shape,
                color: widget.itemStyle.color,
                clipBehavior: widget.itemStyle.clipBehavior ?? Clip.none,
                animationDuration:
                    widget.itemStyle.animationDuration ?? kThemeChangeDuration,
                child: itemWidget,
              )
            : itemWidget,
      ),
      id,
    ];

    _keys[id] ??= GlobalKey<_DashboardItemWidgetState>();
    l._key = _keys[id]!;
  }

  final Map<String, GlobalKey<_DashboardItemWidgetState>> _keys = {};

  late int startIndex, endIndex;

  List<Widget> _buildBackground() {
    final res = <Widget>[];

    int i = startIndex;

    var l =
        viewportDelegate.padding.left + (viewportDelegate.crossAxisSpace / 2);
    var t =
        viewportDelegate.padding.top +
        (viewportDelegate.mainAxisSpace / 2);
    var w = slotEdge - viewportDelegate.crossAxisSpace;
    var h = verticalSlotEdge - viewportDelegate.mainAxisSpace;

    while (i <= endIndex) {
      var x = i % widget.dashboardController.slotCount;
      var y = (i / widget.dashboardController.slotCount).floor();
      widget.slotBackground!._itemController =
          widget.dashboardController.itemController;
      final bgWidget = widget.slotBackground!._build(context, x, y);
      if (bgWidget != null && bgWidget is! SizedBox) {
        res.add(
          Positioned(
            left: x * slotEdge + l,
            top: y * verticalSlotEdge + t,
            width: w,
            height: h,
            child: bgWidget,
          ),
        );
      }
      i++;
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dashboardController._rebuild) {
      _widgetsMap.clear();
      widget.dashboardController._rebuild = false;
    }

    slotEdge = widget.dashboardController.slotEdge;
    verticalSlotEdge = widget.dashboardController.verticalSlotEdge;
    var startPixels = (viewportOffset.pixels) - widget.cacheExtend;
    var startY = (startPixels / verticalSlotEdge).floor();

    startIndex = widget.dashboardController.getIndex([0, startY]);

    var endPixels = viewportOffset.pixels + height + widget.cacheExtend;
    var endY = (endPixels / verticalSlotEdge).ceil();
    endIndex = widget.dashboardController.getIndex([
      widget.dashboardController.slotCount - 1,
      endY,
    ]);

    final needs = widget.dashboardController._indexesTree.itemsInRange(startIndex, endIndex);

    final validIds = widget.dashboardController.itemController._items.keys.toSet();
    _keys.removeWhere((k, _) => !validIds.contains(k));

    var edit = widget.dashboardController.editSession?.editing;

    _widgetsMap.removeWhere((n, _) => !needs.contains(n) && n != edit?.id);

    for (var n in needs) {
      if (!_widgetsMap.containsKey(n)) {
        addWidget(n);
      }
    }

    if (edit != null && !_widgetsMap.containsKey(edit.id)) {
      _widgetsMap.remove(edit.id);
      _keys.remove(edit.id);
      addWidget(edit.id);
    }

    Widget result = Stack(
      clipBehavior: widget.dashboardController.isEditing ? Clip.hardEdge : Clip.none,
      children: [
        if (widget.slotBackground != null) ..._buildBackground(),
        if (widget.dashboardController.isEditing)
          Positioned(
            top: viewportDelegate.padding.top,
            left: viewportDelegate.padding.left,
            width:
                viewportDelegate.constraints.maxWidth -
                viewportDelegate.padding.vertical,
            height:
                viewportDelegate.constraints.maxHeight -
                viewportDelegate.padding.horizontal,
            child: Builder(
              builder: (context) {
                return _AnimatedBackgroundPainter(
                  layoutController: widget.dashboardController,
                  editModeSettings: widget.editModeSettings,
                  offset: viewportOffset,
                );
              },
            ),
          ),
        ..._widgetsMap.entries
            .where(
              (element) =>
                  element.value[2] !=
                  widget.dashboardController.editSession?.editing.id,
            )
            .map((e) {
              return buildPositioned(e.value);
            }),
        if (widget.dashboardController.itemController._items.isEmpty &&
            !widget.dashboardController._isEditing)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: widget.emptyPlaceholder ?? Container(),
          ),
        ...?(widget.dashboardController.editSession == null
            ? null
            : [
                buildPositioned(
                  _widgetsMap[widget
                      .dashboardController
                      .editSession
                      ?.editing
                      .id]!,
                ),
              ]),
      ],
    );

    if (widget.dashboardController.isEditing) {
      result = GestureDetector(
        onPanStart: widget.editModeSettings.panEnabled
            ? (panStart) {
                _onMoveStart(panStart.localPosition);
              }
            : null,
        onPanUpdate:
            widget.editModeSettings.panEnabled &&
                edit != null &&
                edit.id.isNotEmpty
            ? (u) {
                setSpeed(u.localPosition);
                _onMoveUpdate(u.localPosition);
              }
            : null,
        onPanEnd: widget.editModeSettings.panEnabled
            ? (e) {
                _onMoveEnd();
              }
            : null,
        onLongPressStart: widget.editModeSettings.longPressEnabled
            ? (longPressStart) {
                _onMoveStart(longPressStart.localPosition);
              }
            : null,
        onLongPressMoveUpdate:
            widget.editModeSettings.longPressEnabled &&
                edit != null &&
                edit.id.isNotEmpty
            ? (u) {
                setSpeed(u.localPosition);
                _onMoveUpdate(u.localPosition);
              }
            : null,
        onLongPressEnd: widget.editModeSettings.longPressEnabled
            ? (e) {
                _onMoveEnd();
              }
            : null,
        child: result,
      );
    }

    if (!widget.isSliver) {
      result = AnimatedBuilder(
        animation: viewportOffset,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -viewportOffset.pixels),
            child: child,
          );
        },
        child: result,
      );
    }

    return result;
  }

  void setSpeed(Offset global) {
    if (!widget.editModeSettings.autoScroll) {
      speed = 0;
      return;
    }

    var last = min((height - global.dy), global.dy);
    var m = global.dy < 50 ? -1 : 1;
    if (last < 10) {
      speed = 0.3 * m;
    } else if (last < 20) {
      speed = 0.1 * m;
    } else if (last < 50) {
      speed = 0.05 * m;
    } else {
      speed = 0;
    }
    scroll();
  }

  void scroll() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        if (speed != 0) {
          var n = pixels + speed;

          viewportOffset.jumpTo(n.clamp(0.0, (1 << 31).toDouble()));

          scroll();
        }
      } catch (e) {
        rethrow;
      }
    });
  }

  @override
  void reassemble() {
    _widgetsMap.clear();
    super.reassemble();
  }

  double speed = 0;

  Offset holdOffset = Offset.zero;

  void _onMoveStart(Offset local) {
    var holdGlobal = Offset(
      local.dx - viewportDelegate.padding.left,
      local.dy - viewportDelegate.padding.top,
    );

    var x = (local.dx - viewportDelegate.padding.left) ~/ slotEdge;
    var y =
        (local.dy + pixels - viewportDelegate.padding.top) ~/ verticalSlotEdge;

    var e = widget
        .dashboardController
        ._indexesTree[widget.dashboardController.getIndex([x, y])];

    if (e is String) {
      var directions = <AxisDirection>[];
      _editing = widget.dashboardController._layouts![e]!;
      var current = _editing!._currentPosition(
        slotEdge: slotEdge,
        viewportDelegate: viewportDelegate,
        verticalSlotEdge: verticalSlotEdge,
      );
      var itemGlobal = _ItemCurrentPosition(
        x: current.x - viewportDelegate.padding.left,
        y: current.y - viewportDelegate.padding.top - pixels,
        height: current.height,
        width: current.width,
      );
      if (holdGlobal.dx < itemGlobal.x || holdGlobal.dy < itemGlobal.y) {
        _editing = null;
        setState(() {});
        return;
      }
      if (itemGlobal.x + widget.editModeSettings.resizeCursorSide >
          holdGlobal.dx) {
        directions.add(AxisDirection.left);
      }

      if ((itemGlobal.y) + widget.editModeSettings.resizeCursorSide >
          holdGlobal.dy) {
        directions.add(AxisDirection.up);
      }

      if (itemGlobal.endX - widget.editModeSettings.resizeCursorSide <
          holdGlobal.dx) {
        directions.add(AxisDirection.right);
      }

      if ((itemGlobal.endY) - widget.editModeSettings.resizeCursorSide <
          holdGlobal.dy) {
        directions.add(AxisDirection.down);
      }
      if (directions.isNotEmpty) {
        _holdDirections = directions;
      } else {
        _holdDirections = null;
      }
      _moveStartOffset = local;
      _startScrollPixels = pixels;
      widget.dashboardController.startEdit(e, _holdDirections == null);

      holdOffset = holdGlobal - Offset(itemGlobal.x, itemGlobal.y);

      var l = widget.dashboardController._layouts![e];
      widget.dashboardController.editSession!.editing._originSize = [
        l!.width,
        l.height,
      ];
      setState(() {});
      widget.onScrollStateChange(false);
    } else {
      _moveStartOffset = null;
      _editing = null;
      _holdDirections = null;
      widget.dashboardController.editSession?.editing._originSize = null;
      speed = 0;
      widget.dashboardController.saveEditSession();
      widget.onScrollStateChange(true);
    }
  }

  _ItemCurrentLayout? _editing;

  bool get _editingResize => _holdDirections != null;
  List<AxisDirection>? _holdDirections;
  Offset? _moveStartOffset;
  double? _startScrollPixels;

  bool isResizing(AxisDirection direction) =>
      _holdDirections!.contains(direction);

  void _onMoveUpdate(Offset local) {
    if (_editing == null) {
      return;
    }

    var e = widget.dashboardController._endsTree.lastKey() ?? 0;

    if (_editingResize) {
      var scrollDifference = pixels - _startScrollPixels!;
      var differences = <String>{};
      var resizeMoveResult = _editing!._resizeMove(
        holdDirections: _holdDirections!,
        local: local,
        onChange: (s) {
          differences.add(s);
        },
        start: _moveStartOffset!,
        scrollDifference: scrollDifference,
      );

      if (resizeMoveResult.isChanged) {
        setState(() {
          _moveStartOffset =
              _moveStartOffset! + resizeMoveResult.startDifference;
          _widgetsMap.remove(_editing!.id);
          for (var r in differences) {
            _widgetsMap.remove(r);
          }
          if (_editing!._endIndex > (e)) {
            widget.shouldCalculateNewDimensions();
          }
        });
      }
    } else {
      var resizeMoveResult = _editing!._transformUpdate(
        local - _moveStartOffset!,
        pixels - _startScrollPixels!,
        holdOffset,
      );

      if (resizeMoveResult != null && resizeMoveResult.isChanged) {
        setState(() {
          _moveStartOffset =
              _moveStartOffset! + resizeMoveResult.startDifference;
          _widgetsMap.remove(_editing!.id);

          if (_editing!._endIndex > (e)) {
            widget.shouldCalculateNewDimensions();
          }
        });
      }
    }
  }

  void _onMoveEnd() {
    _editing?._key = _keys[_editing!.id]!;
    _editing?._key.currentState
        ?._setLast(
          _editing!._transform?.value,
          _editing!._resizePosition?.value,
        )
        .then((value) {
          widget.dashboardController.editSession?.editing._originSize = null;
          _editing?._clearListeners();
          _editing = null;
          _moveStartOffset = null;
          _holdDirections = null;
          _startScrollPixels = null;
          widget.dashboardController.saveEditSession();
        });
    speed = 0;
    widget.onScrollStateChange(true);
  }
}
