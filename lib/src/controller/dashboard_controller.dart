part of dashboard;

class DashboardItemController<T> {
  DashboardItemController(
      {required List<DashboardItem<T>> items,
      this.onNewLayout,
      this.allowEdit = true})
      : _items = items
            .asMap()
            .map((key, value) => MapEntry(value.identifier, value));

  ///
  final bool allowEdit;

  bool get isEditing => _layoutController!.isEditing;

  void addAll(List<DashboardItem<T>> items, {bool exactCoordinate = false}) {
    throw 0;
  }

  void add(DashboardItem<T> item, {bool exactCoordinate = false}) {
    if (isAttached) {
      _items[item.identifier] = item;
      _layoutController!.add(item);
    } else {
      throw Exception("Not Attached");
    }
  }

  void remove(String id, {bool slideToFill = true}) {
    throw 0;
  }

  void removeWhere(bool Function(DashboardItem) test) {
    throw 0;
  }

  ///
  final Map<String, DashboardItem<T>> _items;

  bool get isAttached => _layoutController != null;

  DashboardLayoutController<T>? _layoutController;

  void attach(DashboardLayoutController<T> layoutController) {
    _layoutController = layoutController;
  }

  void setEditMode(bool value) {
    _layoutController!.isEditing = value;
  }

  ///
  final void Function(DashboardItem<T> item)? onNewLayout;
}

///
class DashboardLayoutController<T> with ChangeNotifier {
  ///
  DashboardLayoutController();

  ///
  late DashboardItemController<T> itemController;

  ///
  late ViewportDelegate _viewportDelegate;

  ///
  late int slotCount;

  ///
  late bool shrinkToPlace;

  ///
  late bool swapOnEditing;

  ///
  late bool slideToTop;

  bool _isEditing = false;

  bool get isEditing {
    return _isEditing;
  }

  set isEditing(bool value) {
    if (value != _isEditing) {
      _isEditing = value;
      notifyListeners();
    }
  }

  // BoxConstraints? _constrains;
  // BoxConstraints get constrains => _constrains!;

  ///
  late double slotEdge;

  ///
  late Map<String, ItemCurrentLayout> _layouts;

  final SplayTreeMap<int, String> _startsTree = SplayTreeMap<int, String>();
  final SplayTreeMap<int, String> _endsTree = SplayTreeMap<int, String>();

  final SplayTreeMap<int, String> _indexesTree = SplayTreeMap<int, String>();

  EditSession? editSession;

  void startEdit(String id, bool transform) {
    editSession = EditSession(
        layoutController: this, editing: _layouts[id]!, transform: transform);
  }

  void saveEditSession() {
    if (editSession == null) return;
    if (editSession!.isEqual) {
      cancelEditSession();
      editSession = null;
      notifyListeners();
    } else {
      //Notify storage
      editSession = null;
      // _layouts.forEach((key, value) {
      //   value._mount(this, key);
      // });
      notifyListeners();
    }
  }

  void cancelEditSession() {
    if (editSession == null) return;

    _layouts.forEach((key, value) {
      value._mount(this, key);
    });
    editSession = null;
    notifyListeners();
  }

  ///
  late Axis _axis;

  void add(DashboardItem item) {
    _layouts[item.identifier] = ItemCurrentLayout(item.layoutData);
    mountToTop(item.identifier);
    notifyListeners();
  }

  ///
  List<int> getIndexCoordinate(int index) {
    return [index % slotCount, index ~/ slotCount];
  }

  ///
  List<int?> getOverflows(ItemLayout itemLayout) {
    var possibilities = <OverflowPossibility>[];

    var y = itemLayout.startY;
    var eX = itemLayout.startX + itemLayout.width;
    var eY = itemLayout.startY + itemLayout.height;

    int? blockX, blockY;

    int? minX, minY;

    while (y < eY) {
      var x = itemLayout.startX;
      xLoop:
      while (x < eX) {
        if (x >= slotCount || _indexesTree.containsKey(getIndex([x, y]))) {
          if (y == itemLayout.startY) {
            return [itemLayout.startX, itemLayout.startY];
          }

          if (x == itemLayout.startX) {
            possibilities.sort((a, b) => b.compareTo(a));

            if (possibilities.isEmpty) {
              print("burası");
              return [null, y];
            }
            print("burası 2");
            var p = possibilities.first;

            return [p.x, p.y];
          }

          var nw = x - itemLayout.startX;
          var nh = y - itemLayout.startY;
          if (itemLayout.maxWidth != null && nw > itemLayout.maxWidth!) {
            possibilities.add(OverflowPossibility(
                x, y, x - itemLayout.startX, y - itemLayout.startY));
            break xLoop;
          }

          if (itemLayout.maxHeight != null && nh > itemLayout.maxHeight!) {
            possibilities.add(OverflowPossibility(
                x, y, x - itemLayout.startX, y - itemLayout.startY));
            break xLoop;
          }

          if ((nw >= itemLayout.minWidth && nh >= itemLayout.minHeight)) {
            possibilities.add(OverflowPossibility(
                x, y, x - itemLayout.startX, y - itemLayout.startY));
            break xLoop;
          }
        }
        x++;
      }
      y++;
    }
    print("burası 3");
    possibilities.sort((a, b) => b.compareTo(a));

    if (possibilities.isEmpty) {
      return [null, null];
    }

    var p = possibilities.first;

    return [p.x, p.y];

    return [minX, minY];
    /*return [blockX, blockY];*/
  }

