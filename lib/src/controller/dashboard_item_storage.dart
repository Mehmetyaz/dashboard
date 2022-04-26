import 'dart:async';

import 'package:dashboard/dashboard.dart';

abstract class DashboardItemStorageDelegate<T extends DashboardItem> {
  ///
  FutureOr<List<T>> getAllItems(int slotCount);

  ///
  FutureOr<void> onItemsUpdated(List<T> items);

  ///
  FutureOr<void> onItemsAdded(List<T> items);

  ///
  FutureOr<void> onItemsDeleted(List<T> items);
}
