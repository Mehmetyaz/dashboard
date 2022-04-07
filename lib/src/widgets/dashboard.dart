part of dashboard;

///
typedef DashboardItemBuilder<T> = Widget Function(
    DashboardItem<T> item, ItemCurrentLayout currentLayout);

///
class Dashboard<T> extends StatefulWidget {
  const Dashboard(
      {Key? key,
      this.axis = Axis.vertical,
      required this.itemBuilder,
      required this.dashboardItemController,
      this.slotCount = 8,
      this.scrollController,
      this.physics,
      this.dragStartBehavior,
      this.scrollBehavior,
      this.cacheExtend = 500,
      this.crossAxisSpace = 8,
      this.mainAxisSpace = 8,
      this.padding = const EdgeInsets.all(0),
      this.shrinkToPlace = true,
      this.swapOnEditing = true,
      this.slideToTop = true,
      this.editModeSettings = const EditModeSettings()})
      : super(key: key);

  ///
  final DashboardItemBuilder<T> itemBuilder;

  ///
  final double cacheExtend;

  ///
  final EditModeSettings editModeSettings;

  /// Dashboard scroll axis.
  /// The dashboard widget should be constrained to the opposite [axis].
  /// E.g if [axis] is vertical, the width of the dashboard should be bounded,
  /// otherwise throws [Unbounded] exception.
  ///
  final Axis axis;

  ///
  final DashboardItemController<T> dashboardItemController;

  ///
  final int slotCount;

  ///
  final ScrollController? scrollController;

  ///
  final ScrollPhysics? physics;

  ///
  final DragStartBehavior? dragStartBehavior;

  ///
  final ScrollBehavior? scrollBehavior;

  ///
  final double mainAxisSpace, crossAxisSpace;

  ///
  final EdgeInsetsGeometry padding;

  ///
  final bool shrinkToPlace;

  ///
  final bool swapOnEditing;

  ///
  final bool slideToTop;

  @override
  _DashboardState<T> createState() => _DashboardState<T>();
}

class _DashboardState<T> extends State<Dashboard<T>>
    with TickerProviderStateMixin {
  ///
  @override
  void initState() {
    _layoutController = DashboardLayoutController();
    _layoutController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  ///
  late final DashboardLayoutController<T> _layoutController;

  ///
  ViewportOffset? _offset;

  ///
  ViewportOffset get offset => _offset!;

  ///
  _setNewOffset(ViewportOffset o, BoxConstraints constraints) {
    /// check slot count
    /// check new constrains equal exists

    var c = BoxConstraints(
      maxHeight: constraints.maxHeight - widget.padding.vertical,
      maxWidth: constraints.maxWidth - widget.padding.horizontal,
    );

    if (!_layoutController._isAttached) {
      _layoutController.attach(
          slideToTop: widget.slideToTop,
          shrinkToPlace: widget.shrinkToPlace,
          axis: widget.axis,
          constrains: c,
          itemController: widget.dashboardItemController,
          slotCount: widget.slotCount);
    }

    if (_layoutController._isAttached &&
        (widget.slotCount != _layoutController.slotCount ||
            widget.axis != _layoutController._axis)) {
      _layoutController.attach(
          shrinkToPlace: widget.shrinkToPlace,
          slideToTop: widget.slideToTop,
          slotCount: widget.slotCount,
          itemController: widget.dashboardItemController,
          constrains: c,
          axis: widget.axis);
    }
    _layoutController._attachConstrains(c);
    _offset = o;
    _offset!.applyViewportDimension(
        widget.axis == Axis.vertical ? c.maxHeight : c.maxWidth);

    var maxIndex =
        (_layoutController._endsTree.max as _IndexedDashboardItem).value;

    var maxCoordinate = (_layoutController.getIndexCoordinate(maxIndex));

    _maxExtend = ((maxCoordinate[1] + 1) * _layoutController.slotEdge);

    _maxExtend -= constraints.maxHeight;

    _offset!.applyContentDimensions(
        0, _maxExtend.clamp(0, double.maxFinite) + widget.padding.vertical);
  }

  ///
  late double _maxExtend;

  ///
  double base = 150;

  ///
  Duration duration = const Duration(milliseconds: 200);

  ///
  final GlobalKey<_DashboardViewportOffsetBuilderState> _stateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      Unbounded.check(widget.axis, constrains);
      return Scrollable(
          physics: widget.physics,
          controller: widget.scrollController,
          semanticChildCount: widget.dashboardItemController._items.length,
          dragStartBehavior:
              widget.dragStartBehavior ?? DragStartBehavior.start,
          scrollBehavior: widget.scrollBehavior,
          viewportBuilder: (c, o) {
            _setNewOffset(o, constrains);
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              _stateKey.currentState?._listenOffset(o);
            });
            return _DashboardViewportOffsetBuilder<T>(
                maxScrollOffset: _maxExtend,
                editModeSettings: widget.editModeSettings,
                crossAxisSpace: widget.crossAxisSpace,
                mainAxisSpace: widget.mainAxisSpace,
                padding: widget.padding.resolve(TextDirection.ltr),
                cacheExtend: widget.cacheExtend,
                key: _stateKey,
                itemBuilder: widget.itemBuilder,
                dashboardController: _layoutController,
                constraints: constrains,
                offset: offset);
          });
    });
  }
}

