part of dashboard;

class DashboardItemController<T extends DashboardItem> with ChangeNotifier {
  DashboardItemController({required List<T> items})
      : _items = items.asMap().map(
              (key, value) => MapEntry(value.identifier, value),
            );

  DashboardItemController.withDelegate(
      {Duration? timeout, required this.itemStorageDelegate})
      : _timeout = timeout ?? const Duration(seconds: 10);

  DashboardItemStorageDelegate<T>? itemStorageDelegate;

  bool get isEditing => _layoutController!.isEditing;

  Duration? _timeout;

  void addAll(List<T> items, {bool exactCoordinate = false}) {
    if (isAttached) {
      _items.addAll(
          items.asMap().map((key, value) => MapEntry(value.identifier, value)));
      _layoutController!.addAll(items);
      itemStorageDelegate?.onItemsAdded(
          items.map((e) => getItemWithLayout(e.identifier)).toList());
    } else {
      throw Exception("Not Attached");
    }
    throw 0;
  }

  Future<void> _loadItems(int slotCount) async {
    var ftr = itemStorageDelegate!.getAllItems(slotCount);

    if (ftr is Future<List<T>>) {
      if (_asyncSnap == null) {
        _asyncSnap = ValueNotifier(const AsyncSnapshot.waiting());
      } else {
        _asyncSnap!.value = const AsyncSnapshot.waiting();
      }

      ftr.then((value) {
        _asyncSnap!.value = AsyncSnapshot.withData(ConnectionState.done, value);
        _items = value
            .asMap()
            .map((key, value) => MapEntry(value.identifier, value));
        notifyListeners();
      }).timeout(_timeout!, onTimeout: () {
        _asyncSnap!.value = AsyncSnapshot.withError(
            ConnectionState.none, TimeoutException(null), StackTrace.current);
        notifyListeners();
      }).onError((error, stackTrace) {
        _asyncSnap!.value = AsyncSnapshot.withError(
            ConnectionState.none, error ?? Exception(), stackTrace);
        notifyListeners();
      });
    } else {
      _items =
          ftr.asMap().map((key, value) => MapEntry(value.identifier, value));
      if (_asyncSnap == null) {
        _asyncSnap =
            ValueNotifier(AsyncSnapshot.withData(ConnectionState.done, ftr));
      } else {
        _asyncSnap!.value = AsyncSnapshot.withData(ConnectionState.done, ftr);
      }
      notifyListeners();
    }
  }

  ValueNotifier<AsyncSnapshot>? _asyncSnap;

  T getItemWithLayout(String id) {
    if (!isAttached) throw Exception("Not Attached");
    return _items[id]!;
  }

  void delete(String id) {
    if (isAttached) {
      _layoutController!.delete(id);
      itemStorageDelegate?.onItemsDeleted([getItemWithLayout(id)]);
      _items.remove(id);
    } else {
      throw Exception("Not Attached");
    }
  }

  void deleteAll(List<String> ids) {
    if (isAttached) {
      _layoutController!.deleteAll(ids);
      itemStorageDelegate
          ?.onItemsDeleted(ids.map((e) => getItemWithLayout(e)).toList());
      _items.removeWhere((k, v) => ids.contains(k));
    } else {
      throw Exception("Not Attached");
    }
  }

  void add(T item, {bool exactCoordinate = false}) {
    if (isAttached) {
      _items[item.identifier] = item;
      _layoutController!.add(item);
      itemStorageDelegate?.onItemsAdded([item]);
    } else {
      throw Exception("Not Attached");
    }
  }

  ///
  late Map<String, T> _items;

  List<String> get items =>
      List.unmodifiable(_items.values.map((e) => e.identifier));

  bool get isAttached => _layoutController != null;

  DashboardLayoutController? _layoutController;

  void attach(DashboardLayoutController layoutController) {
    _layoutController = layoutController;
  }

  void setEditMode(bool value) {
    _layoutController!.isEditing = value;
  }

  bool trySlideToTop(String id) {
    return _layoutController!.mountToTop(id);
  }

