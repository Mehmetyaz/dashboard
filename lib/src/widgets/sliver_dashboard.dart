part of '../dashboard_base.dart';

class SliverDashboardViewportOffset extends ViewportOffset {
  SliverDashboardViewportOffset(this.context);

  final BuildContext context;

  ScrollPosition? get _position {
    try {
      return Scrollable.maybeOf(context)?.position;
    } catch (_) {
      return null;
    }
  }

  @override
  double get pixels => 0.0;

  @override
  bool get hasPixels => true;

  @override
  ScrollDirection get userScrollDirection =>
      _position?.userScrollDirection ?? ScrollDirection.idle;

  @override
  bool get allowImplicitScrolling => _position?.allowImplicitScrolling ?? false;

  @override
  void correctBy(double correction) {}

  @override
  bool applyViewportDimension(double viewportDimension) => true;

  @override
  bool applyContentDimensions(
          double minScrollExtent, double maxScrollExtent) =>
      true;

  @override
  void jumpTo(double pixels) {
    final pos = _position;
    if (pos != null && pos.hasPixels) {
      pos.jumpTo(pixels + pos.pixels);
    }
  }

  @override
  Future<void> animateTo(double pixels,
      {required Duration duration, required Curve curve}) {
    final pos = _position;
    if (pos != null && pos.hasPixels) {
      return pos.animateTo(pixels + pos.pixels,
          duration: duration, curve: curve);
    }
    return Future.value();
  }
}

class SliverDashboard<T extends DashboardItem> extends StatefulWidget {
  SliverDashboard({
    super.key,
    required this.itemBuilder,
    required this.dashboardItemController,
    this.slotCount = 8,
    this.cacheExtend = 500,
    this.verticalSpace = 8,
    this.horizontalSpace = 8,
    this.padding = const EdgeInsets.all(0),
    this.shrinkToPlace = true,
    this.slideToTop = true,
    this.slotAspectRatio,
    this.slotHeight,
    EditModeSettings? editModeSettings,
    this.textDirection = TextDirection.ltr,
    this.errorPlaceholder,
    this.loadingPlaceholder,
    this.emptyPlaceholder,
    this.absorbPointer = true,
    this.animateEverytime = true,
    this.itemStyle = const ItemStyle(),
    this.scrollToAdded = true,
    this.slotBackgroundBuilder,
  })  : assert((slotHeight == null && slotAspectRatio == null) ||
            !(slotHeight != null && slotAspectRatio != null)),
        editModeSettings = editModeSettings ?? EditModeSettings();

  final SlotBackgroundBuilder<T>? slotBackgroundBuilder;
  final bool scrollToAdded;
  final double? slotAspectRatio;
  final double? slotHeight;
  final bool animateEverytime;
  final bool absorbPointer;
  final DashboardItemBuilder<T> itemBuilder;
  final double cacheExtend;
  final EditModeSettings editModeSettings;
  final Widget? loadingPlaceholder;
  final Widget? emptyPlaceholder;
  final Widget Function(Object error, StackTrace stackTrace)? errorPlaceholder;
  final DashboardItemController<T> dashboardItemController;
  final int slotCount;
  final double horizontalSpace;
  final double verticalSpace;
  final EdgeInsetsGeometry padding;
  final bool shrinkToPlace;
  final bool slideToTop;
  final TextDirection textDirection;
  final ItemStyle itemStyle;

  @override
  State<SliverDashboard<T>> createState() => _SliverDashboardState<T>();
}