class _DashboardViewportOffsetBuilder<T> extends StatefulWidget {
  const _DashboardViewportOffsetBuilder(
      {Key? key,
      required this.constraints,
      required this.editModeSettings,
      required this.offset,
      required this.dashboardController,
      required this.itemBuilder,
      required this.cacheExtend,
      required this.crossAxisSpace,
      required this.mainAxisSpace,
      required this.padding,
      required this.maxScrollOffset})
      : super(key: key);

  final BoxConstraints constraints;
  final ViewportOffset offset;
  final DashboardLayoutController<T> dashboardController;
  final double cacheExtend;
  final double mainAxisSpace, crossAxisSpace;
  final EditModeSettings editModeSettings;
  final EdgeInsets padding;
  final double maxScrollOffset;

  ///
  final DashboardItemBuilder<T> itemBuilder;

  @override
  State<_DashboardViewportOffsetBuilder> createState() =>
      _DashboardViewportOffsetBuilderState();
}

class _DashboardViewportOffsetBuilderState
    extends State<_DashboardViewportOffsetBuilder> {
  ///
  ViewportOffset get viewportOffset => widget.offset;

  ///
  double get pixels => viewportOffset.pixels;

  ///
  double get width => widget.constraints.maxWidth;

  ///
  double get height => widget.constraints.maxHeight;

  ///
  _listenOffset(ViewportOffset o) {
    o.removeListener(_listen);
    o.addListener(_listen);
  }

  ///
  @override
  void didChangeDependencies() {
    _listenOffset(viewportOffset);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _listenOffset(viewportOffset);
    super.initState();
  }

  @override
  void dispose() {
    viewportOffset.removeListener(_listen);
    super.dispose();
  }

  void _listen() {
    setState(() {});
  }

  Widget buildPositioned(List list) {
    return _DashboardItemWidget(
      currentPosition: (list[0] as ItemCurrentLayout).currentPosition(
          offset: viewportOffset.pixels,
          padding: widget.padding,
          mainAxisSpace: widget.mainAxisSpace,
          crossAxisSpace: widget.mainAxisSpace,
          slotEdge: slotEdge),
      offset: viewportOffset.pixels,
      crossAxisSpace: widget.crossAxisSpace,
      mainAxisSpace: widget.mainAxisSpace,
      padding: widget.padding,
      itemCurrentLayout: list[0],
      id: list[2],
      editModeSettings: widget.editModeSettings,
      child: list[1],
      layoutController: widget.dashboardController,
      constraints: widget.constraints,
    );
  }

  late double slotEdge;

  final Map<String, List> _widgetsMap = <String, List>{};

  void addWidget(String id) {
    var i = widget.dashboardController.itemController._items[id];
    var l = widget.dashboardController._layouts[i!.identifier]!;
    _widgetsMap[id] = [l, widget.itemBuilder(i, l), id];
  }

  @override
  Widget build(BuildContext context) {
    slotEdge = widget.dashboardController.slotEdge;

    var startPixels = (viewportOffset.pixels) - widget.cacheExtend;
    var startY = (startPixels / slotEdge).floor();
    var startIndex = widget.dashboardController.getIndex([0, startY]);

    var endPixels = viewportOffset.pixels + height + widget.cacheExtend;
    var endY = (endPixels / slotEdge).ceil();
    var endIndex = widget.dashboardController
        .getIndex([widget.dashboardController.slotCount - 1, endY]);

    var needs = (widget.dashboardController._indexesTree.toListFrom(
                _IndexedDashboardItem("", startIndex),
                equal: true,
                greaterThan: true,
                bound: Bound<_IndexedDashboardItem>(
                    equal: true, element: _IndexedDashboardItem("", endIndex)))
            as List<_IndexedDashboardItem>)
        .map((e) => e.id)
        .toList();

    var beforeIt = widget.dashboardController._indexesTree.toListFrom(
        _IndexedDashboardItem(null, startIndex),
        equal: false,
        greaterThan: false) as List<_IndexedDashboardItem>;

    var afterIt = widget.dashboardController._indexesTree.toListFrom(
        _IndexedDashboardItem(null, endIndex),
        equal: false,
        greaterThan: true) as List<_IndexedDashboardItem>;

    var needDelete = [...afterIt, ...beforeIt];
    var edit = widget.dashboardController.editSession?.editing;

    for (var n in needDelete) {
      if (!needs.contains(n.id) && n.id != edit?.id) {
        _widgetsMap.remove(n.id);
      }
    }

    for (var n in needs) {
      if (!_widgetsMap.containsKey(n)) {
        addWidget(n!);
      }
    }

    if (edit != null && !_widgetsMap.containsKey(edit.id)) {
      addWidget(edit.id);
    }

    Widget result = Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        if (widget.editModeSettings.editBackground &&
            widget.dashboardController.isEditing)
          Positioned(
            top: widget.padding.top,
            left: widget.padding.left,
            width: widget.constraints.maxWidth - widget.padding.vertical,
            height: widget.constraints.maxHeight - widget.padding.horizontal,
            child: CustomPaint(
              painter: EditModeBackgroundPainter(
                  padding: widget.padding,
                  fillPosition: widget.dashboardController.editSession?.editing,
                  mainAxisSpace: widget.mainAxisSpace,
                  crossAxisSpace: widget.crossAxisSpace,
                  slotCount: widget.dashboardController.slotCount,
                  style: widget.editModeSettings.backgroundStyle,
                  slotEdge: slotEdge,
                  offset: viewportOffset.pixels,
                  constraints: BoxConstraints(
                      maxWidth:
                          widget.constraints.maxWidth - widget.padding.vertical,
                      maxHeight: widget.constraints.maxHeight -
                          widget.padding.horizontal)),
              isComplex: true,
            ),
          ),
        ..._widgetsMap.entries
            .where((element) =>
                element.value[2] !=
                widget.dashboardController.editSession?.editing)
            .map((e) => buildPositioned(e.value))
            .toList(),
        ...?(widget.dashboardController.editSession == null
            ? null
            : [
                buildPositioned(_widgetsMap[
                    widget.dashboardController.editSession?.editing.id]!)
              ])
      ],
    );

    if (widget.dashboardController.isEditing) {
      result = GestureDetector(
        onPanStart: (panStart) {
          _onMoveStart(panStart.localPosition);
        },
        onPanUpdate: (u) {
          setSpeed(u.localPosition);
          _onMoveUpdate(u.localPosition);
        },
        onPanEnd: (e) {
          _onMoveEnd();
        },
        onLongPressStart: (longPressStart) {
          _onMoveStart(longPressStart.localPosition);
        },
        onLongPressMoveUpdate: (u) {
          setSpeed(u.localPosition);
          _onMoveUpdate(u.localPosition);
        },
        onLongPressEnd: (e) {
          _onMoveEnd();
        },
        child: result,
      );
    }
    return result;
  }

  void setSpeed(Offset global) {
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
      if (speed != 0) {
        viewportOffset.jumpTo(
            (pixels + speed).clamp(0, widget.maxScrollOffset + (slotEdge * 2)));
        scroll();
      }
    });
  }

  double speed = 0;

  void _onMoveStart(Offset local) {
    var holdGlobal = Offset(local.dx - widget.padding.left,
        local.dy - widget.padding.top + viewportOffset.pixels);

    var x = (local.dx - widget.padding.left) ~/ slotEdge;
    var y = (local.dy + pixels - widget.padding.top) ~/ slotEdge;

    var e = widget.dashboardController._indexesTree.search(
        _IndexedDashboardItem(
            null, widget.dashboardController.getIndex([x, y])));

    print(widget.dashboardController._indexesTree.toList());

    if (e is _IndexedDashboardItem) {
      var directions = <AxisDirection>[];
      _editing = widget.dashboardController._layouts[e.id!]!;
      var _current = _editing!.currentPosition(
          crossAxisSpace: widget.crossAxisSpace,
          mainAxisSpace: widget.mainAxisSpace,
          offset: viewportOffset.pixels,
          padding: widget.padding,
          slotEdge: slotEdge);
      var _itemGlobal = ItemCurrentPosition(
          x: _current.x - widget.padding.left,
          y: _current.y - widget.padding.top,
          height: _current.height,
          width: _current.width);
      if (holdGlobal.dx < _itemGlobal.x || holdGlobal.dy < _itemGlobal.y) {
        _editing = null;
        setState(() {});
        return;
      }
      if (_itemGlobal.x + widget.editModeSettings.resizeCursorSide >
          holdGlobal.dx) {
        directions.add(AxisDirection.left);
      }

      if (_itemGlobal.y + widget.editModeSettings.resizeCursorSide >
          holdGlobal.dy) {
        directions.add(AxisDirection.up);
      }

      if (_itemGlobal.endX - widget.editModeSettings.resizeCursorSide <
          holdGlobal.dx) {
        directions.add(AxisDirection.right);
      }

      if (_itemGlobal.endY - widget.editModeSettings.resizeCursorSide <
          holdGlobal.dy) {
        directions.add(AxisDirection.down);
      }
      if (directions.isNotEmpty) {
        _directions = directions;
      } else {
        _directions = null;
      }

      if (kDebugMode) {
        print("HOLDING: ${e.id}:$_directions\n$holdGlobal\n"
            "_ItemCurrentPosition(\n"
            "x: ${_current.x - widget.padding.left},\n"
            "y: ${_current.y - widget.padding.top},\n"
            "height: ${_current.height}\n"
            "width: ${_current.width}\n"
            ");");
      }

      _start = local;
      _startScroll = pixels;
      widget.dashboardController.startEdit(e.id!);
      setState(() {});
    } else {
      _start = null;
      _editing = null;
      _directions = null;
      speed = 0;
      widget.dashboardController.saveEditSession();
    }
  }

  ItemCurrentLayout? _editing;

  bool get _editingResize => _directions != null;
  List<AxisDirection>? _directions;
  Offset? _start;
  double? _startScroll;

  void _onMoveUpdate(Offset local) {
    if (_editing != null) {
      if (_editingResize) {
        var difPos = ItemCurrentPosition(height: 0, width: 0, y: 0, x: 0);
        var d = <Resizing>[];
        var dif = local - _start!;
        if (_directions!.contains(AxisDirection.left)) {
          var dx = _editing!._clampDifLeft(dif.dx);
          difPos.x += dx;
          difPos.width -= dx;
        }

        if (_directions!.contains(AxisDirection.up)) {
          var dy = _editing!._clampDifTop(dif.dy);
          difPos.y += (dy);
          difPos.height -= (dy + pixels - _startScroll!);
        }

        if (_directions!.contains(AxisDirection.right)) {
          var dx = _editing!._clampDifRight(dif.dx);
          difPos.width += dx;
        }

        if (_directions!.contains(AxisDirection.down)) {
          var dy = _editing!._clampDifBottom(dif.dy);
          difPos.height += dy + pixels - _startScroll!;
        }

        if (_directions!.contains(AxisDirection.left)) {
          if (dif.dx < 0) {
            d.add(Resizing(AxisDirection.left, true));
          } else if (dif.dx > slotEdge) {
            d.add(Resizing(AxisDirection.left, false));
          }
        } else if (_directions!.contains(AxisDirection.right)) {
          if (dif.dx < -slotEdge) {
            d.add(Resizing(AxisDirection.right, false));
          } else if (dif.dx > 0) {
            d.add(Resizing(AxisDirection.right, true));
          }
        }

        if (_directions!.contains(AxisDirection.up)) {
          if (dif.dy < 0) {
            d.add(Resizing(AxisDirection.up, true));
          } else if (dif.dy > slotEdge) {
            d.add(Resizing(AxisDirection.up, false));
          }
        } else if (_directions!.contains(AxisDirection.down)) {
          if (dif.dy < -slotEdge) {
            d.add(Resizing(AxisDirection.down, false));
          } else if (dif.dy > 0) {
            d.add(Resizing(AxisDirection.down, true));
          }
        }

        /// BOUND
        var res = _editing!.tryResize(d);
        if (res != null) {
          _editing!.save();
          res.adjustResizeOffset(local, slotEdge);
          _editing!._resizePosition.value = res.adjustedPosition;
          addWidget(_editing!.id);
          setState(() {
            _start = res.adjustedDif;
            print("N RESIZE: ${_editing!}");
          });
        } else {
          _editing!._resizePosition.value = difPos;
        }
      } else {
        _editing!._transform.value =
            local - _start! + Offset(0, pixels - _startScroll!);
      }
    }
  }

  void _onMoveEnd() {
    _editing?._transform.value = Offset.zero;
    _editing?._resizePosition.value =
        ItemCurrentPosition(height: 0, width: 0, y: 0, x: 0);
    _editing = null;
    _start = null;
    _directions = null;
    speed = 0;
    widget.dashboardController.saveEditSession();
  }
}

