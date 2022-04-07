import 'dart:math';

import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Color> _colors = const {
    "1": Colors.red,
    "2": Colors.yellow,
    "3": Colors.indigo,
    "4": Colors.green,
    "5": Colors.purple,
    "6": Colors.blue,
    "7": Colors.teal,
    "8": Colors.yellowAccent
  };

  final ScrollController scrollController = ScrollController();

  int count = 7;

  final itemController = DashboardItemController<String>(items: [
    DashboardItem(
      identifier: "a",
      startX: 0,
      startY: 0,
      width: 2,
      height: 2,
    ),
    DashboardItem(
        identifier: "b",
        startX: 0,
        startY: 2,
        width: 4,
        height: 2,
        minWidth: 2),
    DashboardItem(
        identifier: "c",
        startX: 1,
        startY: 4,
        width: 3,
        height: 1,
        minWidth: 2,
        maxWidth: 3),
    DashboardItem(identifier: "d", startX: 2, startY: 0, width: 1, height: 1),
    DashboardItem(identifier: "e", startX: 2, startY: 5, width: 2, height: 6),
    DashboardItem(identifier: "f", startX: 0, startY: 5, width: 2, height: 1),
    DashboardItem(identifier: "g", startX: 1, startY: 6, width: 1, height: 3),
  ]);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  itemController.setEditMode(!itemController.isEditing);
                },
                icon: const Icon(Icons.edit))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            count++;
            itemController.add(DashboardItem(
                identifier: "$count", width: 3, height: 3, minWidth: 2));
          },
        ),
        body: DashboardWidget(colors: _colors, itemController: itemController),
      ),
    );
  }
}

class DashboardWidget extends StatefulWidget {
  const DashboardWidget(
      {Key? key,
      required Map<String, Color> colors,
      required this.itemController})
      : super(key: key);

  final DashboardItemController<String> itemController;

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  Color getRandomColor() {
    var r = Random();
    return Color.fromRGBO(r.nextInt(256), r.nextInt(256), r.nextInt(256), 1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: 400,
              child: Dashboard(
                shrinkToPlace: false,
                slideToTop: false,
                editModeSettings: const EditModeSettings(
                    resizeCursorSide: 30,
                    foregroundStyle: EditModeForegroundStyle(
                        fillColor: Colors.black12,
                        sideWidth: 10,
                        innerRadius: 8,
                        outherRadius: 8,
                        shadowColor: Colors.transparent,
                        shadowTransparentOccluder: true),
                    backgroundStyle: EditModeBackgroundStyle(
                        lineColor: Colors.black38,
                        lineWidth: 1,
                        doubleLineHorizontal: true,
                        doubleLineVertical: true)),
                padding: const EdgeInsets.all(16),
                mainAxisSpace: 0,
                crossAxisSpace: 0,
                dashboardItemController: widget.itemController,
                slotCount: 4,
                itemBuilder: (DashboardItem item, ItemCurrentLayout layout) {
                  return InkWell(
                    onTap: () {
                      print(layout);
                      print(layout.currentPosition(
                          offset: 0,
                          padding: const EdgeInsets.all(16),
                          mainAxisSpace: 0,
                          crossAxisSpace: 0,
                          slotEdge: 100));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: getRandomColor(),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                          "ID: ${item.identifier} , Layout: ${layout.origin}"),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