class _SliverDashboardState<T extends DashboardItem>
    extends State<SliverDashboard<T>> with TickerProviderStateMixin {
  late final _DashboardLayoutController<T> _layoutController;
  late final SliverDashboardViewportOffset _viewportOffset;
  final GlobalKey<_DashboardStackState<T>> _stateKey =
      GlobalKey<_DashboardStackState<T>>();

  bool _building = true;
  bool _reloading = false;
  int? _reloadFor;
  bool _moving = false;
  bool scrollable = true;

  AsyncSnapshot? get _snap => widget.dashboardItemController._asyncSnap?.value;
  bool get _withDelegate =>
      widget.dashboardItemController.itemStorageDelegate != null;

  @override
  void initState() {
    super.initState();
    _layoutController = _DashboardLayoutController<T>();
    _layoutController.addListener(_onLayoutChanged);
    _viewportOffset = SliverDashboardViewportOffset(context);

    widget.dashboardItemController._attach(_layoutController);
    if (_withDelegate) {
      widget.dashboardItemController._loadItems(widget.slotCount);
      widget.dashboardItemController._asyncSnap!.addListener(_onSnapChanged);
    }
  }

  void _onLayoutChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSnapChanged() {
    if (mounted && !_building) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _layoutController.removeListener(_onLayoutChanged);
    if (_withDelegate) {
      widget.dashboardItemController._asyncSnap?.removeListener(_onSnapChanged);
    }
    _viewportOffset.dispose();
    super.dispose();
  }

  void _setOnNextFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _setNewOffset(ViewportOffset o, BoxConstraints constraints,
      [bool i = true]) {
    _layoutController.absorbPointer = widget.absorbPointer;
    _layoutController._viewportDelegate = _ViewportDelegate(
        constraints: constraints,
        padding: widget.padding.resolve(widget.textDirection),
        mainAxisSpace: widget.horizontalSpace,
        crossAxisSpace: widget.verticalSpace);

    if (_layoutController._isAttached &&
        (_layoutController.slotCount != widget.slotCount ||
            _layoutController.slideToTop != widget.slideToTop ||
            _layoutController.shrinkToPlace != widget.shrinkToPlace) &&
        !_reloading) {
      _layoutController.attach(
          viewportOffset: o,
          shrinkOnMove: widget.editModeSettings.shrinkOnMove,
          animateEverytime: widget.animateEverytime,
          slideToTop: widget.slideToTop,
          shrinkToPlace: widget.shrinkToPlace,
          axis: Axis.vertical,
          itemController: widget.dashboardItemController,
          slotCount: widget.slotCount,
          scrollToAdded: widget.scrollToAdded);
      _setOnNextFrame();
    }

    if (!_layoutController._isAttached) {
      _layoutController.attach(
          viewportOffset: o,
          shrinkOnMove: widget.editModeSettings.shrinkOnMove,
          animateEverytime: widget.animateEverytime,
          slideToTop: widget.slideToTop,
          shrinkToPlace: widget.shrinkToPlace,
          axis: Axis.vertical,
          itemController: widget.dashboardItemController,
          slotCount: widget.slotCount,
          scrollToAdded: widget.scrollToAdded);
      _setOnNextFrame();
    }

    double h;

    if (widget.slotHeight != null) {
      h = widget.slotHeight!;
    } else if (widget.slotAspectRatio != null) {
      h = _layoutController._viewportDelegate.resolvedConstrains.maxWidth /
          widget.slotCount /
          widget.slotAspectRatio!;
    } else {
      h = _layoutController._viewportDelegate.resolvedConstrains.maxWidth /
          widget.slotCount;
    }

    _layoutController._setSizes(
        _layoutController._viewportDelegate.resolvedConstrains, h);
  }

  @override
  Widget build(BuildContext context) {
    _building = true;
    bool differentReload = _reloadFor != widget.slotCount;
    if (_layoutController._isAttached &&
        (!_reloading || differentReload) &&
        _layoutController.slotCount != widget.slotCount &&
        _withDelegate &&
        widget
            .dashboardItemController.itemStorageDelegate!.layoutsBySlotCount) {
      _reloading = true;
      _reloadFor = widget.slotCount;
      widget.dashboardItemController._items.clear();
      _layoutController._startsTree.clear();
      _layoutController._indexesTree.clear();
      _layoutController._endsTree.clear();
      var loader = widget.dashboardItemController._loadItems(widget.slotCount);

      if (loader is Future) {
        loader.then((value) {
          if (_reloadFor == widget.slotCount) {
            _reloading = false;
            _layoutController.attach(
                viewportOffset: _viewportOffset,
                shrinkOnMove: widget.editModeSettings.shrinkOnMove,
                animateEverytime: widget.animateEverytime,
                slideToTop: widget.slideToTop,
                shrinkToPlace: widget.shrinkToPlace,
                axis: Axis.vertical,
                itemController: widget.dashboardItemController,
                slotCount: widget.slotCount,
                scrollToAdded: widget.scrollToAdded);
          }
        });
      } else {
        if (_reloadFor == widget.slotCount) {
          _reloading = false;
          _layoutController.attach(
              viewportOffset: _viewportOffset,
              shrinkOnMove: widget.editModeSettings.shrinkOnMove,
              animateEverytime: widget.animateEverytime,
              slideToTop: widget.slideToTop,
              shrinkToPlace: widget.shrinkToPlace,
              axis: Axis.vertical,
              itemController: widget.dashboardItemController,
              slotCount: widget.slotCount,
              scrollToAdded: widget.scrollToAdded);
        }
      }
    }

    if (_withDelegate) {
      if (_snap!.connectionState == ConnectionState.none) {
        _building = false;
        return SliverToBoxAdapter(
          child: widget.errorPlaceholder
                  ?.call(_snap!.error!, _snap!.stackTrace!) ??
              const SizedBox(),
        );
      } else if (_snap!.connectionState == ConnectionState.waiting ||
          _reloading) {
        _building = false;
        return SliverToBoxAdapter(
          child: widget.loadingPlaceholder ??
              const Center(
                child: CircularProgressIndicator(),
              ),
        );
      }
    }

    return SliverLayoutBuilder(builder: (context, constraints) {
      final totalHeight = _layoutController.totalContentHeight;

      // Note: We layout the child with the full content height so it renders
      // all child widgets at their absolute coordinate positions.
      final boxConstraints = BoxConstraints(
        minWidth: constraints.crossAxisExtent,
        maxWidth: constraints.crossAxisExtent,
        minHeight: totalHeight,
        maxHeight: totalHeight,
      );

      Unbounded.check(Axis.vertical, boxConstraints);

      if (!_reloading) {
        _setNewOffset(_viewportOffset, boxConstraints);
      }

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _stateKey.currentState?._listenOffset(_viewportOffset);
      });
      _building = false;

      return SliverDashboardWrapper(
        viewportOffset: _viewportOffset,
        totalContentHeight: totalHeight,
        child: _DashboardStack<T>(
          itemStyle: widget.itemStyle,
          shouldCalculateNewDimensions: () {
            if (_moving) {
              return;
            }
            _setNewOffset(_viewportOffset, boxConstraints);
          },
          onScrollStateChange: (st) {
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              _moving = !st;
              setState(() {
                scrollable = st;
              });
              if (!_moving) {
                return;
              }
              _setNewOffset(_viewportOffset, boxConstraints, _moving);
            });
          },
          emptyPlaceholder: widget.emptyPlaceholder,
          maxScrollOffset: totalHeight - constraints.viewportMainAxisExtent,
          editModeSettings: widget.editModeSettings,
          cacheExtend: widget.cacheExtend,
          key: _stateKey,
          itemBuilder: widget.itemBuilder,
          dashboardController: _layoutController,
          offset: _viewportOffset,
          slotBackground: widget.slotBackgroundBuilder,
        ),
      );
    });
  }
}

