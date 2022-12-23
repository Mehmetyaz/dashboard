part of dashboard;

/// A controller for dashboard items.
///
/// Every [Dashboard] needs a [DashboardItemController].
/// The controller determines which items will be displayed on the screen.
/// Item addition, removal, etc. operations are done through the controller.
///
/// The controller is also used to enable/disable editing with [isEditing].
/// Use as setter to specify edit mode.
///
/// [itemStorageDelegate] is used to handle changes and save the layout.
/// You can save layout information on remote server or disk.
///
/// New items can be added with [add] or plural [addAll].
///
/// Items can be deleted with [delete] or plural [deleteAll].
/// For deleting all items can be used [clear].
///
class DashboardItemController<T extends DashboardItem> with ChangeNotifier {
  /// You can define items with constructor.
  /// But the layout information is only for the session.
  /// Changes cannot be handled.
  DashboardItemController({
    required List<T> items,
  })  : _items = items.asMap().map(
              (key, value) => MapEntry(value.identifier, value),
            ),
        itemStorageDelegate = null;

  /// You can create [DashboardItemController] with an [itemStorageDelegate].
  /// In init state, item information is brought with the delegate.
  /// The necessary functions of the delegate are triggered on all changes.
  ///
  /// If the delegate is waiting for a Future to load the items, this will throw
  /// error at the end of the [timout].
  DashboardItemController.withDelegate(
      {Duration? timeout, required this.itemStorageDelegate})
      : _timeout = timeout ?? const Duration(seconds: 10);

  /// To define [itemStorageDelegate] use [DashboardItemController.withDelegate]
  ///
  /// For more see [DashboardItemStorageDelegate] documentation.
  final DashboardItemStorageDelegate<T>? itemStorageDelegate;

  /// Users can only edit the layout when [isEditing] is true.
  /// The [isEditing] does not have to be true to add or delete items.
  ///
  /// Use as setter to change [isEditing] value.
  bool get isEditing => _layoutController!.isEditing;

  /// Change editing status.
  set isEditing(bool value) {
    _layoutController!.isEditing = value;
  }

  /// Add new item to Dashboard.
  ///
  /// If [itemStorageDelegate] is not null,
  /// [DashboardItemStorageDelegate.onItemsAdded] will call with added item and
  /// its new layout.
  /// It is placed wherever possible. The new layoutData may not be the
  /// same as the one added.
  ///
  /// If the location of the added item is defined, it is tried to be
  /// placed in the location first. If there is a conflict or overflow and
  /// [Dashboard.shrinkToPlace] is true, it is tried to be placed by shrinking.
  /// In this case, if there is more than one possibility, it is placed in
  /// the largest form.
  void add(T item, {bool mountToTop = true}) {
    if (_isAttached) {
      _items[item.identifier] = item;
      _layoutController!.add(item, mountToTop);
      itemStorageDelegate?._onItemsAdded(
          [_getItemWithLayout(item.identifier)], _layoutController!.slotCount);
    } else {
      throw Exception("Not Attached");
    }
  }

  /// Add new multiple items to Dashboard.
  ///
  /// If [itemStorageDelegate] is not null,
  /// [DashboardItemStorageDelegate.onItemsAdded] will call with added items and
  /// their new layouts.
  /// They are placed wherever possible. The new layoutData may not be the
  /// same as the one added.
  ///
  /// If the location of the added item is defined, it is tried to be
  /// placed in the location first. If there is a conflict or overflow and
  /// [Dashboard.shrinkToPlace] is true, it is tried to be placed by shrinking.
  /// In this case, if there is more than one possibility, it is placed in
  /// the largest form.
  void addAll(List<T> items, {bool mountToTop = true}) {
    if (_isAttached) {
      _items.addAll(
          items.asMap().map((key, value) => MapEntry(value.identifier, value)));
      _layoutController!.addAll(items);
      itemStorageDelegate?._onItemsAdded(
          items.map((e) => _getItemWithLayout(e.identifier)).toList(),
          _layoutController!.slotCount);
    } else {
      throw Exception("Not Attached");
    }
    throw 0;
  }

  /// Delete an item from Dashboard.
  void delete(String id) {
    if (_isAttached) {
      itemStorageDelegate?._onItemsDeleted(
          [_getItemWithLayout(id)], _layoutController!.slotCount);
      _layoutController!.delete(id);
      _items.remove(id);
    } else {
      throw Exception("Not Attached");
    }
  }

  /// Delete multiple items from Dashboard.
  void deleteAll(List<String> ids) {
    if (_isAttached) {
      itemStorageDelegate?._onItemsDeleted(
          ids.map((e) => _getItemWithLayout(e)).toList(),
          _layoutController!.slotCount);
      _layoutController!.deleteAll(ids);
      _items.removeWhere((k, v) => ids.contains(k));
    } else {
      throw Exception("Not Attached");
    }
  }

