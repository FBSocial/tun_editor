import 'package:flutter/material.dart';
import 'package:tun_editor/tun_editor.dart';

class FullPageEditor extends StatefulWidget {

  const FullPageEditor({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FullPageEditorState();

}

class FullPageEditorState extends State<FullPageEditor> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: TunEditor.buildEditor(),
      ),
    );
  }

}