class SliverDashboardWrapper extends SingleChildRenderObjectWidget {
  const SliverDashboardWrapper({
    super.key,
    required this.viewportOffset,
    required this.totalContentHeight,
    required super.child,
  });

  final SliverDashboardViewportOffset viewportOffset;
  final double totalContentHeight;

  @override
  RenderSliverDashboard createRenderObject(BuildContext context) {
    return RenderSliverDashboard(
      viewportOffset: viewportOffset,
      totalContentHeight: totalContentHeight,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverDashboard renderObject) {
    renderObject.totalContentHeight = totalContentHeight;
  }
}

class RenderSliverDashboard extends RenderSliverSingleBoxAdapter {
  // ignore: prefer_initializing_formals
  RenderSliverDashboard({
    required this.viewportOffset,
    required double totalContentHeight,
  }) : _totalContentHeight = totalContentHeight; // ignore: prefer_initializing_formals

  final SliverDashboardViewportOffset viewportOffset;

  double _totalContentHeight;
  double get totalContentHeight => _totalContentHeight;
  set totalContentHeight(double value) {
    if (_totalContentHeight != value) {
      _totalContentHeight = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final SliverConstraints constraints = this.constraints;

    child!.layout(
      BoxConstraints(
        minWidth: constraints.crossAxisExtent,
        maxWidth: constraints.crossAxisExtent,
        minHeight: totalContentHeight,
        maxHeight: totalContentHeight,
      ),
      parentUsesSize: true,
    );

    final double childExtent = totalContentHeight;
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );

    final SliverPhysicalParentData childParentData =
        child!.parentData! as SliverPhysicalParentData;
    childParentData.paintOffset = Offset(0.0, -constraints.scrollOffset);
  }
}
