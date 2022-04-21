part of dashboard;

class _DashboardItemWidget extends StatefulWidget {
  const _DashboardItemWidget(
      {required Key key,
      required this.layoutController,
      required this.child,
      required this.editModeSettings,
      required this.id,
      required this.itemCurrentLayout,
      required this.itemGlobalPosition,
      required this.offset})
      : super(key: key);

  final ItemCurrentLayout itemCurrentLayout;
  final Widget child;
  final String id;
  final DashboardLayoutController layoutController;
  final EditModeSettings editModeSettings;
  final ItemCurrentPosition itemGlobalPosition;
  final double offset;

  @override
  State<_DashboardItemWidget> createState() => _DashboardItemWidgetState();
}

class _DashboardItemWidgetState extends State<_DashboardItemWidget>
    with TickerProviderStateMixin {
  late MouseCursor cursor;

  // late double leftPad, rightPad, topPad, bottomPad;

  @override
  void dispose() {
    _animationController.dispose();
    _multiplierAnimationController.dispose();
    super.dispose();
  }

  late AnimationController _multiplierAnimationController;

  @override
  void initState() {
    cursor = MouseCursor.defer;
    _animationController = AnimationController(
        vsync: this,
        duration: widget.editModeSettings.fillBackgroundAnimationDuration);
    _multiplierAnimationController = AnimationController(
        vsync: this,
        value: 0,
        duration: widget.editModeSettings.fillBackgroundAnimationDuration);
    super.initState();
  }

  ItemCurrentPosition get _resizePosition =>
      widget.itemCurrentLayout._resizePosition.value;

  bool onRightSide(double dX) =>
      dX >
      (widget.itemGlobalPosition.width + _resizePosition.width) -
          widget.editModeSettings.resizeCursorSide;

  bool onLeftSide(double dX) =>
      (dX + _resizePosition.x) < widget.editModeSettings.resizeCursorSide;

  bool onTopSide(double dY) =>
      (dY + _resizePosition.y) < widget.editModeSettings.resizeCursorSide;

  bool onBottomSide(double dY) =>
      dY >
      (widget.itemGlobalPosition.height + _resizePosition.height) -
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

  ItemCurrentPosition? ex;

  late AnimationController _animationController;
  Animation<ItemCurrentPosition>? _animation;

  Offset? _lastTransform;
  ItemCurrentPosition? _lastPosition;

  Future<void> _setLast(
      Offset lastOffset, ItemCurrentPosition lastPosition) async {
    _lastTransform = lastOffset;
    _lastPosition = lastPosition;
    _multiplierAnimationController.reset();
    _multiplierAnimationController.value = 1;
    await _multiplierAnimationController.animateTo(0).then((value) {
      setState(() {
        _lastTransform = null;
        _lastPosition = null;
      });
    });
  }

  bool get onEditMode => widget.layoutController.isEditing;

  @override
  Widget build(BuildContext context) {
    Widget result = Material(
      elevation: 10,
      child: widget.child,
      color: Colors.transparent,
      type: MaterialType.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    if (onEditMode) {
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

    if (onEditMode && ex != null && !ex!.equal(widget.itemGlobalPosition)) {
      _animationController.reset();
      _animation =
          _ItemCurrentPositionTween(begin: ex!, end: widget.itemGlobalPosition)
              .animate(_animationController);
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _animationController.forward();
      });
    }

    ex = widget.itemGlobalPosition;

    if (!onEditMode) {
      var cp = widget.itemGlobalPosition;
      return Positioned(
          left: cp.x,
          top: cp.y - widget.offset,
          width: cp.width,
          height: cp.height,
          child: result);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.itemCurrentLayout._resizePosition,
        widget.itemCurrentLayout._transform,
        if (_animation != null) _animation,
        _multiplierAnimationController
      ]),
      child: result,
      builder: (c, w) {
        var m = _multiplierAnimationController.value;

        var p = widget.itemCurrentLayout._resizePosition.value;

        if (_lastPosition != null) {
          p += ItemCurrentPosition(
              height: _lastPosition!.height * m,
              width: _lastPosition!.width * m,
              y: _lastPosition!.y * m,
              x: _lastPosition!.x * m);
        }

        var o = widget.itemCurrentLayout._transform.value;

        if (_lastTransform != null) {
          o += _lastTransform! * m;
        }

        var cp = ((widget.layoutController.editSession?.editing.id ==
                    widget.itemCurrentLayout.id)
                ? widget.itemGlobalPosition
                : (_animation?.value ?? widget.itemGlobalPosition)) +
            p;
        return Positioned(
            left: cp.x + o.dx,
            top: cp.y + o.dy - widget.offset,
            width: cp.width,
            height: cp.height,
            child: widget.layoutController.isEditing
                ? CustomPaint(
                    child: w!,
                    foregroundPainter: EditModeItemPainter(
                        style: widget.editModeSettings.foregroundStyle,
                        tolerance: widget.editModeSettings.resizeCursorSide,
                        constraints: BoxConstraints(
                            maxHeight: cp.height, maxWidth: cp.width)),
                  )
                : w!);
      },
    );
  }
}
