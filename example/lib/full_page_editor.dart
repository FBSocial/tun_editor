import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/tun_editor.dart';
import 'package:tun_editor/tun_editor_toolbar.dart';
import 'package:tun_editor/controller.dart';

class FullPageEditor extends StatefulWidget {

  const FullPageEditor({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FullPageEditorState();

}

class FullPageEditorState extends State<FullPageEditor> {

  bool isLoading = true;
  late TunEditorController _controller;

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  
    _loadDocument();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: Text('Loading...')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          child: Text("Editor"),
          onTap: () {
            // if (focusNode.hasFocus) {
            //   focusNode.unfocus();
            // } else {
            //   focusNode.requestFocus();
            // }
            // _controller.insertImage('https://avatars0.githubusercontent.com/u/1758864?s=460&v=4');
            // _controller.formatText(0, 2, Attribute.h1);
            // _controller.insert(2, 'Bye Bye');
            //   _controller.insert(_controller.selection.baseOffset, "🛹");
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
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 15,
                  ),
                  placeholder: "Hello World!",
                  focusNode: focusNode,
                  autoFocus: false,
                  readOnly: false,

                  onMentionClick: (String id, String text) {
                    debugPrint('metion click $id, $text');
                  },
                  onLinkClick: (String url) {
                    debugPrint('link click $url');
                  },
                ),
              ),
              TunEditorToolbar(
                controller: _controller,
                showingAt: false,
                showingImage: false,
                showingEmoji: false,
                onAtChange: (bool isShow) {
                  debugPrint('show at subtoolbar change: $isShow');
                },
                onImageChange: (bool isShow) {
                  debugPrint('show image subtoolbar change: $isShow');
                },
                onEmojiChange: (bool isShow) {
                  debugPrint('show emoji sub toolbar change: $isShow');
                },
                onSend: () {
                  debugPrint('send click');
                },

                // menu: [
                //   ToolbarMenu.textType,
                //   ToolbarMenu.textTypeHeadline1,
                //   ToolbarMenu.textTypeHeadline2,
                //   ToolbarMenu.textTypeHeadline3,

                //   ToolbarMenu.textStyle,
                //   ToolbarMenu.textStyleBold,
                //   ToolbarMenu.textStyleItalic,

                //   ToolbarMenu.link,
                // ],
                // children: [
                //   IconButton(
                //     icon: Icon(Icons.add),
                //     onPressed: () {
                //     },
                //   ),
                // ],
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

  Future<void> _loadDocument() async {
    final result = await rootBundle.loadString('assets/sample_data.json');
    final doc = Document.fromJson(jsonDecode(result));

    _controller = TunEditorController(
        document: doc,
        selection: TextSelection.collapsed(offset: 0),
    );
    _controller.document.changes.listen((event) {
      final delta1 = json.encode(event.item1.toJson());
      final delta2 = json.encode(event.item2.toJson());
      debugPrint('event: $delta1 - $delta2');

      final doc = json.encode(_controller.document.toDelta().toJson());
      debugPrint('document: $doc');
    });
    focusNode.addListener(() {
      debugPrint('focus node listener: ${focusNode.hasFocus}');
    });
    setState(() {
      isLoading = false;
    });
  }

}
