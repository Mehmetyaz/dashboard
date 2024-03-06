import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  int minW = 1, minH = 1, w = 1, h = 1;

  int? maxW, maxH;

  List values = [
    1, //w 0
    1, //h 1
    1, //minW 2
    1, //minH 3
    0, //maxW 4
    0, //maxH 5
    // 6
  ];

  Color color = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text("Add item with:"),
                drop("Width", false, 0, false),
                drop("Height", false, 1, false),
                drop("Minimum Width", false, 2, true),
                drop("Minimum Height", false, 3, true),
                drop("Maximum Width", true, 4, false),
                drop("Maximum Height", true, 5, false),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Color: "),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: BlockPicker(
                            pickerColor: color,
                            onColorChanged: (c) {
                              setState(() {
                                color = c;
                              });
                            }),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (values[0] < values[2]) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("width >= minWidth is not true.")));
                        return;
                      }
                      if (values[1] < values[3]) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("height >= minHeight is not true.")));
                        return;
                      }
                      if (values[4] != 0 && values[0] > values[4]) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("width <= maxWidth is not true.")));
                        return;
                      }
                      if (values[5] != 0 && values[1] > values[5]) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("height <= maxHeight is not true.")));
                        return;
                      }

                      Navigator.pop(context, values..add(color));
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                      child: Text("Add"),
                    )),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drop(String name, bool nullable, int index, bool bounded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$name: "),
        SizedBox(
          width: 100,
          child: DropdownButton<int>(
              underline: const SizedBox(),
              alignment: Alignment.centerRight,
              items: [
                if (nullable) 0,
                1,
                2,
                3,
                4,
                if (!bounded) ...[5, 6, 7, 8, 9]
              ]
                  .map((e) => DropdownMenuItem<int>(
                      alignment: Alignment.centerRight,
                      value: e,
                      child: Text(
                        (e == 0 ? "null" : e).toString(),
                        textAlign: TextAlign.right,
                      )))
                  .toList(),
              value: values[index],
              onChanged: (v) {
                setState(() {
                  values[index] = v ?? 1;
                });
              }),
        ),
      ],
    );
  }
}
