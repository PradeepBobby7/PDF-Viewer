import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

import 'homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var heart = Emoji('heart', '❤️');
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "iLikePDF♡",
      home: HomeScreen(),
    );
  }
}
