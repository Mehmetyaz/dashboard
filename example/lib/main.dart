import 'dart:math';

import 'package:example/screens/dashboard_page.dart';
import 'package:example/screens/main_page.dart';
import 'package:flutter/material.dart';

///
void main() {
  ///
  runApp(const MyApp());
}

///
class MyApp extends StatefulWidget {
  ///
  const MyApp({super.key});

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
      title: 'Dashboard demo',
      onGenerateInitialRoutes: (r) {
        return r == "/dashboard"
            ? [
                MaterialPageRoute(builder: (c) {
                  return const DashboardPage();
                })
              ]
            : [
                MaterialPageRoute(builder: (c) {
                  return const MainPage();
                })
              ];
      },
      initialRoute: "/",
      routes: {
        "/": (c) => const MainPage(),
        "/dashboard": (c) => const DashboardPage()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
