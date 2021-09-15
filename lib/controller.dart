import 'package:flutter/material.dart';
// import 'package:tun_editor/models/documents/attribute.dart';
// import 'package:tun_editor/models/documents/document.dart';
// import 'package:tun_editor/models/documents/nodes/embed.dart';
// import 'package:tun_editor/models/quill_delta.dart';
import 'package:tun_editor/tun_editor_api.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TunEditorController {
  TunEditorApi? _tunEditorApi;

  // Document.
  final Document document;

  // Text selection.
  TextSelection get selection => _selection;
  TextSelection _selection;

  TunEditorController({
    required this.document,
    required TextSelection selection,
  }) : _selection = selection;

  factory TunEditorController.basic() {
    return TunEditorController(
      document: Document(),
      selection: TextSelection.collapsed(offset: 0),
    );
  }

  List<ValueChanged<TextSelection>> _selectionListeners = [];
  List<ValueChanged<Map<String, dynamic>>> _formatListeners = [];

  List<ValueChanged<bool>> _focusListeners = [];

  void dispose() {
    _selectionListeners.clear();
    _formatListeners.clear();
    _focusListeners.clear();
    _tunEditorApi = null;
  }

  /// Insert [data] at the given [index].
  /// And delete some words with [len] size.
  /// It will update selection, if [textSelection] is not null.
  void replaceText(
    int index,
    int len,
    Object? data,
    TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool autoAppendNewlineAfterImage = true,
    List<Attribute> attributes = const [],
  }) {
    assert(data is String || data is Embeddable);

    TextSelection newSelection;
    if (textSelection == null) {
      newSelection = TextSelection.collapsed(
        offset: index + (data is String ? data.length : 1));
    } else {
      newSelection = textSelection;
    }

    _tunEditorApi?.replaceText(
      index,
      len,
      data,
      autoAppendNewlineAfterImage: autoAppendNewlineAfterImage,
      attributes: attributes,
      ignoreFocus: ignoreFocus,
      selection: newSelection,
    );
  }

  void compose(Delta delta, TextSelection? textSelection, ChangeSource source, {
    bool ignoreFocus = false
  }) {
    _tunEditorApi?.updateContents(delta, source, ignoreFocus: ignoreFocus, selection: textSelection);
  }

  /// Insert mention with [id], [text] and [prefixChar], [id] should be unqiue, [id] and [prefixChar] will be used on click event.
  /// If [replaceLength] is given, it will delete some words before insert.
  void insertMention(
    String id,
    String text, {
    String prefixChar = '@',
    int replaceLength = 0,
    bool ignoreFocus = false,
    bool appendSpace = false,
  }) {
    int insertIndex = selection.extentOffset;
    if (replaceLength > 0 && insertIndex - replaceLength >= 0) {
      insertIndex = insertIndex - replaceLength;

      final deleteDelta = new Delta()
        ..retain(insertIndex)
        ..delete(replaceLength);
      compose(deleteDelta, null, ChangeSource.LOCAL, ignoreFocus: ignoreFocus);
    }

    final newIndex = appendSpace ? insertIndex + 2 : insertIndex + 1;
    final newSelection = TextSelection.collapsed(offset: newIndex);

    final mentionDelta = new Delta()
      ..retain(insertIndex)
      ..insert({
        'mention': {
          'denotationChar': '',
          'id': id,
          'value': text,
          'prefixChar': prefixChar,
        },
      });
    if (appendSpace) {
      mentionDelta.insert(' ');
    }
    compose(mentionDelta, newSelection, ChangeSource.LOCAL, ignoreFocus: ignoreFocus);
  }

  /// Insert [data] at the given [index].
  /// This is a shortcut of [replaceText].
  void insert(
    int index,
    Object? data, {
    bool ignoreFocus = false,
  }) {
    replaceText(index, 0, data, null, ignoreFocus: ignoreFocus);
  }

  void batchInsertEmbed({
    required List<Embeddable> embeds,
    bool appendNewLineAfterImage = true,
    bool appendNewLineAfterVideo = true,
    bool appendNewLine = false,
    bool ignoreFocus = false,
  }) {
    int insertOffset = selection.extentOffset;
    int newOffset = selection.extentOffset + 1;
    if (!_isEmptyLine()) {
      final newLineOffset = _insertNewLine(ignoreFocus: ignoreFocus);
      if (newLineOffset != null) {
        insertOffset = newLineOffset;
        newOffset = newLineOffset + 1;
      }
    }

    final delta = new Delta()..retain(insertOffset);
    for (final embed in embeds) {
      delta.insert(embed.toFormalJson());
      newOffset = newOffset + 1;
      if (appendNewLineAfterImage && embed is ImageEmbed) {
        delta.insert('\n');
        newOffset = newOffset + 1;
      }
      if (appendNewLineAfterVideo && embed is VideoEmbed) {
        delta.insert('\n');
        newOffset = newOffset + 1;
      }
    }
    if (appendNewLine) {
      delta.insert('\n');
      newOffset = newOffset + 1;
    }
    final newSelection = TextSelection.collapsed(offset: newOffset);
    compose(delta, newSelection, ChangeSource.LOCAL, ignoreFocus: ignoreFocus);
  }

  /// Insert image with given [url] to current [selection].
  void insertImage({
    required String name,
    required String source,
    required String checkPath,
    required double width,
    required double height,
    String type = 'image',
    bool inline = false,
    bool appendNewLine = false,
    List<Attribute> attributes = const [],
    bool ignoreFocus = false,
  }) {
    // Wrap value.
    final Map<String, dynamic> imageBlot = {
      'name': name,
      'source': source,
      'checkPath': checkPath,
      'width': width,
      'height': height,
      '_type': type,
      '_inline': inline,
    };

    // Wrap attributes
    final Map<String, dynamic> attrMap = {};
    for (final attr in attributes) {
      attrMap[attr.key] = attr.value;
    }

    int insertOffset = selection.extentOffset;
    int newOffset = selection.extentOffset + 1;
    if (!_isEmptyLine()) {
      final newLineOffset = _insertNewLine(ignoreFocus: ignoreFocus);
      if (newLineOffset != null) {
        insertOffset = newLineOffset;
        newOffset = newLineOffset + 1;
      }
    }

    // Insert image.
    final delta = new Delta()
      ..retain(insertOffset)
      ..insert({'image': imageBlot}, attrMap);
    if (appendNewLine) {
      delta.insert('\n');
      newOffset = newOffset + 1;
    }
    final newSelection = TextSelection.collapsed(offset: newOffset);
    compose(delta, newSelection, ChangeSource.LOCAL, ignoreFocus: ignoreFocus);
  }

  void insertVideo({
    required String source,
    required String fileType,
    required double duration,
    required String thumbUrl,
    required String thumbName,
    required double width,
    required double height,
    String type = 'video',
    bool inline = false,
    List<Attribute>? attributes = const [],
    bool ignoreFocus = false,
  }) {
    // Wrap value.
    final Map<String, dynamic> videoBlot = {
      'source': source,
      'duration': duration,
      'thumbUrl': thumbUrl,
      'thumbName': thumbName,
      'fileType': fileType,
      'width': width,
      'height': height,
      '_type': type,
      '_inline': inline,
    };

    // Wrap attributes
    final Map<String, dynamic> attrMap = {};
    if (attributes != null) {
      for (final attr in attributes) {
        attrMap[attr.key] = attr.value;
      }
    }

    int insertOffset = selection.extentOffset;
    int newOffset = selection.extentOffset + 1;
    if (!_isEmptyLine()) {
      final newLineOffset = _insertNewLine(ignoreFocus: ignoreFocus);
      if (newLineOffset != null) {
        insertOffset = newLineOffset;
        newOffset = newLineOffset + 1;
      }
    }

    final delta = new Delta()
      ..retain(insertOffset)
      ..insert({'video': videoBlot}, attrMap);
    final newSelection = TextSelection.collapsed(offset: newOffset);
    compose(delta, newSelection, ChangeSource.LOCAL, ignoreFocus: ignoreFocus);
  }

  /// Insert divider to current [selection].
  void insertDivider({bool ignoreFocus = false}) {
    final newLineOffset = _insertNewLine(ignoreFocus: ignoreFocus);
    if (newLineOffset == null) {
      return;
    }

    // Insert divider.
    final dividerDelta = new Delta()
      ..retain(newLineOffset)
      ..insert({'divider': 'hr'});
    final newSelection =TextSelection.collapsed(offset: newLineOffset + 1); 
    compose(dividerDelta, newSelection, ChangeSource.LOCAL, ignoreFocus: ignoreFocus);
  }

  /// Insert [text] with [link] format to current [selection].
  void insertLink(String text, String url, {bool ignoreFocus = false}) {
    final newSelection = TextSelection.collapsed(offset: selection.extentOffset + text.length);
    final delta = new Delta()
      ..retain(selection.extentOffset)
      ..insert(text, LinkAttribute(url).toJson());
    compose(delta, newSelection, ChangeSource.LOCAL, ignoreFocus: ignoreFocus);
  }

  /// Format current [selection] with text type.
  /// Text type will affects all the text in the [selection] line.
  /// And all text type are mutually exclusive, only the last selected
  /// [textType] will be actived.
  void setTextType(String textType) {
    _tunEditorApi?.setTextType(textType);
  }

  /// Format current [selection] with text style.
  /// Text style will affects inline text.
  /// And all text style support integration.
  void setTextStyle(List<dynamic> textStyle) {
    _tunEditorApi?.setTextStyle(textStyle);
  }

  /// Format the text in current [selection] with given [name] and [value].
  void format(String name, dynamic value) {
    _tunEditorApi?.format(name, value);
  }

  /// Format text which in range from [index] with [len] size with [attribute].
  void formatText(int index, int len, Attribute attribute) {
    _tunEditorApi?.formatText(index, len, attribute);
  }

  /// Update [_selection] with given new [textSelection].
  /// Nothing will happen if invalid [textSelection] is provided.
  void updateSelection(TextSelection textSelection, ChangeSource source, {
    bool ignoreFocus = false,
  }) {
    if (textSelection.baseOffset < 0 || textSelection.extentOffset < 0) {
      return;
    }
    _selection = textSelection;
    _tunEditorApi?.updateSelection(textSelection, ignoreFocus: ignoreFocus);
  }

  /// Request focus to editor.
  void focus() {
    _tunEditorApi?.focus();
  }

  /// Request unfocus to editor.
  void blur() {
    _tunEditorApi?.blur();
  }

  void scrollTo(int offset) {
    _tunEditorApi?.scrollTo(offset);
  }

  void scrollToTop() {
    _tunEditorApi?.scrollToTop();
  }

  void scrollToBottom() {
    _tunEditorApi?.scrollToBottom();
  }

  void addSelectionListener(ValueChanged<TextSelection> listener) {
    _selectionListeners.add(listener);
  }

  void removeSelectionListener(ValueChanged<TextSelection> listener) {
    _selectionListeners.remove(listener);
  }

  // ================== Below methods are internal ==================

  void setTunEditorApi(TunEditorApi? api) {
    this._tunEditorApi = api;
  }

  void addFormatListener(ValueChanged<Map<String, dynamic>> listener) {
    _formatListeners.add(listener);
  }

  void removeFormatListener(ValueChanged<Map<String, dynamic>> listener) {
    _formatListeners.remove(listener);
  }

  void addFocusListener(ValueChanged<bool> listener) {
    _focusListeners.add(listener);
  }

  void removeFocusListener(ValueChanged<bool> listener) {
    _focusListeners.remove(listener);
  }

  void syncSelection(int index, int length, Map<String, dynamic> format) {
    _selection = TextSelection(baseOffset: index, extentOffset: index + length);

    for (final listener in _formatListeners) {
      listener(format);
    }
    for (final listener in _selectionListeners) {
      listener(_selection);
    }
  }

  void syncFocus(bool hasFocus) {
    for (final listener in _focusListeners) {
      listener(hasFocus);
    }
  }

  bool _isEmptyLine() {
    final child = document.queryChild(selection.extentOffset);
    if (child.node == null) {
      return true;
    }
    return child.node!.length == 1 && child.node!.toPlainText() == '\n';
  }

  // Insert new line and return new line's offset.
  int? _insertNewLine({
    bool ignoreFocus = false,
  }) {
    final child = document.queryChild(selection.extentOffset);
    if (child.node == null) {
      return null;
    }

    final delta = new Delta();
    final lineEndOffset = child.node!.documentOffset + child.node!.length - 1;
    delta.retain(lineEndOffset);

    // Insert new line below current line.
    if (child.node!.style.attributes.containsKey(Attribute.header.key)) {
      delta.insert(
          '\n', child.node!.style.attributes[Attribute.header.key]!.toJson());
      delta.retain(1, Attribute.header.toJson());
    } else if (child.node!.style.attributes.containsKey(Attribute.list.key)) {
      delta.insert(
          '\n', child.node!.style.attributes[Attribute.list.key]!.toJson());
      delta.retain(1, Attribute.list.toJson());
    } else if (child.node!.style.attributes
        .containsKey(Attribute.codeBlock.key)) {
      delta.insert('\n',
          child.node!.style.attributes[Attribute.codeBlock.key]!.toJson());
      delta.retain(
          1,
          Attribute(Attribute.codeBlock.key, AttributeScope.BLOCK, null)
              .toJson());
    } else if (child.node!.style.attributes
        .containsKey(Attribute.blockQuote.key)) {
      delta.insert('\n',
          child.node!.style.attributes[Attribute.blockQuote.key]!.toJson());
      delta.retain(
          1,
          Attribute(Attribute.blockQuote.key, AttributeScope.BLOCK, null)
              .toJson());
    } else {
      delta.insert('\n');
    }
    compose(delta, null, ChangeSource.LOCAL, ignoreFocus: ignoreFocus);
    return lineEndOffset + 1;
  }
}
