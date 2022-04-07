import 'dart:async';

import 'package:dashboard/dashboard.dart';

abstract class DashboardItemStorage {
  ///
  List<DashboardItem> getAllItems();

  ///
  FutureOr<void> updateItemLayout(DashboardItem item);

  ///
  FutureOr<void> addNewItem(DashboardItem item);

  ///
  FutureOr<void> deleteItem(DashboardItem item);
}
