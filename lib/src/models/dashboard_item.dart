part of '../../dashboard.dart';

abstract class DashboardItem {
  factory DashboardItem.empty(
          {required String id, required ItemLayoutData layoutData}) =>
      EmptyDashboard(id: id, layoutData: layoutData);

  DashboardItem({required this.id, required this.layoutData});

  ItemLayoutData layoutData;
  String id;
}

class EmptyDashboard extends DashboardItem {
  EmptyDashboard({required String id, required ItemLayoutData layoutData})
      : super(id: id, layoutData: layoutData);
}
