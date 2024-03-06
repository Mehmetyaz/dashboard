part of '../dashboard_base.dart';

class DashboardItemWidget<T extends DashboardItem> extends InheritedWidget {
  const DashboardItemWidget(
      {required this.item, required super.child, super.key});

  final DashboardItem item;

  static DashboardItemWidget<T> of<T extends DashboardItem>(
      BuildContext context) {
    final DashboardItemWidget? result =
        context.dependOnInheritedWidgetOfExactType<DashboardItemWidget>();
    assert(result != null, 'No DashboardItemWidget found in context');
    return result! as DashboardItemWidget<T>;
  }

  @override
  bool updateShouldNotify(covariant DashboardItemWidget oldWidget) {
    return oldWidget.item.identifier != item.identifier;
  }
}

class _DashboardItemWidget extends StatefulWidget {
  const _DashboardItemWidget(
      {required Key key,
      required this.layoutController,
      required this.child,
      required this.editModeSettings,
      required this.id,
      required this.itemCurrentLayout,
      required this.itemGlobalPosition,
      required this.offset,
      required this.style})
      : super(key: key);

  final _ItemCurrentLayout itemCurrentLayout;
  final Widget child;
  final String id;
  final _DashboardLayoutController layoutController;
  final EditModeSettings editModeSettings;
  final _ItemCurrentPosition itemGlobalPosition;
  final ViewportOffset offset;
  final ItemStyle style;

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
    widget.itemCurrentLayout.removeListener(_listen);
    super.dispose();
  }

  _listen() {
    setState(() {});
  }

  late AnimationController _multiplierAnimationController;

  @override
  void initState() {
    cursor = MouseCursor.defer;
    _animationController = AnimationController(
        vsync: this, duration: widget.editModeSettings.duration);
    _multiplierAnimationController = AnimationController(
        vsync: this, value: 0, duration: widget.editModeSettings.duration);
    widget.itemCurrentLayout.addListener(_listen);
    super.initState();
  }

  _ItemCurrentPosition? get _resizePosition =>
      widget.itemCurrentLayout._resizePosition?.value;

  bool onRightSide(double dX) =>
      dX >
      (widget.itemGlobalPosition.width + (_resizePosition?.width ?? 0)) -
          widget.editModeSettings.resizeCursorSide;

  bool onLeftSide(double dX) =>
      (dX + (_resizePosition?.x ?? 0)) <
      widget.editModeSettings.resizeCursorSide;

  bool onTopSide(double dY) =>
      (dY + (_resizePosition?.y ?? 0)) <
      widget.editModeSettings.resizeCursorSide;

  bool onBottomSide(double dY) =>
      dY >
      (widget.itemGlobalPosition.height + (_resizePosition?.height ?? 0)) -
          widget.editModeSettings.resizeCursorSide;

  void _hover(PointerHoverEvent hover) {
    var x = hover.localPosition.dx;
    var y = hover.localPosition.dy;
    MouseCursor cursor;
    var r = onRightSide(x);
    var l = onLeftSide(x);
    var t = onTopSide(y);
    var b = onBottomSide(y);
    if (r) {
      if (b) {
        cursor = SystemMouseCursors.resizeUpLeftDownRight;
      } else if (t) {
        cursor = SystemMouseCursors.resizeUpRightDownLeft;
      } else {
        cursor = SystemMouseCursors.resizeLeftRight;
      }
    } else if (l) {
      if (b) {
        cursor = SystemMouseCursors.resizeUpRightDownLeft;
      } else if (t) {
        cursor = SystemMouseCursors.resizeUpLeftDownRight;
      } else {
        cursor = SystemMouseCursors.resizeLeftRight;
      }
    } else if (b || t) {
      cursor = SystemMouseCursors.resizeUpDown;
    } else {
      cursor = SystemMouseCursors.move;
    }
    if (this.cursor != cursor) {
      setState(() {
        this.cursor = cursor;
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

  _ItemCurrentLayout get l => widget.itemCurrentLayout;

  double get slotEdge => widget.layoutController.slotEdge;

  _ItemCurrentPosition? ex;

  late AnimationController _animationController;
  Animation<_ItemCurrentPosition>? _animation;

  Offset? _lastTransform;
  _ItemCurrentPosition? _lastPosition;

  Future<void> _setLast(
      Offset? lastOffset, _ItemCurrentPosition? lastPosition) async {
    _lastTransform = lastOffset;
    _lastPosition = lastPosition;
    _multiplierAnimationController.reset();
    _multiplierAnimationController.value = 1;
    await _multiplierAnimationController
        .animateTo(0,
            duration: widget.editModeSettings.duration,
            curve: widget.editModeSettings.curve)
        .then((value) {
      setState(() {
        _lastTransform = null;
        _lastPosition = null;
      });
    });
  }

  bool get onEditMode => widget.layoutController.isEditing;

  ItemLayout? _exLayout;

  bool equal() {
    return _exLayout!.startX == widget.itemCurrentLayout.startX &&
        _exLayout!.startY == widget.itemCurrentLayout.startY &&
        _exLayout!.width == widget.itemCurrentLayout.width &&
        _exLayout!.height == widget.itemCurrentLayout.height;
  }

  bool onAnimation = false;
  DateTime? animationStart;

  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;

    if (onEditMode) {
      if (widget.layoutController.absorbPointer) {
        result = AbsorbPointer(child: result);
      }
      result = MouseRegion(
        cursor: cursor,
        onHover: _hover,
        onExit: _exit,
        child: result,
      );
    }

    var currentEdit = widget.layoutController.editSession?.editing.id ==
        widget.itemCurrentLayout.id;

    var transform =
        currentEdit ? widget.layoutController.editSession!.transform : false;

    var onlyDimensions = currentEdit && transform;

    if (onAnimation ||
        ((currentEdit ? transform : true) &&
            (onEditMode || widget.layoutController.animateEverytime) &&
            ex != null &&
            (widget.itemCurrentLayout._change))) {
      widget.itemCurrentLayout._change = false;

      if (onAnimation) {
        ex = _animation!.value;

        var difMicro = (widget.editModeSettings.duration -
                (DateTime.now().difference(animationStart!).abs()))
            .inMicroseconds;
        _animationController.duration = Duration(
            microseconds: difMicro.clamp(
                0, widget.editModeSettings.duration.inMicroseconds));
      } else {
        animationStart = DateTime.now();
        onAnimation = true;
      }
      _animationController.reset();

      _animation = CurvedAnimation(
              parent: _animationController,
              curve: widget.editModeSettings.curve)
          .drive(_ItemCurrentPositionTween(
              begin: onlyDimensions
                  ? _ItemCurrentPosition(
                      height: ex!.height,
                      width: ex!.width,
                      y: widget.itemGlobalPosition.y,
                      x: widget.itemGlobalPosition.x)
                  : ex!,
              end: widget.itemGlobalPosition,
              onlyDimensions: onlyDimensions));

      _animationController.forward().then((value) {
        onAnimation = false;
        animationStart = null;
        _animationController.duration = widget.editModeSettings.duration;
        _animation = null;
        widget.itemCurrentLayout._change = false;
        ex = widget.itemGlobalPosition;
      });
    } else {
      ex = widget.itemGlobalPosition;
      widget.itemCurrentLayout._change = false;
    }
    if (!onEditMode && !widget.layoutController.animateEverytime) {
      var cp = widget.itemGlobalPosition;
      return Positioned(
          left: cp.x,
          top: cp.y - widget.offset.pixels,
          width: cp.width,
          height: cp.height,
          child: result);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        if (widget.itemCurrentLayout._resizePosition != null)
          widget.itemCurrentLayout._resizePosition,
        if (widget.itemCurrentLayout._transform != null)
          widget.itemCurrentLayout._transform,
        if (_animation != null) _animation,
        if (onEditMode) _multiplierAnimationController,
      ]),
      child: result,
      builder: (c, w) {
        var m = _multiplierAnimationController.value;

        var p = widget.itemCurrentLayout._resizePosition?.value;

        var cp = onAnimation
            ? (_animation?.value ?? widget.itemGlobalPosition)
            : widget.itemGlobalPosition;

        if (p != null) {
          if (_lastPosition != null) {
            p = _lastPosition! * m;
          }
          cp += p;
        }
        double left = cp.x, top = cp.y;

        var o = widget.itemCurrentLayout._transform?.value;

        if (o != null) {
          if (_lastTransform != null) {
            o = _lastTransform! * m;
          }
          left += o.dx;
          top += o.dy;
        }

        var wi = cp.width;

        if (!widget.editModeSettings.draggableOutside) {
          final constraints =
              widget.layoutController._viewportDelegate.constraints;
          final maxW = constraints.maxWidth;

          if (left < 0) {
            left = 0;
          } else if (left + wi > maxW) {
            left = maxW - wi;
          }

          if (!widget.editModeSettings.autoScroll) {
            if (o != null) {
              final maxH = constraints.maxHeight;
              final hi = cp.height;
              final scrollOffset = widget.offset.pixels;

              if (top < scrollOffset) {
                top = scrollOffset;
              } else if (top + hi > maxH + scrollOffset) {
                top = maxH + scrollOffset - hi;
              }
            }
          }
        }

        return Positioned(
            left: left,
            top: top - widget.offset.pixels,
            width: cp.width,
            height: cp.height,
            child: w!);
      },
    );
  }
}
