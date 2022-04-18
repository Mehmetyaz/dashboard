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
      this.editModeSettings = const EditModeSettings(),
      this.textDirection = TextDirection.ltr})
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

  final TextDirection textDirection;

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

    _layoutController._viewportDelegate = ViewportDelegate(
        constraints: constraints,
        padding: widget.padding.resolve(widget.textDirection),
        mainAxisSpace: widget.mainAxisSpace,
        crossAxisSpace: widget.crossAxisSpace);

    if (!_layoutController._isAttached) {
      _layoutController.attach(
          slideToTop: widget.slideToTop,
          shrinkToPlace: widget.shrinkToPlace,
          axis: widget.axis,
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
          axis: widget.axis);
    }

    _layoutController
        ._setSizes(_layoutController._viewportDelegate.resolvedConstrains);
    _offset = o;
    _offset!.applyViewportDimension(widget.axis == Axis.vertical
        ? _layoutController._viewportDelegate.constraints.maxHeight
        : _layoutController._viewportDelegate.constraints.maxWidth);

    var maxIndex = (_layoutController._endsTree.lastKey());

    var maxCoordinate = (_layoutController.getIndexCoordinate(maxIndex!));

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
  final GlobalKey<_DashboardStackState> _stateKey = GlobalKey();

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
            return _DashboardStack<T>(
                maxScrollOffset: _maxExtend,
                editModeSettings: widget.editModeSettings,
                cacheExtend: widget.cacheExtend,
                key: _stateKey,
                itemBuilder: widget.itemBuilder,
                dashboardController: _layoutController,
                offset: offset);
          });
    });
  }
}

class _DashboardItemWidget extends StatefulWidget {
  const _DashboardItemWidget(
      {Key? key,
      required this.layoutController,
      required this.child,
      required this.editModeSettings,
      required this.id,
      required this.itemCurrentLayout,
      required this.currentPosition})
      : super(key: key);

  final ItemCurrentLayout itemCurrentLayout;
  final Widget child;
  final String id;
  final DashboardLayoutController layoutController;
  final EditModeSettings editModeSettings;
  final ItemCurrentPosition currentPosition;

  @override
  State<_DashboardItemWidget> createState() => _DashboardItemWidgetState();
}

class _DashboardItemWidgetState extends State<_DashboardItemWidget> {
  late MouseCursor cursor;

  // late double leftPad, rightPad, topPad, bottomPad;

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
      (widget.currentPosition.width + _resizePosition.width) -
          widget.editModeSettings.resizeCursorSide;

  bool onLeftSide(double dX) =>
      (dX + _resizePosition.x) < widget.editModeSettings.resizeCursorSide;

  bool onTopSide(double dY) =>
      (dY + _resizePosition.y) < widget.editModeSettings.resizeCursorSide;

  bool onBottomSide(double dY) =>
      dY >
      (widget.currentPosition.height + _resizePosition.height) -
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

  //late BoxConstraints c;

  double get slotEdge => widget.layoutController.slotEdge;

  @override
  Widget build(BuildContext context) {
    // leftPad = l.isLeftSide ? 0.0 : widget.crossAxisSpace / 2;
    // rightPad = l.isRightSide ? 0.0 : widget.crossAxisSpace / 2;
    // topPad = l.isTopSide ? 0.0 : widget.mainAxisSpace / 2;
    // bottomPad = l.isBottomSide ? 0.0 : widget.mainAxisSpace / 2;
    // c = BoxConstraints(
    //     maxWidth: l.width * slotEdge - rightPad - leftPad,
    //     maxHeight: l.height * slotEdge - topPad - bottomPad);

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
