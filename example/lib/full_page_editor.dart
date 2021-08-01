import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/documents/document.dart';
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
  
    _controller = TunEditorController(
        document: Document(),
        selection: TextSelection.collapsed(offset: 0),
    );
    _controller.document.changes.listen((event) {
      final delta1 = json.encode(event.item1.toJson());
      final delta2 = json.encode(event.item2.toJson());
      debugPrint('event: $delta1 - $delta2');

      final doc = json.encode(_controller.document.toDelta().toJson());
      debugPrint('document: $doc');

      setState(() {
        _previewText = doc;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          child: Text("Editor"),
          onTap: () {
            _controller.formatText(0, 2, Attribute.h1);
            // _controller.insert(2, 'Bye Bye');
            // _controller.replaceText(6, 5, 'Jeffrey Wu', null);
          },
        ),
      ),
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
              // SizedBox(
              //   height: 50,
              //   child: SingleChildScrollView(
              //     child: Text(
              //       _previewText,
              //     ),
              //   ),
              // ),
              TunEditorToolbar(
                controller: _controller,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
  
    super.dispose();
  }

}