  /// Clear all items from Dashboard.
  void clear() {
    return deleteAll(items);
  }

  T _getItemWithLayout(String id) {
    if (!_isAttached) throw Exception("Not Attached");
    return _items[id]!..layoutData = _layoutController!._layouts![id]!.origin;
  }

  ///
  late Map<String, T> _items;

  /// Get all items.
  ///
  /// The returned list is unmodifiable. A change negative affects
  /// state management and causes conflicts.
  List<String> get items =>
      List.unmodifiable(_items.values.map((e) => e.identifier));

  Duration? _timeout;

  FutureOr<void> _loadItems(int slotCount) {
    var ftr = itemStorageDelegate!._getAllItems(slotCount);
    if (ftr is Future<List<T>>) {
      if (_asyncSnap == null) {
        _asyncSnap = ValueNotifier(const AsyncSnapshot.waiting());
      } else {
        _asyncSnap!.value = const AsyncSnapshot.waiting();
      }
      var completer = Completer();

      ftr.then((value) {
        _items = value
            .asMap()
            .map((key, value) => MapEntry(value.identifier, value));

        completer.complete();
        _asyncSnap!.value = AsyncSnapshot.withData(ConnectionState.done, value);
      }).timeout(_timeout!, onTimeout: () {
        completer.complete();
        _asyncSnap!.value = AsyncSnapshot.withError(
            ConnectionState.none, TimeoutException(null), StackTrace.current);
      }).onError((error, stackTrace) {
        completer.complete();
        _asyncSnap!.value = AsyncSnapshot.withError(
            ConnectionState.none, error ?? Exception(), stackTrace);
      });

      return Future.sync(() => completer.future);
    } else {
      _items =
          ftr.asMap().map((key, value) => MapEntry(value.identifier, value));

      if (_asyncSnap == null) {
        _asyncSnap =
            ValueNotifier(AsyncSnapshot.withData(ConnectionState.done, ftr));
      } else {
        _asyncSnap!.value = AsyncSnapshot.withData(ConnectionState.done, ftr);
      }
      return null;
    }
  }

  ValueNotifier<AsyncSnapshot>? _asyncSnap;

  bool get _isAttached => _layoutController != null;

  _DashboardLayoutController? _layoutController;

  void _attach(_DashboardLayoutController layoutController) {
    _layoutController = layoutController;
  }

// bool trySlideToTop(String id) {
//   return _layoutController!.mountToTop(id);
// }
//
// void slideToTopAll() {
//   return _layoutController!._slideToTopAll();
// }
}

///
class _DashboardLayoutController<T extends DashboardItem> with ChangeNotifier {
  ///
  _DashboardLayoutController();

  ///
  late DashboardItemController<T> itemController;

  ///
  late _ViewportDelegate _viewportDelegate;

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
  Map<String, _ItemCurrentLayout>? _layouts;

  final SplayTreeMap<int, String> _startsTree = SplayTreeMap<int, String>();
  final SplayTreeMap<int, String> _endsTree = SplayTreeMap<int, String>();

  final SplayTreeMap<int, String> _indexesTree = SplayTreeMap<int, String>();

  _EditSession? editSession;

  void startEdit(String id, bool transform) {
    editSession = _EditSession(
        layoutController: this, editing: _layouts![id]!, transform: transform);
  }

