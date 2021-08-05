import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tun_editor/iconfont.dart';
import 'package:tun_editor/controller.dart';
import 'package:tun_editor/models/documents/attribute.dart';

class TunEditorToolbar extends StatefulWidget {

  final TunEditorController controller;

  final bool showingAt;
  final bool showingImage;
  final bool showingEmoji;
  final ValueChanged<bool>? onAtChange;
  final ValueChanged<bool>? onImageChange;
  final ValueChanged<bool>? onEmojiChange;

  final VoidCallback? onSend;

  const TunEditorToolbar({
    Key? key,
    required this.controller,
    this.showingAt = false,
    this.showingImage = false,
    this.showingEmoji = false,
    this.onAtChange,
    this.onImageChange,
    this.onEmojiChange,
    this.onSend,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TunEditorToolbarState();

}

class TunEditorToolbarState extends State<TunEditorToolbar> {

  static const String FORMAT_TEXT_TYPE_NORMAL = "normal";

  TunEditorController get controller => widget.controller;
  bool get showingAt => widget.showingAt;
  bool get showingImage => widget.showingImage;
  bool get showingEmoji => widget.showingEmoji;
  ValueChanged<bool>? get onAtChange => widget.onAtChange;
  ValueChanged<bool>? get onImageChange => widget.onImageChange;
  ValueChanged<bool>? get onEmojiChange => widget.onEmojiChange;
  VoidCallback? get onSend => widget.onSend;

  // Sub toolbar.
  SubToolbar showingSubToolbar = SubToolbar.none;

  // Text type and style.
  String currentTextType = FORMAT_TEXT_TYPE_NORMAL;
  List<String> currentTextStyleList = [];

  // Link related.
  bool get isSelectNonLinkText => !controller.selection.isCollapsed
      && !currentTextStyleList.contains(Attribute.link.uniqueKey);
  late TextEditingController textCtrl;
  late TextEditingController urlCtrl;

  bool isCanSend = false;

  @override
  void initState() {
    super.initState();
  
    textCtrl = TextEditingController();
    urlCtrl = TextEditingController();
    controller.addFormatListener(syncFormat);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSubToolbar(),
          showingSubToolbar == SubToolbar.textType
            || showingSubToolbar == SubToolbar.textStyle ? SizedBox(height: 4) : SizedBox.shrink(),
          Divider(height: 1, thickness: 1, color: Color(0x148F959E)),
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

  // Main toolbar.
  Widget buildMainToolbar() {
    return Container(
      width: double.infinity,
      height: 48,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Row(
        children: [
          buildButton(
            IconFont.at,
            () => toggleSubToolbar(SubToolbar.at),
            false,
          ),
          SizedBox(width: 8),
          buildButton(
            IconFont.image,
            () => toggleSubToolbar(SubToolbar.image),
            false,
          ),
          SizedBox(width: 8),
          buildButton(
            IconFont.emoji,
            () => toggleSubToolbar(SubToolbar.emoji),
            false,
          ),
          SizedBox(width: 8),
          buildButton(
            IconFont.textType,
            () => toggleSubToolbar(SubToolbar.textType),
            showingSubToolbar == SubToolbar.textType,
          ),
          SizedBox(width: 8),
          buildButton(
            IconFont.textStyle,
            () => toggleSubToolbar(SubToolbar.textStyle),
            showingSubToolbar == SubToolbar.textStyle,
          ),
          SizedBox(width: 8),
          buildButton(
            IconFont.link,
            () => toggleSubToolbar(SubToolbar.link),
            showingSubToolbar == SubToolbar.link,
          ),
          Spacer(),
          // Send button.
          GestureDetector(
            onTap: onSendClick,
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
                color: isCanSend ? Color(0xFF5562F2) : Color(0xA6363940),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sub toolbar.
  Widget buildSubToolbar() {
    switch (showingSubToolbar) {
      case SubToolbar.textType:
        return buildTextTypeToolbar();
      case SubToolbar.textStyle:
        return buildTextStyleToolbar();
      case SubToolbar.link:
        return buildLinkToolbar();
      default: 
        return SizedBox.shrink();
    }
  }

  // Text type sub toolbar.
  Widget buildTextTypeToolbar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 1,
            color: Color(0x198F959E),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5),
              blurRadius: 20,
              color: Color(0x0C646A73),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 10),
            buildOutlineButton(
              IconFont.headline1,
              () => toggleTextType(Attribute.h1.uniqueKey),
              currentTextType == Attribute.h1.uniqueKey,
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.headline2,
              () => toggleTextType(Attribute.h2.uniqueKey),
              currentTextType == Attribute.h2.uniqueKey,
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.headline3,
              () => toggleTextType(Attribute.h3.uniqueKey),
              currentTextType == Attribute.h3.uniqueKey,
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.listBullet,
              () => toggleTextType(Attribute.ul.uniqueKey),
              currentTextType == Attribute.ul.uniqueKey,
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.listOrdered,
              () => toggleTextType(Attribute.ol.uniqueKey),
              currentTextType == Attribute.ol.uniqueKey,
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.divider,
              onDividerClick,
              false,
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.quote,
              () => toggleTextType(Attribute.blockQuote.uniqueKey),
              currentTextType == Attribute.blockQuote.uniqueKey,
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.codeBlock,
              () => toggleTextType(Attribute.codeBlock.uniqueKey),
              currentTextType == Attribute.codeBlock.uniqueKey,
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  // Text style sub toolbar.
  Widget buildTextStyleToolbar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 1,
            color: Color(0x198F959E),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5),
              blurRadius: 20,
              color: Color(0x0C646A73),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 10),
            buildOutlineButton(
              IconFont.bold,
              () => toggleTextStyle(Attribute.bold.uniqueKey),
              currentTextStyleList.contains(Attribute.bold.uniqueKey),
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.italic,
              () => toggleTextStyle(Attribute.italic.uniqueKey),
              currentTextStyleList.contains(Attribute.italic.uniqueKey),
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.underline,
              () => toggleTextStyle(Attribute.underline.uniqueKey),
              currentTextStyleList.contains(Attribute.underline.uniqueKey),
            ),
            SizedBox(width: 8),
            buildOutlineButton(
              IconFont.strikeThrough,
              () => toggleTextStyle(Attribute.strikeThrough.uniqueKey),
              currentTextStyleList.contains(Attribute.strikeThrough.uniqueKey),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  // Link sub toolbar.
  Widget buildLinkToolbar() {
    final labelStyle = TextStyle(
      color: Color(0xFF363940),
      fontWeight: FontWeight.w500,
      fontSize: 16,
    );
    final hintStyle = TextStyle(
      color: Color(0xFF8F959E),
      fontSize: 16,
      height: 1.25,
    );
    final fieldStyle = TextStyle(
      color: Color(0xFF363940),
      fontSize: 16,
      height: 1.25,
    );
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Color(0x1A8F959E),
      hintStyle: hintStyle,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(
          color: Color(0xFFE3E4E7),
          width: 1,
        )),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          // Link text.
          isSelectNonLinkText ? SizedBox.shrink() : Row(
            children: [
              SizedBox(width: 12),
              Text(
                "文本",
                style: labelStyle,
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 230,
                height: 40,
                child: TextField(
                  style: fieldStyle,
                  cursorColor: Color(0xFF5562F2),
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration.copyWith(
                    hintText: "输入文本",
                  ),
                  controller: textCtrl,
                ),
              ),
            ],
          ),
          isSelectNonLinkText ? SizedBox.shrink() : SizedBox(height: 10),
          // Link value.
          Row(
            children: [
              SizedBox(width: 12),
              Text(
                "链接",
                style: labelStyle,
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 230,
                height: 40,
                child: TextField(
                  style: fieldStyle,
                  cursorColor: Color(0xFF5562F2),
                  decoration: inputDecoration.copyWith(
                    hintText: "粘贴或输入一个链接",
                  ),
                  controller: urlCtrl,
                  onSubmitted: (_) => onLinkSubmit(),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 65,
                height: 40,
                child: OutlinedButton(
                  onPressed: onLinkSubmit,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Color(0xFF5562F2)),
                    side: MaterialStateProperty.all(BorderSide.none),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                   ),
                  child: Text("确定"),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
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
          color: isActive ? Color(0x268F959E) : Colors.transparent,
          borderRadius: isActive ? BorderRadius.circular(3) : BorderRadius.zero,
        ),
        child: Icon(iconData, size: 24, color: Color(0xFF363940)),
      ),
    );
  }

  Widget buildOutlineButton(IconData iconData, VoidCallback onPressed, bool isActive) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        child: Icon(
          iconData,
          size: 24,
          color: isActive ? Color(0xFF5562F2) : Color(0xFF363940),
        ),
      ),
    );
  }

  void onSendClick() {
    setState(() {});
  }

  void onDividerClick() {
    // Disable insert divider if in code block.
    if (currentTextType == Attribute.codeBlock.uniqueKey) {
      return;
    }
    controller.insertDivider();
  }

  void onLinkSubmit() {
    if (isSelectNonLinkText) {
      // Format link.
      if (urlCtrl.text.isEmpty) {
        return;
      }
      controller.format(Attribute.link.key, urlCtrl.text);
      // Clear text field and hide sub toolbar.
      textCtrl.text = '';
      urlCtrl.text = '';
      toggleSubToolbar(SubToolbar.link);
    } else {
      // Insert text with link format.
      if (textCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
        return;
      }
      controller.insertLink(textCtrl.text, urlCtrl.text);
      // Clear text field and hide sub toolbar.
      textCtrl.text = '';
      urlCtrl.text = '';
      toggleSubToolbar(SubToolbar.link);
    }
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

  void toggleSubToolbar(SubToolbar subToolbar) {
    if (showingSubToolbar == subToolbar) {
      showingSubToolbar = SubToolbar.none;
    } else {
      showingSubToolbar = subToolbar;
    }
    setState(() {});

    // Check if the value of at, image and emoji have changed.
    final showingAtNew = showingSubToolbar == SubToolbar.at;
    final showingImageNew = showingSubToolbar == SubToolbar.image;
    final showingEmojiNew = showingSubToolbar == SubToolbar.emoji;
    if (showingAtNew != showingAt) {
      onAtChange?.call(showingAtNew);
    }
    if (showingImageNew != showingImage) {
      onImageChange?.call(showingImageNew);
    }
    if (showingEmojiNew != showingEmoji) {
      onEmojiChange?.call(showingEmojiNew);
    }
  }

  void syncFormat(Map<String, dynamic> format) {
    debugPrint('sync format: ${controller.selection.baseOffset} - ${controller.selection.extentOffset} - $format');
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
    if (format.containsKey(Attribute.link.key)) {
      currentTextStyleList.add(Attribute.link.uniqueKey);
    }
    setState(() {});
  }

}

enum SubToolbar {
  none,
  at,
  image,
  emoji,
  textType,
  textStyle,
  link,
}
