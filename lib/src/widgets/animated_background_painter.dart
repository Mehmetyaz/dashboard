part of dashboard;

class AnimatedBackgroundPainter extends StatefulWidget {
  const AnimatedBackgroundPainter(
      {Key? key,
      required this.layoutController,
      required this.editModeSettings,
      required this.offset})
      : super(key: key);

  final DashboardLayoutController layoutController;
  final EditModeSettings editModeSettings;
  final double offset;

  @override
  State<AnimatedBackgroundPainter> createState() =>
      _AnimatedBackgroundPainterState();
}

class _AnimatedBackgroundPainterState extends State<AnimatedBackgroundPainter>
    with SingleTickerProviderStateMixin {
  ViewportDelegate get viewportDelegate =>
      widget.layoutController._viewportDelegate;

  Rect? fillRect;

  late double offset;

  late AnimationController _animationController;

  Animation<Rect?>? _animation;

  @override
  void initState() {
    offset = widget.offset;
    _animationController = AnimationController(
        vsync: this,
        duration: widget.editModeSettings.fillBackgroundAnimationDuration);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editModeSettings.fillEditingBackground &&
        widget.layoutController.editSession != null) {
      var pos = widget.layoutController.editSession?.editing.currentPosition(
          viewportDelegate: widget.layoutController._viewportDelegate,
          slotEdge: widget.layoutController.slotEdge);
      var rect = Rect.fromLTWH(pos!.x - viewportDelegate.padding.left,
          pos.y - offset - viewportDelegate.padding.top, pos.width, pos.height);

      if (fillRect != null) {
        _animationController.reset();
        _animation = RectTween(begin: fillRect!, end: rect).animate(
            CurvedAnimation(
                parent: _animationController,
                curve: widget.editModeSettings.fillBackgroundAnimationCurve));
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _animationController.forward();
        });
      }
      fillRect = rect;
    }

    if (widget.layoutController.editSession == null ||
        !widget.editModeSettings.fillEditingBackground) {
      fillRect = null;
      _animation = null;
    }

    if (_animation != null && offset == widget.offset) {
      offset = widget.offset;
      return AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            return CustomPaint(
              painter: EditModeBackgroundPainter(
                  fillPosition: _animation!.value,
                  slotCount: widget.layoutController.slotCount,
                  style: widget.editModeSettings.backgroundStyle,
                  slotEdge: widget.layoutController.slotEdge,
                  offset: widget.offset,
                  viewportDelegate: widget.layoutController._viewportDelegate),
              isComplex: true,
            );
          });
    } else {
      offset = widget.offset;
      return CustomPaint(
        painter: EditModeBackgroundPainter(
            fillPosition: fillRect,
            slotCount: widget.layoutController.slotCount,
            style: widget.editModeSettings.backgroundStyle,
            slotEdge: widget.layoutController.slotEdge,
            offset: widget.offset,
            viewportDelegate: widget.layoutController._viewportDelegate),
        isComplex: true,
      );
    }
  }
}
