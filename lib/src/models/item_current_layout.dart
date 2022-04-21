part of dashboard;

class ItemCurrentPosition {
  ItemCurrentPosition(
      {required this.height,
      required this.width,
      required this.y,
      required this.x});

  double width, height, x, y;

  double get endX => x + width;

  double get endY => y + height;

  ItemCurrentPosition operator +(ItemCurrentPosition other) {
    return ItemCurrentPosition(
        height: height + other.height,
        width: width + other.width,
        y: y + other.y,
        x: x + other.x);
  }

  bool equal(ItemCurrentPosition other) {
    return x == other.x &&
        y == other.y &&
        width == other.width &&
        height == other.height;
  }

  @override
  String toString() {
    return "ITEM_CURRENT($x, $y , $width , $height)";
  }
}

abstract class _Change {
  _Change(this.direction, this.increment);

  ItemLayout back(ItemLayout layout);

  AxisDirection direction;
  bool increment;
}

class Resizing extends _Change {
  Resizing(AxisDirection direction, bool increment)
      : super(direction, increment);

  @override
  String toString() {
    return "RESIZE ${increment ? "increment" : "decrement"} $direction";
  }

  @override
  ItemLayout back(ItemLayout layout) {
    int x = layout.startX,
        y = layout.startY,
        w = layout.width,
        h = layout.height;
    if (direction == AxisDirection.left) {
      x -= 1;
      w += 1;
    } else if (direction == AxisDirection.right) {
      w += 1;
    } else if (direction == AxisDirection.up) {
      y -= 1;
      h += 1;
    } else {
      h += 1;
    }
    return ItemLayout(startX: x, startY: y, width: w, height: h);
  }
}

class Moving extends _Change {
  Moving(AxisDirection direction, bool increment) : super(direction, increment);

  @override
  String toString() {
    return "MOVE: ${increment ? "increment" : "decrement"} $direction";
  }

  @override
  ItemLayout back(ItemLayout layout) {

    int x = layout.startX, y = layout.startY;
    if (direction == AxisDirection.left) {
      x -= 1;
    } else if (direction == AxisDirection.right) {
      x += 1;
    } else if (direction == AxisDirection.up) {
      y -= 1;
    } else {
      y += 1;
    }
    return ItemLayout(
        startX: x, startY: y, width: layout.width, height: layout.height);
  }
}

class Resize {
  Resize(this.resize, {this.indirectResizes});

  Resizing resize;

  Map<String, _Change>? indirectResizes;

  late Offset offsetDifference;
  late ItemCurrentPosition positionDifference;

  void adjustResizeOffset(double slotEdge, ItemCurrentPosition difPos) {
    Offset? difOffset;
    if (resize.increment) {
      if (resize.direction == AxisDirection.left) {
        difPos
          ..x += slotEdge
          ..width -= slotEdge;
        difOffset = Offset(-slotEdge, 0);
      } else if (resize.direction == AxisDirection.up) {
        difPos
          ..y += slotEdge
          ..height -= slotEdge;
        difOffset = Offset(0, -slotEdge);
      } else if (resize.direction == AxisDirection.right) {
        difPos.width -= slotEdge;
        difOffset = Offset(slotEdge, 0);
      } else {
        difPos.height -= slotEdge;
        difOffset = Offset(0, slotEdge);
      }
    } else {
      if (resize.direction == AxisDirection.left) {
        difPos.x += 0;
        difOffset = Offset(slotEdge, 0);
      } else if (resize.direction == AxisDirection.up) {
        difPos.y += 0;
        difOffset = Offset(0, slotEdge);
      } else if (resize.direction == AxisDirection.right) {
        difOffset = Offset(-slotEdge, 0);
      } else {
        difOffset = Offset(0, -slotEdge);
      }
    }

    offsetDifference = difOffset;
    positionDifference = difPos;
  }
}

class ResizeMoveResult {
  ResizeMoveResult();

  /// Move start offset
  Offset startDifference = const Offset(0, 0);

  bool isChanged = false;
}

///
class ItemCurrentLayout implements ItemLayout {
  ///
  ItemCurrentLayout(this.origin);