  void slideToTopAll() {
    return _layoutController!._slideToTopAll();
  }

  void clear() {
    return deleteAll(items);
  }
}

///
class DashboardLayoutController<T extends DashboardItem> with ChangeNotifier {
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

  late bool absorbPointer;

  // BoxConstraints? _constrains;
  // BoxConstraints get constrains => _constrains!;

  ///
  late double slotEdge, verticalSlotEdge;

  ///
  Map<String, ItemCurrentLayout>? _layouts;

  final SplayTreeMap<int, String> _startsTree = SplayTreeMap<int, String>();
  final SplayTreeMap<int, String> _endsTree = SplayTreeMap<int, String>();

  final SplayTreeMap<int, String> _indexesTree = SplayTreeMap<int, String>();

  EditSession? editSession;

  void startEdit(String id, bool transform) {
    editSession = EditSession(
        layoutController: this, editing: _layouts![id]!, transform: transform);
  }

  void saveEditSession() {
    if (editSession == null) return;

    if (editSession!._changes.isNotEmpty) {
      itemController.itemStorageDelegate?.onItemsUpdated(editSession!._changes
          .map((e) => itemController.getItemWithLayout(e))
          .toList());
    }

    if (editSession!.isEqual) {
      cancelEditSession();
      editSession = null;
      notifyListeners();
    } else {
      //Notify storage
      editSession = null;
      notifyListeners();
    }
  }

  void cancelEditSession() {
    if (editSession == null) return;
    _layouts!.forEach((key, value) {
      value._mount(this, key);
    });
    editSession = null;
  }

  ///
  late Axis _axis;

  void deleteAll(List<String> ids) {
    for (var id in ids) {
      var l = _layouts![id];
      var indexes = getItemIndexes(l!.origin);
      _startsTree.remove(indexes.first);
      _endsTree.remove(indexes.last);

      for (var i in indexes) {
        _indexesTree.remove(i);
      }

      _layouts!.remove(id);
    }
    notifyListeners();
  }

  void delete(String id) {
    var l = _layouts![id];
    var indexes = getItemIndexes(l!.origin);
    _startsTree.remove(indexes.first);
    _endsTree.remove(indexes.last);

    for (var i in indexes) {
      _indexesTree.remove(i);
    }

    _layouts!.remove(id);
    notifyListeners();
  }

  void add(DashboardItem item) {
    _layouts![item.identifier] = ItemCurrentLayout(item.layoutData);
    mountToTop(item.identifier);
    notifyListeners();
  }

  void addAll(List<DashboardItem> items) {
    for (var item in items) {
      _layouts![item.identifier] = ItemCurrentLayout(item.layoutData);
      mountToTop(item.identifier);
    }
    notifyListeners();
  }

  ///
  List<int> getIndexCoordinate(int index) {
    return [index % slotCount, index ~/ slotCount];
  }

  List<int?> getOverflowsAlt(ItemLayout itemLayout) {
    var possibilities = <OverflowPossibility>[];

    var y = itemLayout.startY;
    var eY = itemLayout.startY + itemLayout.height;
    var eX = min(itemLayout.startX + itemLayout.width, slotCount + 1);

    var minX = eX;

    yLoop:
    while (y < eY) {
      var x = itemLayout.startX;
      xLoop:
      while (x < eX) {
        if (x > minX) {
          possibilities.add(OverflowPossibility(
              x, y + 1, x - itemLayout.startX, y - itemLayout.startY + 1));
          break xLoop;
        }
        if (_indexesTree.containsKey(getIndex([x, y]))) {
          minX = x - 1;
          // filled
          if (x == itemLayout.startX) {
            if (y == itemLayout.startY) {
              return [x, y];
            } else {
              if (possibilities.isEmpty) {
                return [null, y];
              }

              possibilities.removeWhere((element) {
                return (element.w < itemLayout.minWidth ||
                    element.h < itemLayout.minHeight);
              });

              if (possibilities.isEmpty) {
                return [itemLayout.startX, itemLayout.startY];
              }

              possibilities.sort((a, b) => b.compareTo(a));

              var p = possibilities.first;

              return [p.x, p.y];
            }
          }

          if (possibilities.isEmpty) {
            possibilities.add(OverflowPossibility(
                itemLayout.startX + itemLayout.width,
                y,
                itemLayout.width,
                y - itemLayout.startY));
          }

          possibilities.add(OverflowPossibility(
              x, y + 1, x - itemLayout.startX, y - itemLayout.startY + 1));

          y++;
          continue yLoop;
        }
        x++;
      }
      // possibilities.add(OverflowPossibility(
      //     x + 1, y + 1, x - itemLayout.startX, y - itemLayout.startY));
      y++;
    }

    if (possibilities.isEmpty) {
      return [null, null];
    }

    possibilities.removeWhere((element) {
      return (element.w < itemLayout.minWidth ||
          element.h < itemLayout.minHeight);
    });

    if (possibilities.isEmpty) {
      return [itemLayout.startX, itemLayout.startY];
    }

    possibilities.sort((a, b) {
      return b.compareTo(a);
    });

    var p = possibilities.first;

    return [p.x, p.y];
  }

