import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tun_editor/edit_text.dart';
import 'package:tun_editor/iconfont.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/models/documents/nodes/embed.dart';

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
  late TunEditorController _dialogEditorController;

  late String _fileBasePath;

  FocusNode _editorFocusNode = FocusNode();

  bool _readOnly = false;

  SubToolbar _showingSubToolbar = SubToolbar.none;
  bool get isShowingAIE =>
      _showingSubToolbar == SubToolbar.at ||
      _showingSubToolbar == SubToolbar.image ||
      _showingSubToolbar == SubToolbar.emoji;
  bool get isNotShowingAIE =>
      _showingSubToolbar != SubToolbar.at &&
      _showingSubToolbar != SubToolbar.image &&
      _showingSubToolbar != SubToolbar.emoji;
  List<ToolbarMenu> _disabledMenu = [];

  double _keyboardMaxHeight = 0;

  String _previewText = '';

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
      debugPrint('on focus change ${_editorFocusNode.hasFocus}');
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
          actions: [
            IconButton(
              onPressed: () {
                _showEditorDialog();
              },
              icon: Icon(
                Icons.keyboard,
              ),
            ),
          ],
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
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Flutter text field',
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: EditText(),
                      ),
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
                          placeholderStyle: TextStyle(
                              color: Colors.pink,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.combine([
                                TextDecoration.underline,
                                TextDecoration.lineThrough,
                              ])),
                          focusNode: _editorFocusNode,
                          autoFocus: false,
                          readOnly: _readOnly,
                          scrollable: true,
                          onMentionClick:
                              (String id, String prefixChar, String text) {
                            debugPrint('metion click $id, $prefixChar, $text');
                          },
                          onLinkClick: (String url) {
                            debugPrint('link click $url');
                          },
                          enableMarkdownSyntax: false,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: SingleChildScrollView(
                          child: Text(_previewText),
                        ),
                      ),
                      SizedBox(height: 48),
                      keyboard.isOpen || isShowingAIE
                          ? SizedBox(
                              height: isShowingAIE
                                  ? _keyboardMaxHeight
                                  : keyboard.keyboardHeight,
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
                            if (subToolbar == SubToolbar.at ||
                                subToolbar == SubToolbar.image ||
                                subToolbar == SubToolbar.emoji) {
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
                            ? _buildAtPicker()
                            : SizedBox.shrink(),
                        _showingSubToolbar == SubToolbar.image
                            ? _buildImagePicker()
                            : SizedBox.shrink(),
                        _showingSubToolbar == SubToolbar.emoji
                            ? _buildbEmojiPicker()
                            : SizedBox.shrink(),
                        keyboard.isOpen &&
                                _showingSubToolbar != SubToolbar.at &&
                                _showingSubToolbar != SubToolbar.image &&
                                _showingSubToolbar != SubToolbar.emoji
                            ? SizedBox(
                                height: keyboard.keyboardHeight,
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dialogEditorController.dispose();

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
                _controller.insertMention('$index', '@个GV不@~、😃😄',
                    replaceLength: 1, appendSpace: true);
              } else {
                _controller.insertMention(
                  '$index',
                  '#*Topic*',
                  prefixChar: '#',
                  ignoreFocus: true,
                );
              }
            },
          );
        },
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
      debugPrint('delta item $i');
    }

    _controller = TunEditorController(
      document: doc,
      selection: TextSelection.collapsed(offset: 2),
    );
    _controller.document.changes.listen((event) {
      // final delta1 = json.encode(event.item1.toJson());
      final delta2 = jsonEncode(event.item2.toJson());
      debugPrint('event:  $delta2');

      final doc = jsonEncode(_controller.document.toDelta().toJson());
      debugPrint('document: $doc');

      setState(() {
        final encoder = JsonEncoder.withIndent('  ');
        _previewText = encoder.convert(_controller.document.toDelta().toJson());
      });
    });
    _controller.addSelectionListener((selection) {
      debugPrint(
          'selection changed ${selection.baseOffset} ${selection.extentOffset}');
      if (_showingSubToolbar == SubToolbar.at ||
          _showingSubToolbar == SubToolbar.image) {
        setState(() {
          _showingSubToolbar = SubToolbar.none;
        });
      }
    });

    _dialogEditorController = TunEditorController(
      document: Document(),
      selection: TextSelection.collapsed(offset: 0),
    );

    if (Platform.isIOS) {
      final appDocPath = await getApplicationDocumentsDirectory();
      final tempPath = path.join(appDocPath.parent.path, 'tmp');
      _fileBasePath = tempPath;
    } else {
      final tempPath = await getTemporaryDirectory();
      _fileBasePath = tempPath.path;
    }
    setState(() {
      final encoder = JsonEncoder.withIndent('  ');
      _previewText = encoder.convert(_controller.document.toDelta().toJson());
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    // _controller.batchInsertEmbed(
    //   appendNewLineAfterImage: true,
    //   appendNewLineAfterVideo: false,
    //   appendNewLine: false,
    //   embeds: [
    //     ImageEmbed(
    //       name: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //       source: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //       checkPath: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //       width: 230,
    //       height: 230,
    //     ),
    //     VideoEmbed(
    //       source: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
    //       duration: 100,
    //       thumbUrl: 'https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png',
    //       thumbName: 'https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png',
    //       fileType: 'mp4',
    //       width: 100,
    //       height: 200,
    //     ),
    //     // ImageEmbed(
    //     //   name: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //     //   source: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //     //   checkPath: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //     //   width: 230,
    //     //   height: 230,
    //     // ),
    //     // VideoEmbed(
    //     //   source: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
    //     //   duration: 100,
    //     //   thumbUrl: 'https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png',
    //     //   thumbName: 'https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png',
    //     //   fileType: 'mp4',
    //     //   width: 100,
    //     //   height: 200,
    //     // ),
    //     // ImageEmbed(
    //     //   name: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //     //   source: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //     //   checkPath: "https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png",
    //     //   width: 230,
    //     //   height: 230,
    //     // ),
    //     // MentionEmbed(
    //     //   denotationChar: '',
    //     //   id: '1',
    //     //   value: '#test',
    //     //   prefixChar: '#',
    //     // ),
    //   ],
    // );
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _controller.insertImage(
        name: image.name,
        // source: 'file://${image.name}',
        source: image.name,
        checkPath: image.name,
        width: 230,
        height: 230,
        ignoreFocus: false,
        appendNewLine: false,
      );
      // _controller.insertVideo(
      //   source:
      //       'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
      //   duration: 100,
      //   thumbUrl: 'file://${image.name}',
      //   thumbName: image.name,
      //   fileType: 'mp4',
      //   width: 100,
      //   height: 200,
      //   ignoreFocus: false,
      //   appendNewLine: true
      // );
    }
  }

  Future<void> _showEditorDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 8),
              Text(
                'Dialog Editor',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 8),
              Expanded(
                child: TunEditor(
                  controller: _dialogEditorController,
                  fileBasePath: _fileBasePath,
                  placeholder: 'placeholder on dialog editor',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
