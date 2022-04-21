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
  late DashboardLayoutController<T> _layoutController;

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
  final GlobalKey<_DashboardStackState> _stateKey = GlobalKey();

  bool scrollable = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      Unbounded.check(widget.axis, constrains);
      return Scrollable(
          physics: scrollable
              ? widget.physics
              : const NeverScrollableScrollPhysics(),
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
                onScrollStateChange: (st) {
                  setState(() {
                    scrollable = st;
                  });
                },
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

class _ItemCurrentPositionTween extends Tween<ItemCurrentPosition> {
  _ItemCurrentPositionTween(
      {required ItemCurrentPosition begin, required ItemCurrentPosition end})
      : super(begin: begin, end: end);

  @override
  ItemCurrentPosition lerp(double t) {
    return ItemCurrentPosition(
        width: begin!.width * (1.0 - t) + end!.width * t,
        height: begin!.height * (1.0 - t) + end!.height * t,
        x: begin!.x * (1.0 - t) + end!.x * t,
        y: begin!.y * (1.0 - t) + end!.y * t);
  }
}