  void _removeFromIndexes(ItemLayout itemLayout, String id) {
    assert(!_locked);
    _locked = true;
    var i = getItemIndexes(itemLayout);

    var ss = _startsTree.containsKey(i.first);
    if (ss && _startsTree[i.first] == id) {
      _startsTree.remove((i.first));
    }

    var es = _endsTree.containsKey(i.last);
    if (es && _endsTree[i.last] == id) {
      _endsTree.remove((i.last));
    }
    for (var index in i) {
      var s = _indexesTree[index];
      if (s != null && s == id) {
        _indexesTree.remove(index);
      }
    }
    _locked = false;
  }

  void _reIndexItem(ItemLayout itemLayout, String id) {
    var l = _layouts[id]!;
    _removeFromIndexes(l.origin, id);
    l._height = null;
    l._width = null;
    l._startX = null;
    l._startY = null;
    _indexItem(itemLayout, id);
  }

  bool _locked = false;

  void _indexItem(ItemLayout itemLayout, String id) {
    assert(!_locked);
    _locked = true;
    var i = getItemIndexes(itemLayout);
    _startsTree[i.first] = id;
    _endsTree[i.last] = id;
    for (var index in i) {
      _indexesTree[index] = id;
    }

    _layouts[id]!.origin = itemLayout;
    _layouts[id]!._mount(this, id);
    _locked = false;
  }

  ///
  ItemLayout? tryMount(int value, ItemLayout itemLayout) {
    var r = getIndexCoordinate(value);
    var n = itemLayout.copyWithStarts(startX: r[0], startY: r[1]);
    while (true) {
      if (shrinkToPlace && n.startX + n.width > slotCount) {
        // Not fit to viewport
        if (n.minWidth < n.width) {
          n = n.copyWithDimension(width: n.width - 1);
          continue;
        } else {
          return null;
        }
      } else {
        // Fit viewport
        var overflows = getOverflows(n);
        // if (kDebugMode) {
        //   print(overflows);
        // }
        if (overflows.where((element) => element != null).isEmpty) {
          return n;
        } else {
          if (shrinkToPlace) {
            var eX = overflows[0] ?? (n.startX + n.width);
            var eY = overflows[1] ?? (n.startY + n.height);

            if (eX - n.startX >= n.minWidth && eY - n.startY >= n.minHeight) {
              return n.copyWithDimension(
                  width: eX - n.startX, height: eY - n.startY);
            } else {
              return null;
            }
          } else {
            return null;
          }
        }
      }
    }
  }

  ///
  void mountToTop(String id) {
    var itemCurrent = _layouts[id]!;
    _removeFromIndexes(itemCurrent, id);
    var i = 0;
    while (true) {
      var nLayout = tryMount(i, itemCurrent.origin);
      if (nLayout != null) {
        _indexItem(nLayout, id);
        break;
      }
      i++;
    }
  }

  ///
  void _slideToTopAll() {
    var l = _startsTree.values.toList();

    _startsTree.clear();
    _endsTree.clear();
    _indexesTree.clear();
    for (var e in l) {
      mountToTop(e);
    }
  }

  ///
  void mountItems() {
    if (!_isAttached) throw Exception("Not Attached");

    _startsTree.clear();
    _endsTree.clear();
    _indexesTree.clear();

    var not = <String>[];

    layouts:
    for (var i in _layouts.entries) {
      if (_axis == Axis.vertical && i.value.width > slotCount) {
        // Check fit, if necessary and possible, edit
        if (i.value.minWidth > slotCount) {
          throw Exception("Minimum width > slotCount");
        } else {
          if (!shrinkToPlace) {
            throw Exception("width not fit");
          }
        }
      }

      // can mount given start index
      var mount =
          tryMount(getIndex([i.value.startX, i.value.startY]), i.value.origin);

      if (mount == null) {
        not.add(i.key);
        continue layouts;
      }

      _indexItem(mount, i.key);
    }

    if (slideToTop) {
      _slideToTopAll();
    }
    for (var n in not) {
      mountToTop(n);
    }
  }

  ///
  int getIndex(List<int> point) {
    var x = point[0];
    var y = point[1];
    return (y * slotCount) + x;
  }

