import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("style_dart framework documentation coming soon...",
              textAlign: TextAlign.center),
          const SizedBox(
            height: 20,
          ),
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/dashboard");
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                  child: Text("Try dashboard demo"),
                )),
          )
        ],
      ),
    );
  }
}
