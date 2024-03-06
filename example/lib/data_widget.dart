import 'package:auto_size_text/auto_size_text.dart';
import 'package:dashboard/dashboard.dart';
import 'package:example/storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

const Color blue = Color(0xFF4285F4);
const Color red = Color(0xFFEA4335);
const Color yellow = Color(0xFFFBBC05);
const Color green = Color(0xFF34A853);

class DataWidget extends StatelessWidget {
  DataWidget({super.key, required this.item});

  final ColoredDashboardItem item;

  final Map<String, Widget Function(ColoredDashboardItem i)> _map = {
    "welcome": (l) => const WelcomeWidget(),
    "resize": (l) => AdviceResize(size: l.layoutData.width),
    "description": (l) => const BasicDescription(),
    "transform": (l) => const TransformAdvice(),
    "add": (l) => const AddAdvice(),
    "buy_mee": (l) => const BuyMee(),
    "delete": (l) => const ClearAdvice(),
    "refresh": (l) => const DefaultAdvice(),
    "info": (l) => InfoAdvice(layout: l.layoutData),
    "github": (l) => const Github(),
    "twitter": (l) => const Twitter(),
    "linkedin": (l) => const LinkedIn(),
    "pub": (l) => const Pub(),
  };

  @override
  Widget build(BuildContext context) {
    return _map[item.data]!(item);
  }
}

class Pub extends StatelessWidget {
  const Pub({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrlString("https://pub.dev/packages/dashboard");
      },
      child: Container(
        color: Colors.white,
        child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage("assets/pub_dev.png")))),
      ),
    );
  }
}

class LinkedIn extends StatelessWidget {
  const LinkedIn({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrlString("https://www.linkedin.com/in/mehmetyaz/");
      },
      child: Container(
        color: const Color(0xFF0A66C2),
        child: Row(
          children: [
            const Expanded(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Connect Me!", style: TextStyle(color: Colors.white)),
            )),
            Expanded(
              child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage("assets/linkedin.png")))),
            ),
          ],
        ),
      ),
    );
  }
}

class Twitter extends StatelessWidget {
  const Twitter({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrlString("https://twitter.com/smehmetyaz");
      },
      child: Container(
        color: const Color(0xFF1DA0F1),
        child: Row(
          children: [
            const Expanded(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Follow Me!", style: TextStyle(color: Colors.white)),
            )),
            Expanded(
              child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage("assets/twitter.png")))),
            ),
          ],
        ),
      ),
    );
  }
}

class Github extends StatelessWidget {
  const Github({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrlString("https://github.com/Mehmetyaz/dashboard");
      },
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            const Expanded(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Create Issue!",
                style: TextStyle(color: Colors.black),
              ),
            )),
            Expanded(
              child: Container(
                  margin: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage("assets/github.png")))),
            ),
          ],
        ),
      ),
    );
  }
}

class BuyMee extends StatelessWidget {
  const BuyMee({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrlString("https://www.buymeacoffee.com/mehmetyaz");
      },
      child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: AssetImage("assets/img.png")))),
    );
  }
}

class InfoAdvice extends StatelessWidget {
  const InfoAdvice({super.key, required this.layout});

  final ItemLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: blue,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            const Text("Example dimensions and locations. (showing this)",
                style: TextStyle(color: Colors.white)),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: DataTable(

                    headingRowHeight: 25,
                    border: const TableBorder(
                        horizontalInside: BorderSide(color: Colors.white)),
                    headingTextStyle: const TextStyle(color: Colors.white),
                    dataTextStyle: const TextStyle(color: Colors.white),
                    columns: const [
                      DataColumn(label: Text("startX")),
                      DataColumn(label: Text("startY")),
                      DataColumn(label: Text("width")),
                      DataColumn(label: Text("height"))
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text(layout.startX.toString())),
                        DataCell(Text(layout.startY.toString())),
                        DataCell(Text(layout.width.toString())),
                        DataCell(Text(layout.height.toString())),
                      ])
                    ]),
              ),
            ),
          ],
        ));
  }
}

class DefaultAdvice extends StatelessWidget {
  const DefaultAdvice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: yellow,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 30,
              color: Colors.white,
            ),
            Expanded(
              child: Text(
                "Your layout changes saved locally."
                " Set default with this button.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ));
  }
}

class ClearAdvice extends StatelessWidget {
  const ClearAdvice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: green,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              size: 30,
              color: Colors.white,
            ),
            Text(
              "Delete all widgets.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            )
          ],
        ));
  }
}

class AddAdvice extends StatelessWidget {
  const AddAdvice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: blue,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            ),
            Text(
              "Add own colored widget with custom sizes.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            )
          ],
        ));
  }
}

class TransformAdvice extends StatelessWidget {
  const TransformAdvice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: red,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Users can move widgets.",
              style: TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            Text(
              "To try moving, hold (or long press) the widget and move.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "While moving, it shrinks if possible according to the "
                    "minimum width and height values.\n(This min w: 2 , h: 2)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
/*
                Icon(
                  Icons.arrow_right_alt,
                  color: Colors.white,
                  size: 30,
                )
*/
              ],
            ),
          ],
        ));
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: red,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    children: [
                  const TextSpan(text: "Welcome to "),
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrlString("https://pub.dev/packages/dashboard");
                        },
                      text: "dashboard",
                      style: const TextStyle(
                          decoration: TextDecoration.underline)),
                  const TextSpan(text: " online demo!"),
                ])),
          ],
        ));
  }
}

class BasicDescription extends StatelessWidget {
  const BasicDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: yellow,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AutoSizeText(
                "Each widget on the screen is called \"DashboardItem\"",
                maxLines: 4,
                style: TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center),
            AutoSizeText("Each has a location and dimensions by slots.",
                maxLines: 3,
                style: TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center),
            Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                      "You can switch to edit mode to see these slots.",
                      maxLines: 4,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      textAlign: TextAlign.center),
                ),
                SizedBox(
                  width: 8,
                ),
                Column(
                  children: [
                    Text("Tap: ",
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                    Icon(Icons.edit, color: Colors.white),
                  ],
                )
              ],
            ),
          ],
        ));
  }
}

class AdviceResize extends StatelessWidget {
  const AdviceResize({super.key, required this.size});

  final int size;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: green,
        alignment: Alignment.center,
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 5),
              height: double.infinity,
              width: 1,
              color: Colors.white,
            ),
            const Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AutoSizeText("Users can resize widgets.",
                    maxLines: 2,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center),
                AutoSizeText(
                    "To try resizing, hold (or long press) the line on the left"
                    " and drag it to the left.",
                    maxLines: 5,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center),
                AutoSizeText("Don't forget switch to edit mode.",
                    maxLines: 3,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center),
              ],
            ))
          ],
        ));
  }
}