  ///
  BoxConstraints getConstrains(ItemLayout layout) {
    return BoxConstraints(
        maxHeight: layout.height * slotEdge, maxWidth: layout.width * slotEdge);
  }

  ///
  List<int> getItemIndexes(ItemLayout data) {
    if (!_isAttached) throw Exception("Not Attached");
    var l = <int>[];

    var y = data.startY;
    var eY = data.startY + data.height;
    var eX = data.startX + data.width;

    while (y < eY) {
      var x = data.startX;
      xLoop:
      while (x < eX) {
        if (x >= slotCount) {
          continue xLoop;
        }
        l.add(getIndex([x, y]));
        x++;
      }
      y++;
    }

    return l;
  }

  void _setSizes(BoxConstraints _constrains) {
    slotEdge = (_axis == Axis.vertical
            ? _constrains.maxWidth
            : _constrains.maxHeight) /
        slotCount;
  }

  ///
  void attach(
      {required Axis axis,
      required DashboardItemController<T> itemController,
      required int slotCount,
      required bool slideToTop,
      required bool shrinkToPlace}) {
    this.itemController = itemController;
    this.slideToTop = slideToTop;
    this.shrinkToPlace = shrinkToPlace;
    this.slotCount = slotCount;
    itemController.attach(this);
    _axis = axis;
    _isAttached = true;
    _layouts = itemController._items.map((key, value) =>
        MapEntry(value.identifier, ItemCurrentLayout(value.layoutData)));
    mountItems();
  }

  ///
  bool _isAttached = false;
}

class OverflowPossibility extends Comparable<OverflowPossibility> {
  OverflowPossibility(this.x, this.y, this.w, this.h) : sq = w * h;

  int x, y, w, h, sq;

  @override
  int compareTo(OverflowPossibility other) {
    return sq.compareTo(other.sq);
  }

  @override
  String toString() {
    return super.toString();
  }
}

///
class EditSession {
  ///
  EditSession(
      {required DashboardLayoutController layoutController,
      required this.editing,
      required this.transform})
      : editingOrigin = editing.copy();

  bool transform;

  ///
  bool get isEqual {
    editing.startX == editingOrigin.startX &&
        editing.startY == editingOrigin.startY &&
        editing.width == editingOrigin.width &&
        editing.height == editingOrigin.height;

    return editing.startX == editingOrigin.startX;
  }

  // final Map<AxisDirection, List<Resizing>> _resizes = {};

  final Map<AxisDirection, Map<String, List<_Change>>> _indirectChanges = {};

  void _addResize(
      Resize resize, void Function(String id, _Change) onBackChange) {
    // _resizes[resize.resize.direction] ??= [];
    // _resizes[resize.resize.direction]!.add(resize.resize);
    if (resize.resize.increment && resize.indirectResizes != null) {
      for (var _indirect in resize.indirectResizes!.entries) {
        _indirectChanges[_indirect.value.direction] ??= {};
        _indirectChanges[_indirect.value.direction]![_indirect.key] ??= [];
        _indirectChanges[_indirect.value.direction]![_indirect.key]!
            .add(_indirect.value);
      }
    }

    if (!resize.resize.increment) {
      var dir = resize.resize.direction;
      AxisDirection reverseDir;
      if (dir == AxisDirection.left) {
        reverseDir = AxisDirection.right;
      } else if (dir == AxisDirection.right) {
        reverseDir = AxisDirection.left;
      } else if (dir == AxisDirection.up) {
        reverseDir = AxisDirection.down;
      } else {
        reverseDir = AxisDirection.up;
      }

      var reverseIndirectResizes = _indirectChanges[reverseDir];

      if (reverseIndirectResizes == null) {
        return;
      } else {
        for (var _resize in reverseIndirectResizes.entries) {
          if (_resize.value.isNotEmpty) {
            onBackChange(
                _resize.key, _resize.value.removeAt(_resize.value.length - 1));
          }
        }
      }
    }
  }

  ///
  final ItemCurrentLayout editing;

  ///
  final ItemCurrentLayout editingOrigin;
}

///
// class _IndexedDashboardItem extends Comparable {
//   ///
//   _IndexedDashboardItem(this.id, this.value);
//
//   ///
//   final int value;
//
//   ///
//   final String? id;
//
//   @override
//   bool operator ==(Object other) {
//     if (other is! _IndexedDashboardItem) {
//       throw Exception();
//     }
//     return other.value == value;
//   }
//
//   ///
//   @override
//   int compareTo(Object? other) {
//     return other is _IndexedDashboardItem
//         ? value.compareTo(other.value)
//         : value.compareTo(other as int);
//   }
//
//   @override
//   String toString() {
//     return "_IndexedDashboardItem(\"$id\", $value)";
//   }
//
//   // @override
//   // String toString() {
//   //   return "INDEX($value) : ID($id)";
//   // }
//
//   ///
//   @override
//   int get hashCode => value.hashCode;
// }
