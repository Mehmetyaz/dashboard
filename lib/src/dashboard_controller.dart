part of '../dashboard.dart';

class DashboardController {
  DashboardController({required List<DashboardItem> items, required this.verticalSlotCount})
      : items = items.asMap().map((key, value) => MapEntry(value.id, value));



  int  verticalSlotCount;

  ///
  Map<String, DashboardItem> items;

  ///
  final Map<String, ItemCurrentLayout> _currentLayouts = {};

  ///
  final Map<int, String> _index = {};


  void _mountItems() {

  }

  _getItemIndexNumbers() {}
}

class _ItemLayout {
  _ItemLayout(
      {required this.x, required this.y, required this.w, required this.h});

  int x, y, w, h;

  List<int> slots(int verticalSlotCount) {
    throw UnimplementedError();
  }
}
