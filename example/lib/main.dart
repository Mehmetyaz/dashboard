import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var ss = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: ss.width,
        height: ss.height * 4,
        child: Scrollable(
          viewportBuilder: (c, o) {
            return Stack(
              children: [
                Positioned(
                    left: 0,
                    width: ss.width / 2,
                    height: ss.height / 2,
                    top: ss.height / 2 * 0 - o.pixels,
                    child: Container(
                      color: Colors.red,
                    )),
                Positioned(
                    left: 0,
                    width: ss.width / 2,
                    height: ss.height / 2,
                    top: ss.height / 2 * 1 - o.pixels,
                    child: Container(
                      color: Colors.green,
                    )),
                Positioned(
                    left: 0,
                    width: ss.width / 2,
                    height: ss.height / 2,
                    top: ss.height / 2 * 2 - o.pixels,
                    child: Container(
                      color: Colors.yellow,
                    )),
                Positioned(
                    left: 0,
                    width: ss.width / 2,
                    height: ss.height / 2,
                    top: ss.height / 2 * 3 - o.pixels,
                    child: Container(
                      color: Colors.deepPurpleAccent,
                    ))
              ],
            );
          },
        ),
      ),
    );
  }
}
