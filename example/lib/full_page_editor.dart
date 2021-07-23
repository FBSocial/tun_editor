import 'package:flutter/material.dart';
import 'package:tun_editor/tun_editor.dart';
import 'package:tun_editor/tun_editor_controller.dart';
import 'package:tun_editor/tun_editor_toolbar.dart';

class FullPageEditor extends StatefulWidget {

  const FullPageEditor({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FullPageEditorState();

}

class FullPageEditorState extends State<FullPageEditor> {

  late TunEditorController _controller;

  String _previewText = "";

  @override
  void initState() {
    super.initState();
  
    _controller = TunEditorController.basic()
        ..addListener(() async {
          final String htmlText = await _controller.getHtml();
          setState(() {
            _previewText = htmlText;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
            children: [
              Expanded(
                child: TunEditor(
                  controller: _controller,
                  placeHolder: "Hello World",
                ),
              ),
              SizedBox(
                height: 50,
                child: TunEditorToolbar(
                  controller: _controller,
                ),
              ),
              Container(
                height: 100,
                child: Text(
                  _previewText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
