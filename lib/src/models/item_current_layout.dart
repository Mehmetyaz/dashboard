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

  @override
  String toString() {
    return "ITEM_CURRENT($x, $y , $width , $height)";
  }
}

class Resizing {
  Resizing(this.direction, this.increment);

  AxisDirection direction;
  bool increment;

  @override
  String toString() {
    return "${increment ? "increment" : "decrement"} $direction";
  }
}

class Resize {
  Resize(this.resizing);

  List<Resizing> resizing;

  late Offset adjustedDif;
  late ItemCurrentPosition adjustedPosition;

  void adjustResizeOffset(Offset local, double slotEdge) {
    var pos = ItemCurrentPosition(height: 0, width: 0, y: 0, x: 0);
    var difOffset = Offset(local.dx, local.dy);
    for (var resize in resizing) {
      if (resize.increment) {
        if (resize.direction == AxisDirection.left) {
          pos
            ..x += slotEdge
            ..width -= slotEdge;
          difOffset += Offset(-slotEdge, 0);
        } else if (resize.direction == AxisDirection.right) {
          pos.width -= slotEdge;
          difOffset += Offset(slotEdge, 0);
        } else if (resize.direction == AxisDirection.up) {
          pos
            ..y += slotEdge
            ..height -= slotEdge;
          difOffset += Offset(0, -slotEdge);
        } else {
          pos.height -= slotEdge;
          difOffset += Offset(0, slotEdge);
        }
      }
    }
    adjustedDif = difOffset;
    adjustedPosition = pos;
  }
}

///
class ItemCurrentLayout implements ItemLayout {
  ///
  ItemCurrentLayout(this.origin);

  ValueNotifier<Offset> _transform = ValueNotifier(Offset.zero);
  ValueNotifier<ItemCurrentPosition> _resizePosition =
      ValueNotifier(ItemCurrentPosition(y: 0, x: 0, height: 0, width: 0));

  @override
  String toString() {
    return "current: (startX: $startX , startY: $startY , width: $width , height: $height)"
        "\n origin: ($origin)";
  }

  ItemCurrentPosition currentPosition(
      {required double offset,
      required EdgeInsets padding,
      required double mainAxisSpace,
      required double crossAxisSpace,
      required double slotEdge}) {
    var leftPad = isLeftSide ? 0.0 : crossAxisSpace / 2;
    var rightPad = isRightSide ? 0.0 : crossAxisSpace / 2;
    var topPad = isTopSide ? 0.0 : mainAxisSpace / 2;
    var bottomPad = isBottomSide ? 0.0 : mainAxisSpace / 2;
    return ItemCurrentPosition(
        height: height * slotEdge - topPad - bottomPad,
        width: width * slotEdge - rightPad - leftPad,
        y: ((startY * (slotEdge)) - offset) + padding.top + topPad,
        x: (startX * slotEdge) + padding.left + leftPad);
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

  bool sideIsEmpty(AxisDirection direction) {
    List<int> sideIndexes;

    if (direction == AxisDirection.left) {
      if (startX == 0) {
        return false;
      }
      sideIndexes = _layoutController.getItemIndexes(ItemLayout(
          startX: startX - 1, startY: startY, width: 1, height: height));
    } else if (direction == AxisDirection.right) {
      if (startX == _layoutController.slotCount - 1) {
        return false;
      }
      sideIndexes = _layoutController.getItemIndexes(ItemLayout(
          startX: startX - width, startY: startY, width: 1, height: height));
    } else if (direction == AxisDirection.up) {
      if (startY == 0) {
        return false;
      }
      sideIndexes = _layoutController.getItemIndexes(ItemLayout(
          startX: startX, startY: startY - 1, width: width, height: 1));
    } else {
      sideIndexes = _layoutController.getItemIndexes(ItemLayout(
          startX: startX, startY: startY + height, width: width, height: 1));
    }

    var res = false;
    for (var i in sideIndexes) {
      res = _layoutController._indexesTree
          .contains(_IndexedDashboardItem(null, i));

      if (res) return false;
    }
    return !res;
  }

  Resize? tryResize(List<Resizing> resizes) {
    var res = <Resizing>[];

    for (var resize in resizes) {
      var direction = resize.direction;
      if (resize.increment) {
        if (sideIsEmpty(direction)) {
          if (direction == AxisDirection.left) {
            _startX = startX - 1;
            _width = width + 1;
          } else if (direction == AxisDirection.right) {
            _width = width + 1;
          } else if (direction == AxisDirection.up) {
            _startY = startY - 1;
            _height = height + 1;
          } else {
            _height = height + 1;
          }
          res.add(resize);
        }
      } else {
        //decrement size by direction
        if (direction == AxisDirection.up) {
          if (minHeight < height) {
            _height = height - 1;
            _startY = startY + 1;
            res.add(resize);
          }
        } else if (direction == AxisDirection.down) {
          if (minHeight < height) {
            _height = height - 1;
            res.add(resize);
          }
        } else if (direction == AxisDirection.left) {
          if (minWidth < width) {
            _width = width - 1;
            _startX = startX + 1;
            res.add(resize);
          }
        } else if (direction == AxisDirection.right) {
          if (minWidth < width) {
            _width = width - 1;
            res.add(resize);
          }
        } else {
          throw 0;
        }
      }
    }

    if (res.isEmpty) {
      return null;
    }

    return Resize(res);
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
    var last = (_layoutController._endsTree.max).value;
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