class _DashboardItemWidget extends StatefulWidget {
  const _DashboardItemWidget(
      {Key? key,
      required this.layoutController,
      required this.child,
      required this.offset,
      required this.editModeSettings,
      required this.id,
      required this.mainAxisSpace,
      required this.crossAxisSpace,
      required this.padding,
      required this.itemCurrentLayout,
      required this.constraints,
      required this.currentPosition})
      : super(key: key);

  final ItemCurrentLayout itemCurrentLayout;
  final Widget child;
  final String id;
  final DashboardLayoutController layoutController;
  final double crossAxisSpace, mainAxisSpace;
  final EdgeInsets padding;
  final EditModeSettings editModeSettings;
  final double offset;
  final BoxConstraints constraints;
  final ItemCurrentPosition currentPosition;

  @override
  State<_DashboardItemWidget> createState() => _DashboardItemWidgetState();
}

class _DashboardItemWidgetState extends State<_DashboardItemWidget> {
  late MouseCursor cursor;

  late double leftPad, rightPad, topPad, bottomPad;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    cursor = MouseCursor.defer;
    super.initState();
  }

  ItemCurrentPosition get _resizePosition =>
      widget.itemCurrentLayout._resizePosition.value;

  bool onRightSide(double dX) =>
      dX >
      (c.maxWidth + _resizePosition.width) -
          widget.editModeSettings.resizeCursorSide;

  bool onLeftSide(double dX) =>
      (dX + _resizePosition.x) < widget.editModeSettings.resizeCursorSide;

  bool onTopSide(double dY) =>
      (dY + _resizePosition.y) < widget.editModeSettings.resizeCursorSide;

  bool onBottomSide(double dY) =>
      dY >
      (c.maxHeight + _resizePosition.height) -
          widget.editModeSettings.resizeCursorSide;

  void _hover(PointerHoverEvent hover) {
    var x = hover.localPosition.dx;
    var y = hover.localPosition.dy;
    MouseCursor _cursor;
    var r = onRightSide(x);
    var l = onLeftSide(x);
    var t = onTopSide(y);
    var b = onBottomSide(y);
    if (r) {
      if (b) {
        _cursor = SystemMouseCursors.resizeUpLeftDownRight;
      } else if (t) {
        _cursor = SystemMouseCursors.resizeUpRightDownLeft;
      } else {
        _cursor = SystemMouseCursors.resizeLeftRight;
      }
    } else if (l) {
      if (b) {
        _cursor = SystemMouseCursors.resizeUpRightDownLeft;
      } else if (t) {
        _cursor = SystemMouseCursors.resizeUpLeftDownRight;
      } else {
        _cursor = SystemMouseCursors.resizeLeftRight;
      }
    } else if (b || t) {
      _cursor = SystemMouseCursors.resizeUpDown;
    } else {
      _cursor = SystemMouseCursors.move;
    }
    if (_cursor != cursor) {
      setState(() {
        cursor = _cursor;
      });
    }
  }

  void _exit(PointerExitEvent exit) {
    setState(() {
      cursor = MouseCursor.defer;
    });
  }

  Offset transform = Offset.zero;

  Offset? panStart;

  double scrollOffset = 0;

  double startScrollOffset = 0;

  ItemCurrentLayout get l => widget.itemCurrentLayout;

  late BoxConstraints c;

  double get slotEdge => widget.layoutController.slotEdge;

  @override
  Widget build(BuildContext context) {
    leftPad = l.isLeftSide ? 0.0 : widget.crossAxisSpace / 2;
    rightPad = l.isRightSide ? 0.0 : widget.crossAxisSpace / 2;
    topPad = l.isTopSide ? 0.0 : widget.mainAxisSpace / 2;
    bottomPad = l.isBottomSide ? 0.0 : widget.mainAxisSpace / 2;
    c = BoxConstraints(
        maxWidth: l.width * slotEdge - rightPad - leftPad,
        maxHeight: l.height * slotEdge - topPad - bottomPad);

    Widget result = Material(
      elevation: 10,
      child: widget.child,
      color: Colors.transparent,
      type: MaterialType.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    if (widget.layoutController.isEditing) {
      result = AbsorbPointer(child: result);

      if (kIsWeb) {
        result = MouseRegion(
          cursor: cursor,
          onHover: _hover,
          onExit: _exit,
          child: result,
        );
      }
    }

    return ValueListenableBuilder<ItemCurrentPosition>(
        valueListenable: widget.itemCurrentLayout._resizePosition,
        builder: (__, p, w) {
          return ValueListenableBuilder<Offset>(
              child: result,
              valueListenable: widget.itemCurrentLayout._transform,
              builder: (_, o, w) {
                var cp = widget.currentPosition + p;
                return Positioned(
                    left: cp.x + o.dx,
                    top: cp.y + o.dy,
                    width: cp.width,
                    height: cp.height,
                    child: widget.layoutController.isEditing
                        ? CustomPaint(
                            child: w!,
                            foregroundPainter: EditModeItemPainter(
                                style: widget.editModeSettings.foregroundStyle,
                                tolerance:
                                    widget.editModeSettings.resizeCursorSide,
                                constraints: BoxConstraints(
                                    maxHeight: cp.height, maxWidth: cp.width)),
                          )
                        : w!);
              });
        });
  }
}