  ValueNotifier<Offset> _transform = ValueNotifier(Offset.zero);
  ValueNotifier<ItemCurrentPosition> _resizePosition =
      ValueNotifier(ItemCurrentPosition(y: 0, x: 0, height: 0, width: 0));

  late GlobalKey<_DashboardItemWidgetState> _key;

  @override
  String toString() {
    return "current: (startX: $startX , startY: $startY , width: $width , height: $height)"
        "\n origin: ($origin)";
  }

  ItemCurrentPosition currentPosition(
      {required ViewportDelegate viewportDelegate, required double slotEdge}) {
    var leftPad = isLeftSide ? 0.0 : viewportDelegate.crossAxisSpace / 2;
    var rightPad = isRightSide ? 0.0 : viewportDelegate.crossAxisSpace / 2;
    var topPad = isTopSide ? 0.0 : viewportDelegate.mainAxisSpace / 2;
    var bottomPad = isBottomSide ? 0.0 : viewportDelegate.mainAxisSpace / 2;
    return ItemCurrentPosition(
        height: height * slotEdge - topPad - bottomPad,
        width: width * slotEdge - rightPad - leftPad,
        y: ((startY * (slotEdge))) + viewportDelegate.padding.top + topPad,
        x: (startX * slotEdge) + viewportDelegate.padding.left + leftPad);
  }

  double get _slotEdge {
    return _layoutController.slotEdge;
  }

  double _clampDifLeft(double x) {
    var _slot = _slotEdge;
    return x.clamp(0, (width - minWidth) * _slot);
  }

  double _clampDifRight(double x) {
    var _slot = _slotEdge;
    return x.clamp(
      (width - minWidth) * -_slot,
      0,
    );
  }

  double _clampDifTop(double y) {
    var _slot = _slotEdge;
    return y.clamp(0, (height - minHeight) * _slot);
  }

  double _clampDifBottom(double y) {
    var _slot = _slotEdge;
    return y.clamp(
      (height - minHeight) * -_slot,
      0,
    );
  }

  ResizeMoveResult _resizeMove(
      {required List<AxisDirection> holdDirections,
      required Offset local,
      required Offset start,
      required double scrollDifference}) {
    var difference = local - start;
    difference += Offset(0, scrollDifference);
    if (holdDirections.isEmpty || (difference == Offset.zero)) {
      return ResizeMoveResult();
    }

    var result = ResizeMoveResult();

    var itemPositionDifference =
        ItemCurrentPosition(height: 0, width: 0, y: 0, x: 0);

    if (holdDirections.contains(AxisDirection.left)) {
      Resizing? resizing;

      if (difference.dx < 0) {
        resizing = (Resizing(AxisDirection.left, true));
      } else if (difference.dx > _slotEdge) {
        resizing = (Resizing(AxisDirection.left, false));
      }

      var res = tryResize(resizing);
      if (res != null) {
        itemPositionDifference =
            _saveResizeResult(res, itemPositionDifference, result);
      } else {
        var dx = _clampDifLeft(difference.dx);
        itemPositionDifference.x += dx;
        itemPositionDifference.width -= dx;
      }
    }
    if (holdDirections.contains(AxisDirection.up)) {
      Resizing? resizing;

      if (difference.dy < 0) {
        resizing = (Resizing(AxisDirection.up, true));
      } else if (difference.dy > _slotEdge) {
        resizing = (Resizing(AxisDirection.up, false));
      }
      var res = tryResize(resizing);
      if (res != null) {
        itemPositionDifference =
            _saveResizeResult(res, itemPositionDifference, result);
      } else {
        var dy = _clampDifTop(difference.dy);
        itemPositionDifference.y += dy;
        itemPositionDifference.height -= dy;
      }
    }

    if (holdDirections.contains(AxisDirection.right)) {
      Resizing? resizing;

      if (difference.dx < -_slotEdge) {
        resizing = (Resizing(AxisDirection.right, false));
      } else if (difference.dx > 0) {
        resizing = (Resizing(AxisDirection.right, true));
      }
      var res = tryResize(resizing);
      if (res != null) {
        _saveResizeResult(res, itemPositionDifference, result);
      } else {
        var dx = _clampDifRight(difference.dx);
        itemPositionDifference.width += dx;
      }
    }

    if (holdDirections.contains(AxisDirection.down)) {
      Resizing? resizing;
      //BOTTOM
      if (difference.dy < -_slotEdge) {
        resizing = (Resizing(AxisDirection.down, false));
      } else if (difference.dy > 0) {
        resizing = (Resizing(AxisDirection.down, true));
      }
      var res = tryResize(resizing);
      if (res != null) {
        _saveResizeResult(res, itemPositionDifference, result);
      } else {
        var dy = _clampDifBottom(difference.dy);
        itemPositionDifference.height += dy;
      }
    }
    _resizePosition.value = itemPositionDifference;
    return result;
  }

