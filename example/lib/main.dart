import 'dart:async';
import 'dart:math';

import 'package:dashboard/dashboard.dart';

import 'package:example/storage.dart';
import 'package:flutter/material.dart';

import 'add_dialog.dart';

///
void main() {
  ///
  runApp(const MyApp());
}

///
class MyApp extends StatefulWidget {
  ///
  const MyApp({Key? key}) : super(key: key);

  ///
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ///
  Color getRandomColor() {
    var r = Random();
    return Color.fromRGBO(r.nextInt(256), r.nextInt(256), r.nextInt(256), 1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DashboardWidget(),
    );
  }
}

class DashboardWidget extends StatefulWidget {
  ///
  const DashboardWidget({Key? key}) : super(key: key);

  ///
  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  ///
  final ScrollController scrollController = ScrollController();

  ///
  final itemController =
      DashboardItemController<ColoredDashboardItem>.withDelegate(
          itemStorageDelegate: MyItemStorage());

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                itemController.clear();
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () {
                add(context);
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                itemController.setEditMode(!itemController.isEditing);
                setState(() {});
              },
              icon: const Icon(Icons.edit)),
          // IconButton(
          //     onPressed: () {
          //       configuration(context);
          //     },
          //     icon: const Icon(Icons.settings))
        ],
      ),
      body: SafeArea(
        child: Dashboard<ColoredDashboardItem>(
          shrinkToPlace: true,
          slideToTop: true,
          absorbPointer: false,
          padding: const EdgeInsets.all(1),
          horizontalSpace: 8,
          verticalSpace: 8,
          slotAspectRatio: 1.7,
          dashboardItemController: itemController,
          slotCount:
              4 /*(MediaQuery.of(context).size.width ~/ 100).clamp(2, 20)*/,
          errorPlaceholder: (e, s) {
            return Text("$e , $s");
          },
          physics: const ClampingScrollPhysics(),
          editModeSettings: const EditModeSettings(
              paintItemForeground: false,
              resizeCursorSide: 15,
              fillBackgroundAnimationDuration: Duration(milliseconds: 200),
              foregroundStyle: EditModeForegroundStyle(
                  fillColor: Colors.black12,
                  sideWidth: 15,
                  innerRadius: 8,
                  outherRadius: 8,
                  shadowColor: Colors.black12,
                  shadowTransparentOccluder: true),
              backgroundStyle: EditModeBackgroundStyle(
                  lineColor: Colors.black38,
                  lineWidth: 0.5,
                  doubleLineHorizontal: true,
                  doubleLineVertical: true)),
          itemBuilder: (ColoredDashboardItem item) {
            var layout = item.layoutData;
            return Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(10)),
                  child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Text("ID: ${item.identifier}\n${[
                        "x: ${layout.startX}",
                        "y: ${layout.startY}",
                        "w: ${layout.width}",
                        "h: ${layout.height}",
                        if (layout.minWidth != 1) "minW: ${layout.minWidth}",
                        if (layout.minHeight != 1) "minH: ${layout.minHeight}",
                        if (layout.maxWidth != null) "maxW: ${layout.maxWidth}",
                        if (layout.maxHeight != null)
                          "maxH : ${layout.maxHeight}"
                      ].join("\n")}")),
                ),
                if (itemController.isEditing)
                  Positioned(
                      right: 5,
                      top: 5,
                      child: InkResponse(
                          radius: 20,
                          onTap: () {
                            itemController.delete(item.identifier);
                          },
                          child: const Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 20,
                          )))
              ],
            );
          },
        ),
      ),
    );
  }

  // Future<void> configuration(BuildContext context) async {
  //   var res = await showDialog(
  //       context: context,
  //       builder: (c) {
  //         return const ConfigurationDialog();
  //       });
  //   if (res != null) {}
  // }

  Future<void> add(BuildContext context) async {
    var res = await showDialog(
        context: context,
        builder: (c) {
          return const AddDialog();
        });

    if (res != null) {
      itemController.add(ColoredDashboardItem(
          color: res[6],
          width: res[0],
          height: res[1],
          identifier: Random().nextInt(100000).toString(),
          minWidth: res[2],
          minHeight: res[3],
          maxWidth: res[4] == 0 ? null : res[4],
          maxHeight: res[5] == 0 ? null : res[5]));
    }
  }
}
