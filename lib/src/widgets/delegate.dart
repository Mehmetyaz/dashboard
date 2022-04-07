part of dashboard;

// class DashboardDelegate extends SliverGridDelegate {
//   DashboardDelegate(
//       {required this.dashboardController,
//       required this.axis,
//       this.mainAxisSpace = 8,
//       this.crossAxisSpace = 8});
//
//   ///
//   final DashboardController dashboardController;
//
//   ///
//   double mainAxisSpace;
//
//   ///
//   double crossAxisSpace;
//
//   ///
//   final Axis axis;
//
//   @override
//   SliverGridLayout getLayout(SliverConstraints constraints) {
//     dashboardController.attach(constraints.asBoxConstraints(), axis);
//     return DashboardGridLayout(dashboardController, 10);
//   }
//
//   @override
//   bool shouldRelayout(covariant DashboardDelegate oldDelegate) {
//     return false;
//   }
// }

// class DashboardGridLayout extends SliverGridLayout {
//   const DashboardGridLayout(this.controller, this.constraints);
//
//   final DashboardController controller;
//
//   final double constraints;
//
//   Axis get axis => controller._axis;
//
//   double get slotEdgeLen => controller._slotEdge;
//
//   @override
//   double computeMaxScrollOffset(int childCount) {
//     if (kDebugMode) {
//       print("Compute");
//     }
//
//     var c =
//         controller._layouts[controller._index[controller._endsSorted.last]]!;
//
//     return axis == Axis.vertical
//         ? ((c.startY + c.height) * slotEdgeLen)
//         : (((c.startX + c.width) * slotEdgeLen));
//   }
//
//   @override
//   SliverGridGeometry getGeometryForChildIndex(int index) {
//     var item =
//         controller._layouts[controller._index[controller._sorted[index]]]!;
//     return SliverGridGeometry(
//         scrollOffset: axis == Axis.vertical
//             ? item.startY * slotEdgeLen
//             : item.startX * slotEdgeLen,
//         crossAxisOffset: axis == Axis.vertical
//             ? item.startX * slotEdgeLen
//             : item.startY * slotEdgeLen,
//         mainAxisExtent: axis == Axis.vertical
//             ? item.height * slotEdgeLen
//             : item.width * slotEdgeLen,
//         crossAxisExtent: axis == Axis.vertical
//             ? item.width * slotEdgeLen
//             : item.height * slotEdgeLen);
//   }
//
//   @override
//   int getMaxChildIndexForScrollOffset(double scrollOffset) {
//     return controller._sorted.length - 1;
//   }
//
//   @override
//   int getMinChildIndexForScrollOffset(double scrollOffset) {
//     return 0;
//   }
// }