  void saveEditSession() {
    if (editSession == null) return;

    if (editSession!._changes.isNotEmpty) {
      itemController.itemStorageDelegate?._onItemsUpdated(
          editSession!._changes
              .map(
                (e) => itemController._getItemWithLayout(e),
              )
              .toList(),
          slotCount);
      for (var i in editSession!._changes) {
        _layouts![i]!._clearListeners();
      }
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

  void add(DashboardItem item, [bool mountToTop = true]) {
    _layouts![item.identifier] = _ItemCurrentLayout(item.layoutData);
    this.mountToTop(
        item.identifier,
        mountToTop
            ? 0
            : getIndex(
                [_adjustToPosition(item.layoutData), item.layoutData.startY]));
    notifyListeners();
  }

  int _adjustToPosition(ItemLayout layout) {
    int start;
    if (layout.startX + layout.width > slotCount) {
      start = slotCount - layout.width;
    } else {
      start = layout.startX;
    }
    return start;
  }

  void addAll(List<DashboardItem> items, {bool mountToTop = true}) {
    for (var item in items) {
      _layouts![item.identifier] = _ItemCurrentLayout(item.layoutData);

      int startX;

      if (mountToTop) {
        startX = 0;
      } else {
        startX = _adjustToPosition(item.layoutData);
      }

      int startY = item.layoutData.startY;

      this.mountToTop(item.identifier, getIndex([startX, startY]));
    }
    notifyListeners();
  }

  ///
  List<int> getIndexCoordinate(int index) {
    return [index % slotCount, index ~/ slotCount];
  }

  List<int?> getOverflowsAlt(ItemLayout itemLayout) {
    var possibilities = <_OverflowPossibility>[];

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
          possibilities.add(_OverflowPossibility(
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
            possibilities.add(_OverflowPossibility(
                itemLayout.startX + itemLayout.width,
                y,
                itemLayout.width,
                y - itemLayout.startY));
          }

          possibilities.add(_OverflowPossibility(
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
    if (i.isEmpty) throw Exception("BURADA SIKINTI VAR: $id : $itemLayout");
    _startsTree[i.first] = id;
    _endsTree[i.last] = id;
    for (var index in i) {
      _indexesTree[index] = id;
    }

    _layouts![id]!.origin = itemLayout.._haveLocation = true;
    _layouts![id]!._mount(this, id);
  }

  bool? shrinkOnMove;

  ///
  ItemLayout? tryMount(int value, ItemLayout itemLayout) {
    var shrinkToPlaceL = shrinkOnMove ?? shrinkToPlace;

    var r = getIndexCoordinate(value);
    var n = itemLayout.copyWithStarts(startX: r[0], startY: r[1]);
    var i = 0;
    while (true) {
      if (i > 1000000) {
        throw Exception("loop");
      }
      i++;

      var exOut = n.startX + n.width > slotCount;

      if (exOut && !shrinkToPlaceL) {
        return null;
      }

      if (shrinkToPlaceL && exOut) {
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
          if (shrinkToPlaceL) {
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
  bool mountToTop(String id, [int start = 0]) {
    try {
      var itemCurrent = _layouts![id]!;

      _removeFromIndexes(itemCurrent, id);

      var i = start;
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
      for (var i in _layouts!.entries
          .where((element) => element.value._haveLocation)) {
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

      layouts:
      for (var i in _layouts!.entries
          .where((element) => !element.value._haveLocation)) {
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
        itemController.itemStorageDelegate?._onItemsUpdated(
            changes.map((e) => itemController._getItemWithLayout(e)).toList(),
            slotCount);
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

  void _setSizes(BoxConstraints constrains, double vertical) {
    verticalSlotEdge = vertical;
    slotEdge =
        (_axis == Axis.vertical ? constrains.maxWidth : constrains.maxHeight) /
            slotCount;
  }

  late bool animateEverytime;

  ///
  void attach(
      {required Axis axis,
      required DashboardItemController<T> itemController,
      required int slotCount,
      required bool slideToTop,
      required bool shrinkToPlace,
      required bool animateEverytime,
      required bool? shrinkOnMove}) {
    this.shrinkOnMove = shrinkOnMove;
    this.itemController = itemController;
    this.slideToTop = slideToTop;
    this.shrinkToPlace = shrinkToPlace;
    this.slotCount = slotCount;
    this.animateEverytime = animateEverytime;
    _axis = axis;
    _isAttached = true;

    _layouts = itemController._items.map((key, value) =>
        MapEntry(value.identifier, _ItemCurrentLayout(value.layoutData)));
    mountItems();
    _rebuild = true;
  }

  bool _rebuild = false;

  ///
  bool _isAttached = false;
}

class _OverflowPossibility extends Comparable<_OverflowPossibility> {
  _OverflowPossibility(this.x, this.y, this.w, this.h) : sq = w * h;

  int x, y, w, h, sq;

  @override
  int compareTo(_OverflowPossibility other) {
    return sq.compareTo(other.sq);
  }
}

///
class _EditSession {
  ///
  _EditSession(
      {required _DashboardLayoutController layoutController,
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
      _Resize resize, void Function(String id, _Change) onBackChange) {
    // _resizes[resize.resize.direction] ??= [];
    // _resizes[resize.resize.direction]!.add(resize.resize);
    if (resize.resize.increment && resize.indirectResizes != null) {
      for (var indirect in resize.indirectResizes!.entries) {
        _indirectChanges[indirect.value.direction] ??= {};
        _indirectChanges[indirect.value.direction]![indirect.key] ??= [];
        _indirectChanges[indirect.value.direction]![indirect.key]!
            .add(indirect.value);
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
        for (var resize in reverseIndirectResizes.entries) {
          if (resize.value.isNotEmpty) {
            onBackChange(
                resize.key, resize.value.removeAt(resize.value.length - 1));
          }
        }
      }
    }
  }

  ///
  final _ItemCurrentLayout editing;

  ///
  final _ItemCurrentLayout editingOrigin;
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
