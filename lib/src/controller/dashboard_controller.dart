part of dashboard;

class DashboardItemController<T> {
  DashboardItemController(
      {required List<DashboardItem<T>> items,
      this.onNewLayout,
      this.editMode = const EditMode(),
      this.allowEdit = true})
      : _items = items
            .asMap()
            .map((key, value) => MapEntry(value.identifier, value));

  ///
  final bool allowEdit;

  ///
  final EditMode editMode;

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

  BoxConstraints? _constrains;

  ///
  late double slotEdge;

  ///
  late double size;

  ///
  late Map<String, ItemCurrentLayout> _layouts;

  ///
  final BinaryTree<_IndexedDashboardItem> _startsTree =
      BinaryTree<_IndexedDashboardItem>();

  ///
  final BinaryTree<_IndexedDashboardItem> _endsTree =
      BinaryTree<_IndexedDashboardItem>();

  ///
  final BinaryTree<_IndexedDashboardItem> _indexesTree =
      BinaryTree<_IndexedDashboardItem>();

  EditSession? editSession;

  void startEdit(String id) {
    editSession = EditSession(layoutController: this, editing: _layouts[id]!);
  }

  void saveEditSession() {
    if (editSession?.equal() ?? false) {
      // cancelEditSession();
      editSession = null;
    } else {
      //Notify storage
      editSession = null;
      _layouts.forEach((key, value) {
        value._mount(this, key);
      });
      notifyListeners();
    }
  }

  // void cancelEditSession() {
  //   print("CANCEL SESSION");
  //   if (editSession == null) return;
  //   _startsTree = BinaryTree<_IndexedDashboardItem>(
  //       editSession!._exStarts as BinaryTree<_IndexedDashboardItem>);
  //   _endsTree = BinaryTree<_IndexedDashboardItem>(
  //       editSession!._exEndsTree as BinaryTree<_IndexedDashboardItem>);
  //   _indexesTree = BinaryTree<_IndexedDashboardItem>(
  //       editSession!._exIndexesTree as BinaryTree<_IndexedDashboardItem>);
  //   _layouts = Map<String, ItemCurrentLayout>.from(editSession!._exLayouts
  //       .map((key, value) => MapEntry(key, value.copy())));
  //   _layouts.forEach((key, value) {
  //     value._mount(this, key);
  //   });
  //   editSession = null;
  //   notifyListeners();
  // }

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
  List<int> getOverflows(ItemLayout itemLayout) {
    var l = <List<int>>[];

    var y = itemLayout.startY;
    var eX = itemLayout.startX + itemLayout.width;
    var eY = itemLayout.startY + itemLayout.height;

    while (y < eY) {
      var x = itemLayout.startX;

      xLoop:
      while (x < eX) {
        if (x >= slotCount ||
            _indexesTree
                .contains(_IndexedDashboardItem(null, getIndex([x, y])))) {
          l.add([x, y]);
          break xLoop;
        }
        x++;
      }
      y++;
    }
    if (l.isEmpty) return [];
    l.sort((a, b) => a[0].compareTo(b[0]));
    return [l.length > 1 ? l[1][0] : l[0][0], l[0][1]];
  }

  void _removeFromIndexes(ItemLayout itemLayout, String id) {
    var i = getItemIndexes(itemLayout);

    var ss = _startsTree.search(_IndexedDashboardItem(null, i.first));
    if (ss != null && ss.id == id) {
      _startsTree.remove(_IndexedDashboardItem(id, i.first));
    }

    var es = _endsTree.search(_IndexedDashboardItem(null, i.last));
    if (es != null && es.id == id) {
      _endsTree.remove(_IndexedDashboardItem(id, i.last));
    }
    for (var index in i) {
      var s = _indexesTree.search(_IndexedDashboardItem(null, index));
      if (s != null && s.id == id) {
        print("rem:$index");
        _indexesTree.remove(_IndexedDashboardItem(id, index));
      }
    }
  }

  void _reIndexItem(ItemLayout itemLayout, String id) {
    print("REINDEXING: $id");
    var l = _layouts[id]!;
    _removeFromIndexes(l.origin, id);

    l._height = null;
    l._width = null;
    l._startX = null;
    l._startY = null;

    _indexItem(itemLayout, id);
  }

