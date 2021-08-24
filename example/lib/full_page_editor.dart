import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tun_editor/iconfont.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/models/quill_delta.dart';
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

  bool _isLoading = true;
  late TunEditorController _controller;

  // FocusNode _titleFocusNode = FocusNode();
  FocusNode _editorFocusNode = FocusNode();

  bool _readOnly = false;

  SubToolbar _showingSubToolbar = SubToolbar.none;

  List<ToolbarMenu> _disabledMenu = [];

  final _emojiList = [
    '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '🥲', '☺️', '😊', '😇', '🙂',
    '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝',
    '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🥸', '🤩', '🥳', '😏', '😒', '😞',
    '😔', '😟', '😕', '🙁', '☹️', '😣', '😖', '😫', '😩', '🥺', '😢', '😭',
    '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥',
    '😓', '🤗', '🤔', '🤭', '🤫', '🤥', '😶', '😐', '😑', '😬', '🙄', '😯',
    '😦', '😧', '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '🤐', '🥴', '🤢',
    '🤮', '🤧', '😷', '🤒', '🤕', '🤑', '🤠', '😈', '👿', '👹', '👺', '🤡',
    '💩', '👻', '💀', '☠️', '👽', '👾', '🤖', '🎃', '😺', '😸', '😹', '😻',
    '😼', '😽', '🙀', '😿', '😾',
  ];

  @override
  void initState() {
    super.initState();

    _loadDocument();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: Text('Loading...')));
    }
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text('Editor'),
          onTap: () {
            // _controller.insertVideo(
            //   source: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
            //   width: 230,
            //   height: 460,
            //   duration: 7,
            //   thumbUrl: 'https://fb-cdn.fanbook.mobi/fanbook/app/files/chatroom/image/43789ea4452106628661d9014d45c873.jpg',
            // );
            // _controller.updateSelection(TextSelection.collapsed(offset: 10), ChangeSource.LOCAL);

            // final imageBlock = BlockEmbed.image(
            //   'https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png',
            // );
            // _controller.replaceText(0, 0, imageBlock, null,
            //   ignoreFocus: false,
            //   autoAppendNewlineAfterImage: true,
            //   attributes: [
            //     WidthAttribute('100'),
            //   ],
            // );

            _controller.compose(new Delta()
                ..retain(1)
                ..insert('Hello World', Attribute.bold.toJson()),
                TextSelection.collapsed(offset: 2), ChangeSource.LOCAL);

            // _controller.formatText(0, 2, Attribute.bold);
            // _controller.insert(2, 'Bye Bye');
            // _controller.insert(_controller.selection.baseOffset, '🛹');
            // _controller.replaceText(6, 5, 'Jeffrey Wu', null);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Stack(
            children: [
              Column(
                children: [
                  // TextField(
                  //   focusNode: _titleFocusNode,
                  //   textInputAction: TextInputAction.next,
                  // ),
                  Expanded(
                    child: TunEditor(
                      controller: _controller,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 15,
                      ),
                      placeholder: 'Hello World!',
                      focusNode: _editorFocusNode,
                      autoFocus: false,
                      readOnly: _readOnly,
                      scrollable: true,

                      onMentionClick: (String id, String prefixChar, String text) {
                        debugPrint('metion click $id, $prefixChar, $text');
                      },
                      onLinkClick: (String url) {
                        debugPrint('link click $url');
                      },

                      onFocusChange: (bool hasFocus) {
                        if (hasFocus) {
                          if (_showingSubToolbar != SubToolbar.none) {
                            setState(() {
                              _showingSubToolbar = SubToolbar.none;
                            });
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 48),
                ],
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TunEditorToolbar(
                      controller: _controller,

                      // Sub toolbar control.
                      showingSubToolbar: _showingSubToolbar,
                      onSubToolbarChange: (SubToolbar subToolbar) {
                        // Hide keyboard on panel showing.
                        if (subToolbar == SubToolbar.at || subToolbar == SubToolbar.image
                            || subToolbar == SubToolbar.emoji) {
                          // TODO Hide keyboard only.
                          _controller.blur();
                        }
                        setState(() {
                          _showingSubToolbar = subToolbar;
                          _readOnly = _showingSubToolbar == SubToolbar.emoji;
                        });
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

                      disabledMenu: _disabledMenu,
                      onDisabledMenuChange: (disabledMenu) {
                        setState(() {
                          _disabledMenu = disabledMenu;
                        });
                      },

                      children: [
                        Spacer(),

                        // Send button.
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 48,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(0x268F959E),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              IconFont.send,
                              size: 24,
                              color: Color(0xA6363940),
                            ),
                          ),
                        ),
                      ],
                    ),

                    _showingSubToolbar == SubToolbar.at
                        ? _buildAtPicker() : SizedBox.shrink(),
                    _showingSubToolbar == SubToolbar.image
                        ? _buildImagePicker() : SizedBox.shrink(),
                    _showingSubToolbar == SubToolbar.emoji
                        ? _buildbEmojiPicker() : SizedBox.shrink(),

                  ],
                ),
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

  Widget _buildAtPicker() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('People $index'),
            onTap: () {
              if (index % 2 == 0) {
                _controller.insertMention('$index', '@People $index');
              } else {
                _controller.insertMention('$index', '#Topic $index', prefixChar: '#');
              }
            },
          );
        }
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: IconButton(
        onPressed: () {
          _pickImage();
        },
        icon: Icon(
          Icons.image,
        ),
      ),
    );
  }

  Widget _buildbEmojiPicker() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: GridView.builder(
        itemCount: _emojiList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _controller.insert(
                _controller.selection.extentOffset,
                _emojiList[index],
                ignoreFocus: true,
              );
            },
            child: Align(
              alignment: Alignment.center,
              child: Text(
                _emojiList[index],
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadDocument() async {
    final result = await rootBundle.loadString('assets/sample_data.json');
    final doc = Document.fromJson(jsonDecode(result));
    // final doc = Document();

    _controller = TunEditorController(
        document: doc,
        selection: TextSelection.collapsed(offset: 0),
    );
    _controller.document.changes.listen((event) {
      // final delta1 = json.encode(event.item1.toJson());
      final delta2 = json.encode(event.item2.toJson());
      debugPrint('event:  $delta2');

      final doc = json.encode(_controller.document.toDelta().toJson());
      debugPrint('document: $doc');
    });
    _controller.addSelectionListener((selection) {
      debugPrint('new selection ${selection.baseOffset} ${selection.extentOffset}');
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _controller.insertImage(
        source: 'file://${image.path}',
        width: 230,
        attributes: [
          WidthAttribute("200"),
          HeightAttribute("100"),
        ]
      );
    }
  }

}