  ItemCurrentPosition _saveResizeResult(Resize res,
      ItemCurrentPosition itemPositionDifference, ResizeMoveResult result) {
    save();
    res.adjustResizeOffset(_slotEdge, itemPositionDifference);
    result.startDifference += res.offsetDifference;
    result.isChanged = true;
    return res.positionDifference;
  }

  /// If side is layout bound returns null
  List<ItemCurrentLayout>? sideItems(AxisDirection direction) {
    var sideItemsIds = <String>[];

    List<int> sideIndexes;

    if (direction == AxisDirection.left) {
      if (startX == 0) {
        return null;
      }
      sideIndexes = _layoutController.getItemIndexes(ItemLayout(
          startX: startX - 1, startY: startY, width: 1, height: height));
    } else if (direction == AxisDirection.right) {
      if ((startX + width) >= _layoutController.slotCount) {
        return null;
      }
      sideIndexes = _layoutController.getItemIndexes(ItemLayout(
          startX: startX + width, startY: startY, width: 1, height: height));
    } else if (direction == AxisDirection.up) {
      if (startY == 0) {
        return null;
      }
      sideIndexes = _layoutController.getItemIndexes(ItemLayout(
          startX: startX, startY: startY - 1, width: width, height: 1));
    } else {
      sideIndexes = _layoutController.getItemIndexes(ItemLayout(
          startX: startX, startY: startY + height, width: width, height: 1));
    }

    for (var i in sideIndexes) {
      var item = _layoutController._indexesTree[i];
      if (item != null && !sideItemsIds.contains(item)) {
        sideItemsIds.add(item);
      }
    }

    return sideItemsIds.map((e) => _layoutController._layouts[e]!).toList();
  }

  _Change? tryDecrementOrMoveTo(AxisDirection direction) {
    AxisDirection reverseDir;
    switch (direction) {
      case AxisDirection.up:
        reverseDir = AxisDirection.down;
        break;
      case AxisDirection.right:
        reverseDir = AxisDirection.left;
        break;
      case AxisDirection.down:
        reverseDir = AxisDirection.up;
        break;
      case AxisDirection.left:
        reverseDir = AxisDirection.right;
        break;
    }

    var side = sideItems(direction);


    if (side != null && side.isEmpty) {
      if (direction == AxisDirection.left) {
        _startX = startX - 1;
        return Moving(reverseDir, false);
      } else if (direction == AxisDirection.right) {
        _startX = startX + 1;
        return Moving(reverseDir, true);
      } else if (direction == AxisDirection.up) {
        _startY = startY - 1;
        return Moving(reverseDir, false);
      } else {
        _startY = startY + 1;
        return Moving(reverseDir, true);
      }
    }

    var resize = Resizing(reverseDir, false);
    if (reverseDir == AxisDirection.up) {
      if (minHeight < height) {
        _height = height - 1;
        _startY = startY + 1;
        return resize;
      }
    } else if (reverseDir == AxisDirection.down) {
      if (minHeight < height) {
        _height = height - 1;
        return resize;
      }
    } else if (reverseDir == AxisDirection.left) {
      if (minWidth < width) {
        _width = width - 1;
        _startX = startX + 1;
        return (resize);
      }
    } else {
      // right
      if (minWidth < width) {
        _width = width - 1;
        return (resize);
      }
    }

    return null;
  }