  void _indexItem(ItemLayout itemLayout, String id) {
    var i = getItemIndexes(itemLayout);
    _startsTree.insert(_IndexedDashboardItem(id, i.first));
    _endsTree.insert(_IndexedDashboardItem(id, i.last));
    for (var index in i) {
      _indexesTree.insert(_IndexedDashboardItem(id, index));
    }

    _layouts[id]!.origin = itemLayout;
    _layouts[id]!._mount(this, id);
  }

  ///
  ItemLayout? tryMount(int value, ItemLayout itemLayout, String id) {
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
        if (overflows.isEmpty) {
          return n;
        } else {
          if (shrinkToPlace) {
            var eX = overflows[0];
            var eY = overflows[1];
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
      var nLayout = tryMount(i, itemCurrent.origin, id);
      if (nLayout != null) {
        _indexItem(nLayout, id);
        break;
      }
      i++;
    }
  }

  ///
  void _slideToTopAll() {
    var l = _startsTree.toList();
    _startsTree.clear();
    _endsTree.clear();
    _indexesTree.clear();
    print("HERE:2");
    for (var e in l) {
      mountToTop(e.id!);
    }
  }

  ///
  void mountItems() {
    if (!_isAttached) throw Exception("Not Attached");

    _startsTree.clear();
    _endsTree.clear();
    print("HERE:1");
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
      var mount = tryMount(
          getIndex([i.value.startX, i.value.startY]), i.value.origin, i.key);

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

  void _setSizes() {
    size =
        _axis == Axis.vertical ? _constrains!.maxWidth : _constrains!.maxHeight;
    slotEdge = size / slotCount;
  }

  void _attachConstrains(BoxConstraints constrains) {
    if (_constrains == null) {
      _constrains = constrains;
    } else {
      if (constrains.maxWidth != _constrains!.maxWidth ||
          constrains.maxHeight != _constrains!.maxHeight) {
        _constrains = constrains;
      }
    }
    _setSizes();
  }

  ///
  void attach(
      {required BoxConstraints constrains,
      required Axis axis,
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

// void _notify() {
//   notifyListeners();
// }
}

class EditSession {
  EditSession(
      {required DashboardLayoutController layoutController,
      required this.editing})
      : editingOrigin = editing.copy()
  /*_exLayouts = Map<String, ItemCurrentLayout>.from(layoutController
            ._layouts
            .map((key, value) => MapEntry(key, value.copy()))),
        _exIndexesTree = BinaryTree<_IndexedDashboardItem>(
            layoutController._indexesTree),
        _exEndsTree = BinaryTree<_IndexedDashboardItem>(
            layoutController._endsTree),
        _exStarts = BinaryTree<_IndexedDashboardItem>(
            layoutController._startsTree)*/
  ;

  bool equal() {
    editing.startX == editingOrigin.startX &&
        editing.startY == editingOrigin.startY &&
        editing.width == editingOrigin.width &&
        editing.height == editingOrigin.height;

    return editing.startX == editingOrigin.startX;
  }

  final ItemCurrentLayout editing;

  final ItemCurrentLayout editingOrigin;

// final Map<String, ItemCurrentLayout> _exLayouts;
//
// ///
// final BinaryTree<Comparable> _exStarts;
//
// ///
// final BinaryTree<Comparable> _exEndsTree;
//
// ///
// final BinaryTree<Comparable> _exIndexesTree;
}

class _IndexedDashboardItem extends Comparable {
  _IndexedDashboardItem(this.id, this.value);

  final int value;
  final String? id;

  @override
  bool operator ==(Object other) {
    if (other is! _IndexedDashboardItem) {
      throw Exception();
    }
    return other.value == value;
  }

  @override
  int compareTo(Object? other) {
    return other is _IndexedDashboardItem
        ? value.compareTo(other.value)
        : value.compareTo(other as int);
  }

  @override
  String toString() {
    return "I($value) : ID($id)";
  }

  @override
  int get hashCode => value.hashCode;
}
