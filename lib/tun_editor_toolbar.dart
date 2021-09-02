import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tun_editor/iconfont.dart';
import 'package:tun_editor/controller.dart';
import 'package:tun_editor/link_format_dialog.dart';
// import 'package:tun_editor/models/documents/attribute.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TunEditorToolbar extends StatefulWidget {

  final TunEditorController controller;

  // Sub toolbar panel showing status.
  final SubToolbar showingSubToolbar;
  final ValueChanged<SubToolbar>? onSubToolbarChange;

  // Menu decides which tool should be showed in toolbar.
  final List<ToolbarMenu> menu;

  // Disabled menu.
  final List<ToolbarMenu>? disabledMenu;
  final ValueChanged<List<ToolbarMenu>>? onDisabledMenuChange;

  // Children is the custom tool menu.
  final List<Widget>? children;

  const TunEditorToolbar({
    Key? key,
    required this.controller,
    this.showingSubToolbar = SubToolbar.none,
    this.onSubToolbarChange,
    this.menu = ToolbarMenu.values,
    this.disabledMenu,
    this.onDisabledMenuChange,
    this.children,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TunEditorToolbarState();

}

class TunEditorToolbarState extends State<TunEditorToolbar> {

  static const String FORMAT_TEXT_TYPE_NORMAL = "normal";

  TunEditorController get controller => widget.controller;
  SubToolbar get showingSubToolbar => widget.showingSubToolbar;
  ValueChanged<SubToolbar>? get onSubToolbarChange => widget.onSubToolbarChange;

  List<ToolbarMenu> get menu => widget.menu;

  List<ToolbarMenu> get disabledMenu => widget.disabledMenu ?? [];
  ValueChanged<List<ToolbarMenu>>? get onDisabledMenuChange => widget.onDisabledMenuChange;

  List<Widget>? get children => widget.children;

  // Text type and style.
  String currentTextType = FORMAT_TEXT_TYPE_NORMAL;
  List<String> currentTextStyleList = [];

  bool isCanSend = false;

  @override
  void initState() {
    super.initState();

    controller.addFormatListener(syncFormat);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height),
      designSize: Size(375, 812),
      orientation: Orientation.portrait,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSubToolbar(),
          showingSubToolbar == SubToolbar.textType
            || showingSubToolbar == SubToolbar.textStyle ? SizedBox(height: 4) : SizedBox.shrink(),
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
    final List<Widget> menuList = [];
    if (menu.contains(ToolbarMenu.at)) {
      menuList.addAll([
        buildButton(
          IconFont.at,
          () => toggleSubToolbar(SubToolbar.at),
          false,
          disabledMenu.contains(ToolbarMenu.at),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.image)) {
      menuList.addAll([
        buildButton(
          IconFont.image,
          () => toggleSubToolbar(SubToolbar.image),
          false,
          disabledMenu.contains(ToolbarMenu.image),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.emoji)) {
      menuList.addAll([
        buildButton(
          IconFont.emoji,
          () => toggleSubToolbar(SubToolbar.emoji),
          false,
          disabledMenu.contains(ToolbarMenu.emoji),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textType)) {
      menuList.addAll([
        buildButton(
          IconFont.textType,
          () => toggleSubToolbar(SubToolbar.textType),
          showingSubToolbar == SubToolbar.textType,
          disabledMenu.contains(ToolbarMenu.textType),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textStyle)) {
      menuList.addAll([
        buildButton(
          IconFont.textStyle,
          () => toggleSubToolbar(SubToolbar.textStyle),
          showingSubToolbar == SubToolbar.textStyle,
          disabledMenu.contains(ToolbarMenu.textStyle),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.link)) {
      menuList.addAll([
        buildOutlineButton(
          IconFont.link,
          () => onLinkFormatClick(),
          currentTextStyleList.contains(Attribute.link.uniqueKey),
          disabledMenu.contains(ToolbarMenu.link),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menuList.isNotEmpty) {
      // Remove last sized box.
      menuList.removeLast();
    }
    if (children == null) {
      menuList.add(Spacer());
    } else {
      menuList.addAll(children!);
    }
    return Container(
      width: double.infinity,
      height: 48,
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: menuList,
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
      default: 
        return SizedBox.shrink();
    }
  }

  // Text type sub toolbar.
  Widget buildTextTypeToolbar() {
    final List<Widget> textTypeMenuList = [];
    if (menu.contains(ToolbarMenu.textTypeHeadline1)) {
      textTypeMenuList.addAll([
        buildOutlineButton(
          IconFont.headline1,
          () => toggleTextType(Attribute.h1.uniqueKey),
          currentTextType == Attribute.h1.uniqueKey,
          disabledMenu.contains(ToolbarMenu.textTypeHeadline1),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textTypeHeadline2)) {
      textTypeMenuList.addAll([
        buildOutlineButton(
          IconFont.headline2,
          () => toggleTextType(Attribute.h2.uniqueKey),
          currentTextType == Attribute.h2.uniqueKey,
          disabledMenu.contains(ToolbarMenu.textTypeHeadline2),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textTypeHeadline3)) {
      textTypeMenuList.addAll([
        buildOutlineButton(
          IconFont.headline3,
          () => toggleTextType(Attribute.h3.uniqueKey),
          currentTextType == Attribute.h3.uniqueKey,
          disabledMenu.contains(ToolbarMenu.textTypeHeadline3),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textTypeListBullet)) {
      textTypeMenuList.addAll([
        buildOutlineButton(
          IconFont.listBullet,
          () => toggleTextType(Attribute.ul.uniqueKey),
          currentTextType == Attribute.ul.uniqueKey,
          disabledMenu.contains(ToolbarMenu.textTypeListBullet),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textTypeListOrdered)) {
      textTypeMenuList.addAll([
        buildOutlineButton(
          IconFont.listOrdered,
          () => toggleTextType(Attribute.ol.uniqueKey),
          currentTextType == Attribute.ol.uniqueKey,
          disabledMenu.contains(ToolbarMenu.textTypeListOrdered),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textTypeDivider)) {
      textTypeMenuList.addAll([
        buildOutlineButton(
          IconFont.divider,
          onDividerClick,
          false,
          disabledMenu.contains(ToolbarMenu.textTypeDivider),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textTypeQuote)) {
      textTypeMenuList.addAll([
        buildOutlineButton(
          IconFont.quote,
          () => toggleTextType(Attribute.blockQuote.uniqueKey),
          currentTextType == Attribute.blockQuote.uniqueKey,
          disabledMenu.contains(ToolbarMenu.textTypeQuote),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textTypeCodeBlock)) {
      textTypeMenuList.addAll([
        buildOutlineButton(
          IconFont.codeBlock,
          () => toggleTextType(Attribute.codeBlock.uniqueKey),
          currentTextType == Attribute.codeBlock.uniqueKey,
          disabledMenu.contains(ToolbarMenu.textTypeCodeBlock),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (textTypeMenuList.isNotEmpty) {
      textTypeMenuList.removeLast();
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
      ),
      child: Container(
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            width: 1.w,
            color: Color(0x198F959E),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5.w),
              blurRadius: 20.w,
              color: Color(0x0C646A73),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 10.w),
            ...textTypeMenuList,
            SizedBox(width: 10.w),
          ],
        ),
      ),
    );
  }

  // Text style sub toolbar.
  Widget buildTextStyleToolbar() {
    final List<Widget> textStyleMenuList = [];
    if (menu.contains(ToolbarMenu.textStyleBold)) {
      textStyleMenuList.addAll([
        buildOutlineButton(
          IconFont.bold,
          () => toggleTextStyle(Attribute.bold.uniqueKey),
          currentTextStyleList.contains(Attribute.bold.uniqueKey),
          disabledMenu.contains(ToolbarMenu.textStyleBold),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textStyleItalic)) {
      textStyleMenuList.addAll([
        buildOutlineButton(
          IconFont.italic,
          () => toggleTextStyle(Attribute.italic.uniqueKey),
          currentTextStyleList.contains(Attribute.italic.uniqueKey),
          disabledMenu.contains(ToolbarMenu.textStyleItalic),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textStyleUnderline)) {
      textStyleMenuList.addAll([
        buildOutlineButton(
          IconFont.underline,
          () => toggleTextStyle(Attribute.underline.uniqueKey),
          currentTextStyleList.contains(Attribute.underline.uniqueKey),
          disabledMenu.contains(ToolbarMenu.textStyleUnderline),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (menu.contains(ToolbarMenu.textStyleStrikeThrough)) {
      textStyleMenuList.addAll([
        buildOutlineButton(
          IconFont.strikeThrough,
          () => toggleTextStyle(Attribute.strikeThrough.uniqueKey),
          currentTextStyleList.contains(Attribute.strikeThrough.uniqueKey),
          disabledMenu.contains(ToolbarMenu.textStyleStrikeThrough),
        ),
        SizedBox(width: 8.w),
      ]);
    }
    if (textStyleMenuList.isNotEmpty) {
      textStyleMenuList.removeLast();
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
      ),
      child: Container(
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            width: 1.w,
            color: Color(0x198F959E),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5.w),
              blurRadius: 20.w,
              color: Color(0x0C646A73),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 10.w),
            ...textStyleMenuList,
            SizedBox(width: 10.w),
          ],
        ),
      ),
    );
  }

  Widget buildButton(IconData iconData, VoidCallback onPressed, bool isActive, bool isDisabled) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: !isDisabled && isActive ? Color(0x268F959E) : Colors.transparent,
          borderRadius: !isDisabled && isActive ? BorderRadius.circular(3.w) : BorderRadius.zero,
        ),
        child: Icon(
          iconData,
          size: 24.w,
          color: isDisabled ? Color(0x80363940) : Color(0xFF363940),
        ),
      ),
    );
  }

  Widget buildOutlineButton(IconData iconData, VoidCallback onPressed, bool isActive, bool isDisabled) {
    Color color = Color(0xFF363940);
    if (isDisabled) {
      color = Color(0x80363940);
    } else if (isActive) {
      color = Color(0xFF5562F2);
    }
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: 36.w,
        height: 36.w,
        child: Icon(
          iconData,
          size: 24.w,
          color: color,
        ),
      ),
    );
  }

  void onDividerClick() {
    controller.insertDivider();
  }

  void toggleTextType(String textType) {
    if (currentTextType == textType) {
      final lastTextType = currentTextType;
      currentTextType = FORMAT_TEXT_TYPE_NORMAL;

      setState(() {});
      if (lastTextType.startsWith(Attribute.header.key)) {
        controller.format(Attribute.header.key, false);
      } else if (lastTextType.startsWith(Attribute.list.key)) {
        controller.format(Attribute.list.key, false);
      } {
        controller.format(lastTextType, false);
      }
      return;
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
      onSubToolbarChange?.call(SubToolbar.none);
    } else {
      onSubToolbarChange?.call(subToolbar);
    }
  }

  Future<void> onLinkFormatClick() async {
    final selection = controller.selection;
    int baseOffset = selection.baseOffset;
    int extentOffset = selection.extentOffset;
    if (baseOffset > extentOffset) {
      baseOffset = selection.extentOffset;
      extentOffset = selection.baseOffset;
    }

    // Remove link format if has link format.
    final hasLinkFormat = currentTextStyleList.contains(Attribute.link.key);
    if (hasLinkFormat) {
      final range = _getLinkNode(selection);
      if (range == null) {
        return;
      }
      controller.formatText(
        range.baseOffset,
        range.extentOffset - range.baseOffset,
        Attribute('link', AttributeScope.INLINE, false),
      );
      return;
    }

    String defaultText = '';
    String defaultUrl = '';
    int textStartIndex = -1;
    int textEndIndex = -1;
    if (!selection.isCollapsed) {
      textStartIndex = selection.baseOffset;
      textEndIndex = selection.extentOffset;
      defaultText = controller.document.toPlainText().substring(textStartIndex, textEndIndex);
    }

    final res = await LinkFomratDialog.show(
      context,
      defaultText: defaultText.replaceAll('\n', ' '),
      defaultUrl: defaultUrl,
      isUrlAutofocus: !selection.isCollapsed,
    );
    if (res != null && res.length >= 2) {
      final text = res[0];
      final url = res[1];

      if (selection.isCollapsed) {
        // Insert new link.
        controller.insertLink(text, url);
      } else {
        // Remove link format.
        controller.formatText(
          textStartIndex,
          textEndIndex - textStartIndex,
          Attribute('link', AttributeScope.INLINE, false),
        );
        // Replace text.
        controller.replaceText(
          textStartIndex,
          textEndIndex - textStartIndex,
          text,
          TextSelection.collapsed(
            offset: textStartIndex + text.length,
          ),
        );
        // Format text with link.
        controller.formatText(
          textStartIndex,
          text.length,
          LinkAttribute(url),
        );
      }
    }
    Future.delayed(Duration(milliseconds: 200), () => controller.focus());
  }

  // Sync toolbar' status with format.
  void syncFormat(Map<String, dynamic> format) {
    // Check text type.
    if (format.containsKey(Attribute.header.key)) {
      if (format[Attribute.header.key] is int) {
        final level = format[Attribute.header.key] as int;
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

    // Disable text style.
    disabledMenu.clear();
    if (currentTextType == Attribute.codeBlock.uniqueKey) {
      disabledMenu.addAll([
        ToolbarMenu.at,
        ToolbarMenu.image,
        ToolbarMenu.textStyleBold,
        ToolbarMenu.textStyleItalic,
        ToolbarMenu.textStyleUnderline,
        ToolbarMenu.textStyleStrikeThrough,
        ToolbarMenu.link,
      ]);
    }
    setState(() {});
  }

  TextSelection? _getLinkNode(TextSelection cursorSelection) {
    // Get selected node's attribute.
    final child = controller.document.queryChild(cursorSelection.baseOffset);

    // Document offset.
    final documentOffset = child.node?.documentOffset ?? 0; 

    // Line offset.
    final cursorLineOffset = child.offset;
    final cursorLineExtentOffset = child.offset + (cursorSelection.extentOffset - cursorSelection.baseOffset);

    int opLineOffset = 0;
    final deltaList = child.node?.toDelta().toList() ?? [];
    for (final op in deltaList) {
      // If has link attribute.
      final opLength = op.length ?? 0;
      final opLineExtentOffset = opLineOffset + opLength;
      if (opLineOffset <= cursorLineOffset && opLineExtentOffset >= cursorLineExtentOffset
          && op.attributes?.keys.contains(Attribute.link.key) == true
          && op.attributes?[Attribute.link.key] is String
          && op.value is String) {
        return TextSelection(baseOffset: documentOffset + opLineOffset, extentOffset: documentOffset + opLineExtentOffset);
      }
      opLineOffset = opLineOffset + opLength;
    }
    return null;
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

enum ToolbarMenu {
  at,
  image,
  emoji,

  // Text type.
  textType,
  textTypeHeadline1,
  textTypeHeadline2,
  textTypeHeadline3,
  textTypeListBullet,
  textTypeListOrdered,
  textTypeDivider,
  textTypeQuote,
  textTypeCodeBlock,

  // Text style.
  textStyle,
  textStyleBold,
  textStyleItalic,
  textStyleUnderline,
  textStyleStrikeThrough,

  link,
}