  void _backResize(_Change change) {
    var res = change.back(ItemLayout(
        startX: startX, startY: startY, width: width, height: height));

    _startX = res.startX;
    _startY = res.startY;
    _width = res.width;
    _height = res.height;

    return;
  }

  Resize? tryResize(Resizing? resize) {
    if (resize == null) return null;
    var direction = resize.direction;
    if (resize.increment) {
      var _sideItems = sideItems(direction);
      if (_sideItems == null) {
        return null;
      } else if (_sideItems.isEmpty) {
        if (direction == AxisDirection.left) {
          if ((maxWidth == null || width < maxWidth!) &&
              width < _layoutController.slotCount) {
            _startX = startX - 1;
            _width = width + 1;
            return Resize(resize);
          }
        } else if (direction == AxisDirection.right) {
          if ((maxWidth == null || width < maxWidth!) &&
              width < _layoutController.slotCount) {
            _width = width + 1;
            return Resize(resize);
          }
        } else if (direction == AxisDirection.up) {
          if ((maxHeight == null || height < maxHeight!)) {
            _startY = startY - 1;
            _height = height + 1;
            return Resize(resize);
          }
        } else {
          if (maxHeight == null || height < maxHeight!) {
            _height = height + 1;
            return Resize(resize);
          }
        }
      } else {
        Map<String, _Change> _indirectResizing = {};

        for (var sideItem in _sideItems) {
          var res = sideItem.tryDecrementOrMoveTo(direction);

          if (res == null) {
            _indirectResizing.forEach((key, value) {
              _layoutController._layouts[key]?._backResize(value);
              _layoutController._layouts[key]?.save();
            });
            _indirectResizing.clear();
            break;
          }
          _indirectResizing[sideItem.id] = res;
        }

        if (_indirectResizing.isEmpty) return null;

        _indirectResizing.forEach((key, value) {
          _layoutController._layouts[key]?.save();
        });

        Resize? result;

        if (direction == AxisDirection.left) {
          if ((maxWidth == null || width < maxWidth!) &&
              width < _layoutController.slotCount) {
            _startX = startX - 1;
            _width = width + 1;
            result = Resize(resize, indirectResizes: _indirectResizing);
          }
        } else if (direction == AxisDirection.right) {
          if ((maxWidth == null || width < maxWidth!) &&
              width < _layoutController.slotCount) {
            _width = width + 1;
            result = Resize(resize, indirectResizes: _indirectResizing);
          }
        } else if (direction == AxisDirection.up) {
          if ((maxHeight == null || height < maxHeight!)) {
            _startY = startY - 1;
            _height = height + 1;
            result = Resize(resize, indirectResizes: _indirectResizing);
          }
        } else {
          if (maxHeight == null || height < maxHeight!) {
            _height = height + 1;
            result = Resize(resize, indirectResizes: _indirectResizing);
          }
        }

        if (result == null) {
          _indirectResizing.forEach((key, value) {
            _layoutController._layouts[key]?._backResize(value);
            _layoutController._layouts[key]?.save();
          });

          return null;
        } else {
          _layoutController.editSession!._addResize(result, (i, p1) {
            _layoutController._layouts[i]?._backResize(p1);
            _layoutController._layouts[i]?.save();
          });

          return result;
        }
      }
    } else {
      Resize? result;

      //decrement size by direction
      if (direction == AxisDirection.up) {
        if (minHeight < height) {
          _height = height - 1;
          _startY = startY + 1;
          result = Resize(resize);
        }
      } else if (direction == AxisDirection.down) {
        if (minHeight < height) {
          _height = height - 1;
          result = Resize(resize);
        }
      } else if (direction == AxisDirection.left) {
        if (minWidth < width) {
          _width = width - 1;
          _startX = startX + 1;
          result = Resize(resize);
        }
      } else {
        // right
        if (minWidth < width) {
          _width = width - 1;
          result = Resize(resize);
        }
      }

      if (result != null) {
        _layoutController.editSession!._addResize(result, (id, p1) {
          _layoutController._layouts[id]?._backResize(p1);
          _layoutController._layouts[id]?.save();
        });
        return result;
      }
    }
    return null;
  }

  bool _onTransformProcess = false;

  List<int>? _originSize;

