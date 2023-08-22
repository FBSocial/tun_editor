import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tun_editor_example/full_page_editor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      title: "Tun editor example",
      home: FullPageEditor(),
      theme: ThemeData(
        dividerTheme: DividerThemeData(
          space: 0,
        ),
      ),
    );
  }
}
