part of dashboard;

class _DashboardStack<T> extends StatefulWidget {
  const _DashboardStack(
      {Key? key,
      required this.editModeSettings,
      required this.offset,
      required this.dashboardController,
      required this.itemBuilder,
      required this.cacheExtend,
      required this.maxScrollOffset,
      required this.onScrollStateChange})
      : super(key: key);

  final ViewportOffset offset;
  final DashboardLayoutController<T> dashboardController;
  final double cacheExtend;
  final EditModeSettings editModeSettings;
  final double maxScrollOffset;
  final void Function(bool scrollable) onScrollStateChange;

  ///
  final DashboardItemBuilder<T> itemBuilder;

  @override
  State<_DashboardStack> createState() => _DashboardStackState();
}

class _DashboardStackState extends State<_DashboardStack> {
  ///
  ViewportOffset get viewportOffset => widget.offset;

  ViewportDelegate get viewportDelegate =>
      widget.dashboardController._viewportDelegate;

  ///
  double get pixels => viewportOffset.pixels;

  ///
  double get width => viewportDelegate.resolvedConstrains.maxWidth;

  ///
  double get height => viewportDelegate.resolvedConstrains.maxHeight;

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
    (list[0] as ItemCurrentLayout)._key = _keys[list[2]]!;
    return _DashboardItemWidget(
      key: _keys[list[2]]!,
      itemGlobalPosition: (list[0] as ItemCurrentLayout).currentPosition(
          viewportDelegate: viewportDelegate, slotEdge: slotEdge),
      itemCurrentLayout: list[0],
      id: list[2],
      editModeSettings: widget.editModeSettings,
      child: list[1],
      offset: pixels,
      layoutController: widget.dashboardController,
    );
  }

  late double slotEdge;

  final Map<String, List> _widgetsMap = <String, List>{};

  void addWidget(String id) {
    var i = widget.dashboardController.itemController._items[id];
    var l = widget.dashboardController._layouts[i!.identifier]!;
    _widgetsMap[id] = [
      l,
      widget.itemBuilder(i, l),
      id,
    ];

    _keys[id] ??= GlobalKey<_DashboardItemWidgetState>();
  }

  final Map<String, GlobalKey<_DashboardItemWidgetState>> _keys = {};

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

    var needs = <String>[];
    var key = startIndex;

    if (widget.dashboardController._indexesTree[key] != null) {
      needs.add(widget.dashboardController._indexesTree[key]!);
    }

    while (true) {
      var f = widget.dashboardController._indexesTree.firstKeyAfter(key);
      if (f != null) {
        key = f;
        needs.add(widget.dashboardController._indexesTree[key]!);
        if (key >= endIndex) {
          break;
        }
      } else {
        break;
      }
    }

    var beforeIt = <String>[];
    key = startIndex;
    while (true) {
      var f = widget.dashboardController._indexesTree.lastKeyBefore(key);
      if (f != null) {
        key = f;
        beforeIt.add(widget.dashboardController._indexesTree[key]!);
      } else {
        break;
      }
    }

    var afterIt = <String>[];
    key = startIndex;
    while (true) {
      var f = widget.dashboardController._indexesTree.firstKeyAfter(key);
      if (f != null) {
        key = f;
        afterIt.add(widget.dashboardController._indexesTree[key]!);
      } else {
        break;
      }
    }

    var needDelete = [...afterIt, ...beforeIt];
    var edit = widget.dashboardController.editSession?.editing;

    for (var n in needDelete) {
      if (!needs.contains(n) && n != edit?.id) {
        _widgetsMap.remove(n);
      }
    }

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
      clipBehavior: Clip.hardEdge,
      children: [
        if (widget.editModeSettings.editBackground &&
            widget.dashboardController.isEditing)
          Positioned(
            top: viewportDelegate.padding.top,
            left: viewportDelegate.padding.left,
            width: viewportDelegate.constraints.maxWidth -
                viewportDelegate.padding.vertical,
            height: viewportDelegate.constraints.maxHeight -
                viewportDelegate.padding.horizontal,
            child: Builder(builder: (context) {
              return AnimatedBackgroundPainter(
                  layoutController: widget.dashboardController,
                  editModeSettings: widget.editModeSettings,
                  offset: viewportOffset.pixels);
            }),
          ),
        ..._widgetsMap.entries
            .where((element) =>
                element.value[2] !=
                widget.dashboardController.editSession?.editing.id)
            .map((e) {
          return buildPositioned(e.value);
        }).toList(),
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
        onPanStart: kIsWeb
            ? (panStart) {
                _onMoveStart(panStart.localPosition);
              }
            : null,
        onPanUpdate: kIsWeb
            ? (u) {
                setSpeed(u.localPosition);
                _onMoveUpdate(u.localPosition);
              }
            : null,
        onPanEnd: kIsWeb
            ? (e) {
                _onMoveEnd();
              }
            : null,
        onLongPressStart: kIsWeb
            ? null
            : (longPressStart) {
                _onMoveStart(longPressStart.localPosition);
              },
        onLongPressMoveUpdate: kIsWeb
            ? null
            : (u) {
                setSpeed(u.localPosition);
                _onMoveUpdate(u.localPosition);
              },
        onLongPressEnd: kIsWeb
            ? null
            : (e) {
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
    var holdGlobal = Offset(local.dx - viewportDelegate.padding.left,
        local.dy - viewportDelegate.padding.top);

    var x = (local.dx - viewportDelegate.padding.left) ~/ slotEdge;
    var y = (local.dy + pixels - viewportDelegate.padding.top) ~/ slotEdge;

    var e = widget.dashboardController
        ._indexesTree[widget.dashboardController.getIndex([x, y])];

    if (e is String) {
      var directions = <AxisDirection>[];
      _editing = widget.dashboardController._layouts[e]!;
      var _current = _editing!.currentPosition(
          slotEdge: slotEdge, viewportDelegate: viewportDelegate);
      var _itemGlobal = ItemCurrentPosition(
          x: _current.x - viewportDelegate.padding.left,
          y: _current.y - viewportDelegate.padding.top - pixels,
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

      if ((_itemGlobal.y) + widget.editModeSettings.resizeCursorSide >
          holdGlobal.dy) {
        directions.add(AxisDirection.up);
      }

      if (_itemGlobal.endX - widget.editModeSettings.resizeCursorSide <
          holdGlobal.dx) {
        directions.add(AxisDirection.right);
      }

      if ((_itemGlobal.endY) - widget.editModeSettings.resizeCursorSide <
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

      var l = widget.dashboardController._layouts[e];
      widget.dashboardController.editSession!.editing._originSize = [
        l!.width,
        l.height
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

  ItemCurrentLayout? _editing;

  bool get _editingResize => _holdDirections != null;
  List<AxisDirection>? _holdDirections;
  Offset? _moveStartOffset;
  double? _startScrollPixels;

  bool isResizing(AxisDirection direction) =>
      _holdDirections!.contains(direction);

  void _onMoveUpdate(Offset local) {
    if (_editing != null) {
      if (_editingResize) {
        var scrollDifference = pixels - _startScrollPixels!;

        var resizeMoveResult = _editing!._resizeMove(
            holdDirections: _holdDirections!,
            local: local,
            start: _moveStartOffset!,
            scrollDifference: scrollDifference);

        if (resizeMoveResult.isChanged) {
          setState(() {
            _moveStartOffset =
                _moveStartOffset! + resizeMoveResult.startDifference;
          });
        }
      } else {
        var resizeMoveResult = _editing!._transformUpdate(
            local - _moveStartOffset!, pixels - _startScrollPixels!);
        if (resizeMoveResult != null && resizeMoveResult.isChanged) {
          setState(() {
            _moveStartOffset =
                _moveStartOffset! + resizeMoveResult.startDifference;
          });
        }
      }
    }
  }

  void _onMoveEnd() {
    _editing?._key.currentState
        ?._setLast(_editing!._transform.value, _editing!._resizePosition.value)
        .then((value) {
      widget.dashboardController.editSession?.editing._originSize = null;
      _editing = null;
      _moveStartOffset = null;
      _holdDirections = null;
      _startScrollPixels = null;
      speed = 0;
      widget.dashboardController.saveEditSession();
    });
    widget.onScrollStateChange(true);
    _editing?._transform.value = Offset.zero;
    _editing?._resizePosition.value =
        ItemCurrentPosition(height: 0, width: 0, y: 0, x: 0);
  }
}