  ResizeMoveResult? _transformUpdate(
      Offset offsetDifference, double scrollDifference) {
    if (_onTransformProcess) return null;
    _onTransformProcess = true;
    var newTransform = offsetDifference + Offset(0, scrollDifference);

    var newStartX = ((newTransform.dx / _slotEdge).floor() + origin.startX)
        .clamp(0, _layoutController.slotCount - 1);
    var newStartY = ((newTransform.dy / _slotEdge).floor() + origin.startY)
        .clamp(0, 9999999999999);

    if ((newStartX != startX || newStartY != startY)) {
      _layoutController._removeFromIndexes(
          ItemLayout(
              startX: startX, startY: startY, width: width, height: height),
          id);
      var nLayout = _layoutController.tryMount(
          _layoutController.getIndex([newStartX, newStartY]),
          ItemLayout(
              startX: newStartX,
              startY: newStartY,
              width: _originSize![0],
              height: _originSize![1]));

      if (nLayout != null) {
        var xDif = nLayout.startX - startX;
        var yDif = nLayout.startY - startY;
        _startX = nLayout.startX;
        _startY = nLayout.startY;
        _width = nLayout.width;
        _height = nLayout.height;
        var dif = Offset(xDif * _slotEdge, yDif * _slotEdge);

        _transform.value = newTransform - dif;
        save();
        _onTransformProcess = false;

        return ResizeMoveResult()
          ..isChanged = true
          ..startDifference = dif;
      } else {
        _layoutController._indexItem(
            ItemLayout(
                startX: startX, startY: startY, width: width, height: height),
            id);
      }
    }
    _transform.value = newTransform;
    _onTransformProcess = false;
    return null;
  }

  late String id;

  void _mount(DashboardLayoutController layoutController, String id) {
    _layoutController = layoutController;
    this.id = id;
    indexes = layoutController.getItemIndexes(origin);
    _endIndex = indexes.last;
    _startIndex = indexes.first;
  }

  bool get isLeftSide {
    return startX == 0;
  }

  bool get isRightSide {
    return (_endIndex + 1) % (_layoutController.slotCount) == 0;
  }

  bool get isTopSide {
    return startY == 0;
  }

  bool get isBottomSide {
    var last = (_layoutController._endsTree.lastKey())!;
    var lIn = _layoutController.getIndexCoordinate(last);
    return _layoutController.getIndexCoordinate(_endIndex)[1] == lIn[1];
  }

  late int _endIndex;
  late int _startIndex;

  late List<int> indexes;

  late DashboardLayoutController _layoutController;

  ///
  ItemLayout origin;

  void save() {
    _layoutController._reIndexItem(
        ItemLayout(
            startX: startX,
            startY: startY,
            width: width,
            height: height,
            minWidth: minWidth,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            minHeight: minHeight),
        id);
  }

  int? _height;

  @override
  int get height {
    return _height ?? origin.height;
  }

  @override
  int? get maxHeight {
    return origin.maxHeight;
  }

  @override
  int? get maxWidth {
    return origin.maxWidth;
  }

  @override
  int get minHeight {
    return origin.minHeight;
  }

  @override
  int get minWidth {
    return origin.minWidth;
  }

  int? _startX;

  @override
  int get startX {
    return _startX ?? origin.startX;
  }

  set startX(int v) {
    _startX = v;
  }

  int? _startY;

  @override
  int get startY {
    return _startY ?? origin.startY;
  }

  set startY(int v) {
    _startY = v;
  }

  int? _width;

  @override
  int get width {
    return _width ?? origin.width;
  }

  ItemCurrentLayout copy() {
    return ItemCurrentLayout(origin)
      ..indexes = List.from(indexes)
      .._layoutController = _layoutController
      .._endIndex = _endIndex
      .._startIndex = _startIndex
      .._transform = _transform
      .._resizePosition = _resizePosition
      ..id = id;
  }

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  ///
  @override
  ItemLayout copyWithStarts({int? startX, int? startY, int? endX, int? endY}) {
    throw UnimplementedError();
  }

  @override
  ItemLayout copyWithDimension({int? width, int? height}) {
    throw UnimplementedError();
  }
}
