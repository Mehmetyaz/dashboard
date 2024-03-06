part of '../dashboard_base.dart';

/// Dashboard item layout changes stored/handled with the delegate. Keeps the
/// layout in memory, fetches the layout when necessary. It can store different
/// layouts for different slotCounts. Different slotCounts may be required,
/// especially for browser users.
///
/// If [cacheItems] the delegate store layouts from memory.
///
/// If [layoutsBySlotCount] the delegate store and request new layout
/// by slotCount.
///
/// Cached items can be get with [itemsFor].
///
/// [getAllItems] will call if necessary. If your item getter is not Future,
/// do not override as [async], because if you use unnecessary Future, layout
/// changes not animated on slotCount changes.
///
/// [onItemsAdded] will call when [DashboardItemController.add] or
/// [addAll] called. Function called with up-to-date layout data.
///
/// [onItemsUpdated] will call when item layout changes. Layout can be changed
/// by user or initially re-mount operations. Function called with up-to-date
/// layout data.
///
/// [onItemsDeleted] will call when item deleted by
/// [DashboardItemController.delete] or [deleteAll] called.
///
abstract class DashboardItemStorageDelegate<T extends DashboardItem> {
  final Map<int, Map<String, T>> _items = {};

  /// Item list for given slotCount
  Map<String, T>? itemsFor(int slotCount) {
    return _items[slotCount] == null ? null : Map.from(_items[slotCount]!);
  }

  /// If [cacheItems] the delegate store layouts from memory.
  bool get cacheItems;

  /// If [layoutsBySlotCount] the delegate store and request new layout
  /// by slotCount.
  bool get layoutsBySlotCount;

  FutureOr<List<T>> _getAllItems(int slotCount) {
    var sc = layoutsBySlotCount ? slotCount : -1;

    if (!cacheItems) {
      return getAllItems(slotCount);
    } else {
      if (_items[sc] != null) {
        return _items[sc]!.values.toList();
      } else {
        var itemsFtrOr = getAllItems(slotCount);
        if (itemsFtrOr is Future) {
          var items = Future<List<T>>.microtask(() async {
            return await itemsFtrOr;
          }).then((value) {
            _items[sc] = value
                .asMap()
                .map((key, value) => MapEntry(value.identifier, value));
            return value;
          });
          return items;
        } else {
          _items[sc] = itemsFtrOr
              .asMap()
              .map((key, value) => MapEntry(value.identifier, value));
          return itemsFtrOr;
        }
      }
    }
  }

  ///
  FutureOr<void> _onItemsUpdated(List<T> items, int slotCount) {
    var sc = layoutsBySlotCount ? slotCount : -1;

    if (cacheItems) {
      var map = _items[sc];
      if (map != null) {
        for (var i in items) {
          map[i.identifier] = i;
        }
      }
    }
    return onItemsUpdated(items, slotCount);
  }

  ///
  FutureOr<void> _onItemsAdded(List<T> items, int slotCount) {
    if (cacheItems) {
      _items.forEach((key, value) {
        for (var i in items) {
          var l = i.layoutData;
          if (l.minWidth <= key) {
            value[i.identifier] = i;
          }
        }
      });
    }

    return onItemsAdded(items, slotCount);
  }

  ///
  FutureOr<void> _onItemsDeleted(List<T> items, int slotCount) {
    if (cacheItems) {
      _items.forEach((key, value) {
        for (var i in items) {
          value.remove(i.identifier);
        }
      });
    }
    return onItemsDeleted(items, slotCount);
  }

  /// [getAllItems] will call if necessary. If your item getter is not Future,
  /// do not override as [async], because if you use unnecessary Future, layout
  /// changes not animated on slotCount changes.
  FutureOr<List<T>> getAllItems(int slotCount);

  /// [onItemsUpdated] will call when item layout changes. Layout can be changed
  /// by user or initially re-mount operations. Function called with up-to-date
  /// layout data.
  FutureOr<void> onItemsUpdated(List<T> items, int slotCount);

  /// [onItemsAdded] will call when [DashboardItemController.add] or
  /// [addAll] called. Function called with up-to-date layout data.
  FutureOr<void> onItemsAdded(List<T> items, int slotCount);

  /// [onItemsDeleted] will call when item deleted by
  /// [DashboardItemController.delete] or [deleteAll] called.
  FutureOr<void> onItemsDeleted(List<T> items, int slotCount);
}
