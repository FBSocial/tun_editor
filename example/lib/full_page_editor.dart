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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.pink,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 3),
                spreadRadius: 3,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: TunEditor.buildEditor(),
              ),
              SizedBox(
                height: 50,
                child: TunEditor.toolbar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
