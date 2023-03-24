import 'package:flutter/material.dart';
import 'package:inspection_flutter_app/Activity/Home.dart';
import 'package:inspection_flutter_app/Activity/Splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}


