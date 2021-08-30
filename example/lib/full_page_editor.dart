import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tun_editor/iconfont.dart';
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

  bool _isLoading = true;
  late TunEditorController _controller;

  late String _fileBasePath;

  FocusNode _editorFocusNode = FocusNode();

  bool _readOnly = false;

  SubToolbar _showingSubToolbar = SubToolbar.none;
  bool get isShowingAIE => _showingSubToolbar == SubToolbar.at
    || _showingSubToolbar == SubToolbar.image
    || _showingSubToolbar == SubToolbar.emoji;
  bool get isNotShowingAIE => _showingSubToolbar != SubToolbar.at
    && _showingSubToolbar != SubToolbar.image
    && _showingSubToolbar != SubToolbar.emoji;
  List<ToolbarMenu> _disabledMenu = [];

  double _keyboardMaxHeight = 0;

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
    _editorFocusNode.addListener(() {
      if (_editorFocusNode.hasFocus) {
        if (_showingSubToolbar != SubToolbar.none) {
          setState(() {
            _showingSubToolbar = SubToolbar.none;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: Text('Loading...')));
    }
    return KeyboardSizeProvider(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: GestureDetector(
            child: Text('Editor'),
            onTap: () {
              debugPrint('focus: ${_editorFocusNode.hasFocus}');
              if (_editorFocusNode.hasFocus) {
                _editorFocusNode.unfocus();
              } else {
                _editorFocusNode.requestFocus();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Consumer<ScreenHeight>(
              builder: (BuildContext context, ScreenHeight keyboard, child) {
                if (keyboard.keyboardHeight > _keyboardMaxHeight) {
                  _keyboardMaxHeight = keyboard.keyboardHeight;
                }
                return Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: TunEditor(
                            controller: _controller,
                            fileBasePath: _fileBasePath,
                            imageStyle: {
                              'width': 100,
                              'height': 100,
                              'align': 'left',
                            },
                            videoStyle: {
                              'width': 100,
                              'height': 100,
                              'align': 'left',
                            },

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
                          ),
                        ),
                        SizedBox(height: 48),
                        keyboard.isOpen || isShowingAIE
                            ? SizedBox(
                              height: isShowingAIE ? _keyboardMaxHeight : keyboard.keyboardHeight,
                            )
                            : SizedBox.shrink(),
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
                                _controller.blur();
                                // _controller.toggleKeyboard(false);
                              }
                              setState(() {
                                _showingSubToolbar = subToolbar;
                                // _readOnly = _showingSubToolbar == SubToolbar.emoji;
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

                          keyboard.isOpen && _showingSubToolbar != SubToolbar.at
                              && _showingSubToolbar != SubToolbar.image
                              && _showingSubToolbar != SubToolbar.emoji
                              ? SizedBox(
                                height: keyboard.keyboardHeight,
                              )
                              : SizedBox.shrink(),

                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
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
      height: _keyboardMaxHeight,
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
      height: _keyboardMaxHeight,
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
      height: _keyboardMaxHeight,
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

    final list = doc.toDelta().toJson();
    for (final i in list) {
      debugPrint('$i');
    }

    _controller = TunEditorController(
        document: doc,
        selection: TextSelection.collapsed(offset: 0),
    );
    _controller.document.changes.listen((event) {
      // final delta1 = json.encode(event.item1.toJson());
      final delta2 = json.encode(event.item2.toCompatibleJson());
      debugPrint('event:  $delta2');

      final doc = json.encode(_controller.document.toDelta().toCompatibleJson());
      debugPrint('document: $doc');
    });
    _controller.addSelectionListener((selection) {
      debugPrint('selection changed ${selection.baseOffset} ${selection.extentOffset}');
      if (_showingSubToolbar == SubToolbar.at || _showingSubToolbar == SubToolbar.image
          || _showingSubToolbar == SubToolbar.emoji) {
        setState(() {
          _showingSubToolbar = SubToolbar.none;
        });
      }
    });

    if (Platform.isIOS) {
      final appDocPath = await getApplicationDocumentsDirectory();
      final tempPath = path.join(appDocPath.parent.path, 'tmp');
      _fileBasePath = tempPath;
    } else {
      final tempPath = await getTemporaryDirectory();
      _fileBasePath = tempPath.path;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _controller.insertImage(
        // source: 'file://${image.name}',
        name: image.name,
        source: image.name,
        checkPath: image.name,
        width: 230,
        height: 230,
      );
      // _controller.insertVideo(
      //   source: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
      //   duration: 100,
      //   thumbUrl: 'file://${image.name}',
      //   thumbName: image.name,
      //   fileType: 'mp4',
      //   width: 100,
      //   height: 200,
      // );
    }
  }

}