  ///
  // List<int?> getOverflows(ItemLayout itemLayout) {
  //   var possibilities = <OverflowPossibility>[];
  //
  //   var y = itemLayout.startY;
  //   var eX = itemLayout.startX + itemLayout.width;
  //   var eY = itemLayout.startY + itemLayout.height;
  //
  //   int minX = max(itemLayout.startX + itemLayout.width, slotCount + 1);
  //
  //   while (y < eY) {
  //     var x = itemLayout.startX;
  //     xLoop:
  //     while (x < eX) {
  //       if (x > minX) {
  //         break xLoop;
  //       }
  //       if (x >= slotCount || _indexesTree.containsKey(getIndex([x, y]))) {
  //         if (x == itemLayout.startX) {
  //           if (y == itemLayout.startY) {
  //
  //             return [itemLayout.startX, itemLayout.startY];
  //           }
  //
  //           possibilities.sort((a, b) => b.compareTo(a));
  //
  //           if (possibilities.isEmpty) {
  //             return [null, y];
  //           }
  //           var p = possibilities.first;
  //
  //           return [p.x, p.y];
  //         }
  //
  //         if (x < minX) {
  //           minX = x;
  //         }
  //
  //         var nw = x - itemLayout.startX;
  //         var nh = y - itemLayout.startY;
  //         if (itemLayout.maxWidth != null && nw > itemLayout.maxWidth!) {
  //           possibilities.add(OverflowPossibility(
  //               x, y, x - itemLayout.startX, y - itemLayout.startY));
  //           break xLoop;
  //         }
  //
  //         if (itemLayout.maxHeight != null && nh > itemLayout.maxHeight!) {
  //           possibilities.add(OverflowPossibility(
  //               x, y, x - itemLayout.startX, y - itemLayout.startY));
  //           break xLoop;
  //         }
  //
  //         if ((nw >= itemLayout.minWidth && nh >= itemLayout.minHeight)) {
  //           possibilities.add(OverflowPossibility(
  //               x, y, x - itemLayout.startX, y - itemLayout.startY));
  //           break xLoop;
  //         }
  //       }
  //       x++;
  //     }
  //     y++;
  //   }
  //   possibilities.sort((a, b) => b.compareTo(a));
  //
  //   if (possibilities.isEmpty) {
  //     return [null, null];
  //   }
  //
  //   var p = possibilities.first;
  //
  //
  //   return [p.x, p.y];
  //
  //   /*return [blockX, blockY];*/
  // }

  void _removeFromIndexes(ItemLayout itemLayout, String id) {
    var i = getItemIndexes(itemLayout);
    if (i.isEmpty) return;
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
  }

  void _reIndexItem(ItemLayout itemLayout, String id) {
    var l = _layouts![id]!;
    _removeFromIndexes(l.origin, id);
    l._height = null;
    l._width = null;
    l._startX = null;
    l._startY = null;
    _indexItem(itemLayout, id);
  }

