part of dashboard;

class _DashboardStack<T> extends StatefulWidget {
  const _DashboardStack(
      {Key? key,
      required this.editModeSettings,
      required this.offset,
      required this.dashboardController,
      required this.itemBuilder,
      required this.cacheExtend,
      required this.maxScrollOffset})
      : super(key: key);

  final ViewportOffset offset;
  final DashboardLayoutController<T> dashboardController;
  final double cacheExtend;
  final EditModeSettings editModeSettings;
  final double maxScrollOffset;

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
    return _DashboardItemWidget(
      currentPosition: (list[0] as ItemCurrentLayout).currentPosition(
          offset: viewportOffset.pixels,
          viewportDelegate: viewportDelegate,
          slotEdge: slotEdge),
      itemCurrentLayout: list[0],
      id: list[2],
      editModeSettings: widget.editModeSettings,
      child: list[1],
      layoutController: widget.dashboardController,
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
    var holdGlobal = Offset(local.dx - viewportDelegate.padding.left,
        local.dy - viewportDelegate.padding.top + viewportOffset.pixels);

    var x = (local.dx - viewportDelegate.padding.left) ~/ slotEdge;
    var y = (local.dy + pixels - viewportDelegate.padding.top) ~/ slotEdge;

    var e = widget.dashboardController
        ._indexesTree[widget.dashboardController.getIndex([x, y])];

    if (e is String) {
      var directions = <AxisDirection>[];
      _editing = widget.dashboardController._layouts[e]!;
      var _current = _editing!.currentPosition(
          offset: viewportOffset.pixels,
          slotEdge: slotEdge,
          viewportDelegate: viewportDelegate);
      var _itemGlobal = ItemCurrentPosition(
          x: _current.x - viewportDelegate.padding.left,
          y: _current.y - viewportDelegate.padding.top,
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

      if ((_itemGlobal.y + viewportOffset.pixels) +
              widget.editModeSettings.resizeCursorSide >
          holdGlobal.dy) {
        directions.add(AxisDirection.up);
      }

      if (_itemGlobal.endX - widget.editModeSettings.resizeCursorSide <
          holdGlobal.dx) {
        directions.add(AxisDirection.right);
      }

      if ((_itemGlobal.endY + viewportOffset.pixels) -
              widget.editModeSettings.resizeCursorSide <
          holdGlobal.dy) {
        directions.add(AxisDirection.down);
      }
      if (directions.isNotEmpty) {
        _directions = directions;
      } else {
        _directions = null;
      }
      _start = local;
      _startScroll = pixels;
      widget.dashboardController.startEdit(e);
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
          difPos.height -=
              (dy + pixels - _startScroll! - (pixels - _startScroll!));
        }

        if (_directions!.contains(AxisDirection.right)) {
          var dx = _editing!._clampDifRight(dif.dx);
          difPos.width += dx;
        }

        if (_directions!.contains(AxisDirection.down)) {
          var dy = _editing!._clampDifBottom(dif.dy + pixels - _startScroll!);
          difPos.height += dy;
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
          if ((dif.dy) < 0) {
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
          res.adjustResizeOffset(local, slotEdge, difPos, _startScroll!);

          _editing!._resizePosition.value = res.adjustedPosition;
          addWidget(_editing!.id);
          setState(() {
            _start = res.adjustedDif;
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
    _startScroll = null;
    speed = 0;
    widget.dashboardController.saveEditSession();
  }
}
