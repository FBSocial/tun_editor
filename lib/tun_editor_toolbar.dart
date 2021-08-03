import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tun_editor/iconfont.dart';
import 'package:tun_editor/controller.dart';
import 'package:tun_editor/models/documents/attribute.dart';

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

  static const String FORMAT_TEXT_TYPE_NORMAL = "normal";

  bool isShowTextType = false;
  bool isShowTextStyle = false;

  String currentTextType = FORMAT_TEXT_TYPE_NORMAL;
  List<String> currentTextStyleList = [];

  TunEditorController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
  
    controller.addFormatListener(syncFormat);
  }

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

  @override
  void dispose() {
    controller.removeFormatListener(syncFormat);
  
    super.dispose();
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
          buildButton(
            IconFont.headline1,
            () => toggleTextType(Attribute.h1.uniqueKey),
            currentTextType == Attribute.h1.uniqueKey,
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.headline2,
            () => toggleTextType(Attribute.h2.uniqueKey),
            currentTextType == Attribute.h2.uniqueKey,
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.headline3,
            () => toggleTextType(Attribute.h3.uniqueKey),
            currentTextType == Attribute.h3.uniqueKey,
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.listBullet,
            () => toggleTextType(Attribute.ul.uniqueKey),
            currentTextType == Attribute.ul.uniqueKey,
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.listOrdered,
            () => toggleTextType(Attribute.ol.uniqueKey),
            currentTextType == Attribute.ol.uniqueKey,
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.divider,
            insertDivider,
            false,
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.quote,
            () => toggleTextType(Attribute.blockQuote.uniqueKey),
            currentTextType == Attribute.blockQuote.uniqueKey,
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.codeBlock,
            () => toggleTextType(Attribute.codeBlock.uniqueKey),
            currentTextType == Attribute.codeBlock.uniqueKey,
          ),
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
          buildButton(
            IconFont.bold,
            () => toggleTextStyle(Attribute.bold.uniqueKey),
            currentTextStyleList.contains(Attribute.bold.uniqueKey),
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.italic,
            () => toggleTextStyle(Attribute.italic.uniqueKey),
            currentTextStyleList.contains(Attribute.italic.uniqueKey),
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.underline,
            () => toggleTextStyle(Attribute.underline.uniqueKey),
            currentTextStyleList.contains(Attribute.underline.uniqueKey),
          ),
          SizedBox(width: 4),
          buildButton(
            IconFont.strikeThrough,
            () => toggleTextStyle(Attribute.strikeThrough.uniqueKey),
            currentTextStyleList.contains(Attribute.strikeThrough.uniqueKey),
          ),
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
      currentTextType = FORMAT_TEXT_TYPE_NORMAL;
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

  void syncFormat(Map<String, dynamic> format) {
    debugPrint('sync format: $format');
    // Check text type.
    if (format.containsKey(Attribute.header.key)) {
      final level = format[Attribute.header.key] as int?;
      switch (level) {
        case 1:
          currentTextType = Attribute.h1.uniqueKey;
          break;
        case 2:
          currentTextType = Attribute.h2.uniqueKey;
          break;
        case 3:
          currentTextType = Attribute.h3.uniqueKey;
          break;
      }
    } else if (format.containsKey(Attribute.list.key)) {
      final listType = format[Attribute.list.key] as String?;
      final ulValue = Attribute.ul.value as String;
      final olValue = Attribute.ol.value as String;
      if (listType == ulValue) {
        currentTextType = Attribute.ul.uniqueKey;
      } else if (listType == olValue) {
        currentTextType = Attribute.ol.uniqueKey;
      }
    } else if (format.containsKey(Attribute.blockQuote.key)) {
      currentTextType = Attribute.blockQuote.uniqueKey;
    } else if (format.containsKey(Attribute.codeBlock.key)) {
      currentTextType = Attribute.codeBlock.uniqueKey;
    } else {
      currentTextType = FORMAT_TEXT_TYPE_NORMAL;
    }

    // Check text style.
    currentTextStyleList.clear();
    if (format.containsKey(Attribute.bold.key)) {
      currentTextStyleList.add(Attribute.bold.uniqueKey);
    }
    if (format.containsKey(Attribute.italic.key)) {
      currentTextStyleList.add(Attribute.italic.uniqueKey);
    }
    if (format.containsKey(Attribute.underline.key)) {
      currentTextStyleList.add(Attribute.underline.uniqueKey);
    }
    if (format.containsKey(Attribute.strikeThrough.key)) {
      currentTextStyleList.add(Attribute.strikeThrough.uniqueKey);
    }
    setState(() {});
  }

}