  void _indexItem(ItemLayout itemLayout, String id) {
    var i = getItemIndexes(itemLayout);
    _startsTree[i.first] = id;
    _endsTree[i.last] = id;
    for (var index in i) {
      _indexesTree[index] = id;
    }

    _layouts![id]!.origin = itemLayout;
    _layouts![id]!._mount(this, id);
  }

  ///
  ItemLayout? tryMount(int value, ItemLayout itemLayout) {
    var r = getIndexCoordinate(value);
    var n = itemLayout.copyWithStarts(startX: r[0], startY: r[1]);
    var i = 0;
    while (true) {
      if (i > 1000000) {
        throw Exception("loop");
      }
      i++;
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
        var overflows = getOverflowsAlt(n);
        if (overflows.where((element) => element != null).isEmpty) {
          // both null
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
  bool mountToTop(String id) {
    try {
      var itemCurrent = _layouts![id]!;

      _removeFromIndexes(itemCurrent, id);

      var i = 0;
      while (true) {
        var nLayout = tryMount(i, itemCurrent.origin);
        if (nLayout != null) {
          _indexItem(nLayout, id);
          return true;
        }

        if (i > 1000000) {
          throw Exception("Stack overflow");
        }
        i++;
      }
    } on Exception {
      rethrow;
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
    try {
      if (!_isAttached) throw Exception("Not Attached");

      _startsTree.clear();
      _endsTree.clear();
      _indexesTree.clear();

      var not = <String>[];

      layouts:
      for (var i in _layouts!.entries) {
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
            getIndex([i.value.startX, i.value.startY]), i.value.origin);

        if (mount == null) {
          not.add(i.key);
          continue layouts;
        }

        _indexItem(mount, i.key);
      }
      List<String> changes = [];

      if (slideToTop) {
        _slideToTopAll();
        changes.addAll(_startsTree.values);
      }

      for (var n in not) {
        mountToTop(n);
      }

      changes.addAll(not);

      if (changes.isNotEmpty) {
        itemController.itemStorageDelegate?.onItemsUpdated(
            changes.map((e) => itemController.getItemWithLayout(e)).toList());
      }
    } on Exception {
      rethrow;
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
        maxHeight: layout.height * verticalSlotEdge,
        maxWidth: layout.width * slotEdge);
  }

  ///
  List<int> getItemIndexes(ItemLayout data) {
    if (!_isAttached) throw Exception("Not Attached");
    var l = <int>[];

    var y = data.startY;
    var eY = data.startY + data.height;
    var eX = data.startX + data.width;

    if (data.startY < 0 || data.startX >= slotCount || eX > slotCount) {
      return [];
    }

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

  void _setSizes(BoxConstraints _constrains, double vertical) {
    verticalSlotEdge = vertical;
    slotEdge = (_axis == Axis.vertical
            ? _constrains.maxWidth
            : _constrains.maxHeight) /
        slotCount;
  }

  late bool animateEverytime;

  ///
  void attach({
    required Axis axis,
    required DashboardItemController<T> itemController,
    required int slotCount,
    required bool slideToTop,
    required bool shrinkToPlace,
    required bool animateEverytime,
  }) {
    this.itemController = itemController;
    this.slideToTop = slideToTop;
    this.shrinkToPlace = shrinkToPlace;
    this.slotCount = slotCount;
    this.animateEverytime = animateEverytime;
    _axis = axis;
    _isAttached = true;
    _layouts ??= itemController._items.map((key, value) =>
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
    return editing.startX == editingOrigin.startX &&
        editing.startY == editingOrigin.startY &&
        editing.width == editingOrigin.width &&
        editing.height == editingOrigin.height;
  }

  List<String> get _changes {
    var changes = <String>[];
    if (!isEqual) {
      for (var dir in _indirectChanges.entries) {
        var dirChanges = _indirectChanges[dir.key];
        if (dirChanges != null) {
          for (var ch in dirChanges.entries) {
            if (ch.value.isNotEmpty) {
              changes.add(ch.key);
            }
          }
        }
      }
      changes.add(editing.id);
    }

    return changes;
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
