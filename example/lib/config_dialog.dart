import 'package:example/config.dart';
import 'package:flutter/material.dart';

class ConfigurationDialog extends StatefulWidget {
  const ConfigurationDialog({Key? key, required this.config}) : super(key: key);

  final DashboardConfig config;

  @override
  State<ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<ConfigurationDialog> {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Slot count: "),
                    SizedBox(
                      width: 100,
                      child: DropdownButton<int>(
                          underline: const SizedBox(),
                          alignment: Alignment.centerRight,
                          items: [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
                              .map((e) => DropdownMenuItem<int>(
                                  alignment: Alignment.centerRight,
                                  value: e,
                                  child: Text(
                                    (e).toString(),
                                    textAlign: TextAlign.right,
                                  )))
                              .toList(),
                          value: widget.config.slotCount,
                          onChanged: (v) {
                            setState(() {
                              widget.config.slotCount = v ?? 4;
                            });
                          }),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {},
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                      child: Text("Apply"),
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
}
