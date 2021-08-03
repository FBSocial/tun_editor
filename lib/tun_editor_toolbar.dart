import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tun_editor/iconfont.dart';
import 'package:tun_editor/controller.dart';

class TunEditorToolbar extends StatefulWidget {

  final TunEditorController controller;

  final VoidCallback? onAtClick;
  final VoidCallback? onImageClick;
  final VoidCallback? onEmojiClick;

  const TunEditorToolbar({
    Key? key,
    required this.controller,
    this.onAtClick,
    this.onImageClick,
    this.onEmojiClick,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TunEditorToolbarState();

}

class TunEditorToolbarState extends State<TunEditorToolbar> {

  bool isShowTextType = false;
  bool isShowTextStyle = false;

  String currentTextType = "normal";
  List<String> currentTextStyleList = [];

  TunEditorController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: isShowTextType || isShowTextStyle ? 100 : 48,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isShowTextType ? buildTextTypeToolbar() : SizedBox.shrink(),
          isShowTextStyle ? buildTextStyleToolbar() : SizedBox.shrink(),
          isShowTextType || isShowTextStyle ? SizedBox(height: 4) : SizedBox.shrink(),
          buildMainToolbar(),
        ],
      ),
    );
  }

  Widget buildTextTypeToolbar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          color: Color(0xFFF2F2F2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 4),
          buildButton(IconFont.headline1, () => toggleTextType('header1'), currentTextType == "header1"),
          SizedBox(width: 4),
          buildButton(IconFont.headline2, () => toggleTextType('header2'), currentTextType == 'header2'),
          SizedBox(width: 4),
          buildButton(IconFont.headline3, () => toggleTextType('header3'), currentTextType == "header3"),
          SizedBox(width: 4),
          buildButton(IconFont.listBullet, () => toggleTextType('list-bullet'), currentTextType == "list-bullet"),
          SizedBox(width: 4),
          buildButton(IconFont.listOrdered, () => toggleTextType('list-ordered'), currentTextType == "list-ordered"),
          SizedBox(width: 4),
          buildButton(IconFont.divider, insertDivider, false),
          SizedBox(width: 4),
          buildButton(IconFont.quote, () => toggleTextType('blockquote'), currentTextType == "blockquote"),
          SizedBox(width: 4),
          buildButton(IconFont.codeBlock, () => toggleTextType('code-block'), currentTextType == "code-block"),
          SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget buildTextStyleToolbar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          color: Color(0xFFF2F2F2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 4),
          buildButton(IconFont.bold, () => toggleTextStyle('bold'), currentTextStyleList.contains('bold')),
          SizedBox(width: 4),
          buildButton(IconFont.italic, () => toggleTextStyle('italic'), currentTextStyleList.contains('italic')),
          SizedBox(width: 4),
          buildButton(IconFont.underline, () => toggleTextStyle('underline'), currentTextStyleList.contains('underline')),
          SizedBox(width: 4),
          buildButton(IconFont.strikeThrough, () => toggleTextStyle('strike'), currentTextStyleList.contains('strike')),
          SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget buildMainToolbar() {
    return Container(
      width: double.infinity,
      height: 48,
      child: Row(
        children: [
          buildButton(IconFont.at, onAtClick, false),
          SizedBox(width: 4),
          buildButton(IconFont.image, onImageClick, false),
          SizedBox(width: 4),
          buildButton(IconFont.emoji, onEmojiClick, false),
          SizedBox(width: 4),
          buildButton(IconFont.textType, toggleTextTypeView, isShowTextType),
          SizedBox(width: 4),
          buildButton(IconFont.textStyle, toggleTextStyleView, isShowTextStyle),
          Spacer(),
          GestureDetector(
            onTap: onSendClick,
            child: Container(
              width: 50,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFFEEEFF0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(IconFont.send, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(IconData iconData, VoidCallback onPressed, bool isActive) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? Color(0xFFEEEFF0) : Colors.transparent,
          borderRadius: isActive ? BorderRadius.circular(4) : BorderRadius.zero,
        ),
        child: Icon(iconData, size: 24, color: Color(0xFF333333)),
      ),
    );
  }

  void onAtClick() {
    setState(() {
      isShowTextType = false;
      isShowTextStyle = false;
    });
    widget.onAtClick?.call();
  }

  void onImageClick() {
    setState(() {
      isShowTextType = false;
      isShowTextStyle = false;
    });
    widget.onImageClick?.call();
  }

  void onEmojiClick() {
    setState(() {
      isShowTextType = false;
      isShowTextStyle = false;
    });
    widget.onEmojiClick?.call();
  }

  void onSendClick() {
    setState(() {});
  }

  void insertDivider() {
    controller.insertDivider();
  }

  void toggleTextType(String textType) {
    if (currentTextType == textType) {
      currentTextType = "normal";
    } else {
      currentTextType = textType;
    }
    setState(() {});
    controller.setTextType(currentTextType);
  }

  void toggleTextStyle(String textStyle) {
    if (currentTextStyleList.contains(textStyle)) {
      currentTextStyleList.remove(textStyle);
    } else {
      currentTextStyleList.add(textStyle);
    }
    setState(() {});
    controller.setTextStyle(currentTextStyleList);
  }

  void toggleTextTypeView() {
    setState(() {
      isShowTextType = !isShowTextType;
      isShowTextStyle = false;
    });
  }

  void toggleTextStyleView() {
    setState(() {
      isShowTextStyle = !isShowTextStyle;
      isShowTextType = false;
    });
  }

}
