import 'package:flutter/material.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/models/documents/nodes/embed.dart';
import 'package:tun_editor/models/quill_delta.dart';
import 'package:tun_editor/tun_editor_api.dart';

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
  }): _selection = selection;

  factory TunEditorController.basic() {
    return TunEditorController(
      document: Document(),
      selection: TextSelection.collapsed(offset: 0),
    );
  }

  List<ValueChanged<Map<String, dynamic>>> _formatListeners = [];

  void dispose() {
    _formatListeners.clear();
    _tunEditorApi = null;
  }

  /// Insert [data] at the given [index].
  /// And delete some words with [len] size.
  /// It will update selection, if [textSelection] is not null.
  void replaceText(int index, int len, Object? data, TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool autoAppendNewlineAfterImage = true,
    List<Attribute> attributes = const [],
  }) {
    assert(data is String || data is Embeddable);
    _tunEditorApi?.replaceText(
      index, len, data,
      autoAppendNewlineAfterImage: autoAppendNewlineAfterImage,
      attributes: attributes,
    );

    if (textSelection == null) {
      updateSelection(
          TextSelection.collapsed(offset: index + (data is String ? data.length : 1)),
          ChangeSource.LOCAL,
      );
    } else {
      updateSelection(textSelection, ChangeSource.LOCAL);
    }
    if (!ignoreFocus) {
      focus();
    }
  }

  void compose(Delta delta, TextSelection? textSelection, ChangeSource source) {
    _tunEditorApi?.updateContents(delta, source);
    if (textSelection == null) {
      updateSelection(selection.copyWith(
        baseOffset: delta.transformPosition(selection.baseOffset, force: false),
        extentOffset: delta.transformPosition(selection.extentOffset, force: false)
      ), source);
    } else {
      updateSelection(textSelection, source);
    }
  }

  /// Insert mention with [id], [text] and [prefixChar], [id] should be unqiue, [id] and [prefixChar] will be used on click event.
  void insertMention(String id, String text, {
    String prefixChar = '@'
  }) {
    final mentionDelta = new Delta()
        ..retain(selection.extentOffset)
        ..insert({
          'mention': {
            'denotationChar': '',
            'id': id,
            'value': text,
            'prefixChar': prefixChar,
          },
        });
    compose(mentionDelta, null, ChangeSource.LOCAL);

    final spaceDelta = new Delta()
        ..retain(selection.extentOffset + 1)
        ..insert(' ');
    compose(spaceDelta, null, ChangeSource.LOCAL);

    updateSelection(
      TextSelection.collapsed(offset: selection.extentOffset + 2),
      ChangeSource.LOCAL,
    );
  }

  /// Insert [data] at the given [index].
  /// This is a shortcut of [replaceText].
  void insert(int index, Object? data, {
    bool ignoreFocus = false,
  }) {
    replaceText(index, 0, data, null, ignoreFocus: ignoreFocus);
  }

  /// Insert image with given [url] to current [selection].
  void insertImage({
    required String source,
    double? width,
    double? height,
    String? checkPath,
    bool appendNewLine = false,
    List<Attribute>? attributes = const [],
  }) {
    // Wrap value.
    final Map<String, dynamic> imageBlot = {
      'source': source,
    };
    if (width != null) {
      imageBlot['width'] = width;
    }
    if (height != null) {
      imageBlot['height'] = height;
    }
    if (checkPath != null) {
      imageBlot['checkPath'] = checkPath;
    }

    // Wrap attributes
    final Map<String, dynamic> attrMap = {};
    if (attributes != null) {
      for (final attr in attributes) {
        attrMap[attr.key] = attr.value;
      }
    }

    // Insert image.
    final delta = new Delta()
      ..retain(selection.extentOffset)
      ..insert({ 'image': imageBlot }, attrMap);
    if (appendNewLine) {
      delta.insert('\n');
    }
    debugPrint('insert delta ${delta.toJson()}');
    compose(delta, null, ChangeSource.LOCAL);

    int newOffset = selection.extentOffset + 1;
    if (appendNewLine) {
      newOffset = newOffset + 1;
    }
    updateSelection(
      TextSelection.collapsed(offset: newOffset),
      ChangeSource.LOCAL,
    );
  }

  void insertVideo({
    required String source,
    required double duration,
    required String thumbUrl,
    double? width,
    double? height,
    String? fillType,
    String? videoType,
    bool? inline,
    List<Attribute>? attributes = const [],
  }) {
    // Wrap value.
    final Map<String, dynamic> videoBlot = {
      'source': source,
      'duration': duration,
      'thumbUrl': thumbUrl,
    };
    if (width != null) {
      videoBlot['width'] = width;
    }
    if (height != null) {
      videoBlot['height'] = height;
    }
    if (fillType != null) {
      videoBlot['fillType'] = fillType;
    }
    if (videoType != null) {
      videoBlot['videoType'] = videoType;
    }
    if (inline != null) {
      videoBlot['inline'] = inline;
    }

    // Wrap attributes
    final Map<String, dynamic> attrMap = {};
    if (attributes != null) {
      for (final attr in attributes) {
        attrMap[attr.key] = attr.value;
      }
    }

    final delta = new Delta()
      ..retain(selection.extentOffset)
      ..insert({ 'video': videoBlot }, attrMap);
    compose(delta, null, ChangeSource.LOCAL);
    updateSelection(
      TextSelection.collapsed(offset: selection.extentOffset + 1),
      ChangeSource.LOCAL,
    );
  }

  /// Insert divider to current [selection].
  void insertDivider() {
    final newLineOffset = _insertNewLine();
    if (newLineOffset == null) {
      return;
    }

    // Insert divider.
    final dividerDelta = new Delta()
        ..retain(newLineOffset)
        ..insert({ 'divider': 'hr' });
    compose(dividerDelta, null, ChangeSource.LOCAL);

    updateSelection(TextSelection.collapsed(
      offset: newLineOffset + 1), ChangeSource.LOCAL);
  }

  /// Insert [text] with [link] format to current [selection].
  void insertLink(String text, String url) {
    final delta = new Delta()
        ..retain(selection.extentOffset)
        ..insert(text, LinkAttribute(url).toJson());
    compose(delta, null, ChangeSource.LOCAL);
    updateSelection(TextSelection.collapsed(
      offset: selection.extentOffset + text.length), ChangeSource.LOCAL);
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
  void updateSelection(TextSelection textSelection, ChangeSource source) {
    if (textSelection.baseOffset < 0 || textSelection.extentOffset < 0) {
      return;
    }
    _selection = textSelection;
    _tunEditorApi?.updateSelection(textSelection);
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

  void syncSelection(int index, int length, Map<String, dynamic> format) {
    _selection = TextSelection(baseOffset: index, extentOffset: index + length);

    for (final listener in _formatListeners) {
      listener(format);
    }
  }

  void composeDocument(Delta delta) {
    debugPrint('compose delta ${delta.toJson()}');
    document.compose(delta, ChangeSource.LOCAL);
  }

  bool _isEmptyLine() {
    final child = document.queryChild(selection.extentOffset);
    if (child.node == null) {
      return true;
    }
    debugPrint('child ${child.node!.length} ${child.node!.toDelta().toJson()} ${child.node!.toPlainText() == '\n'} ${child.node!.isLast}');
    return child.node!.length == 1 && child.node!.toPlainText() == '\n';
  }

  // Insert new line and return new line's offset.
  int? _insertNewLine() {
    final child = document.queryChild(selection.extentOffset);
    if (child.node == null) {
      return null;
    }

    final delta = new Delta();
    final lineEndOffset = child.node!.documentOffset + child.node!.length - 1;
    delta.retain(lineEndOffset);

    // Insert new line below current line.
    if (child.node!.style.attributes.containsKey(Attribute.header.key)) {
      delta.insert('\n', child.node!.style.attributes[Attribute.header.key]!.toJson());
      delta.retain(1, Attribute.header.toJson());
    } else if (child.node!.style.attributes.containsKey(Attribute.list.key)) {
      delta.insert('\n', child.node!.style.attributes[Attribute.list.key]!.toJson());
      delta.retain(1, Attribute.list.toJson());
    } else if (child.node!.style.attributes.containsKey(Attribute.codeBlock.key)) {
      delta.insert('\n', child.node!.style.attributes[Attribute.codeBlock.key]!.toJson());
      delta.retain(1, Attribute(Attribute.codeBlock.key, AttributeScope.BLOCK, null).toJson());
    } else if (child.node!.style.attributes.containsKey(Attribute.blockQuote.key)) {
      delta.insert('\n', child.node!.style.attributes[Attribute.blockQuote.key]!.toJson());
      delta.retain(1, Attribute(Attribute.blockQuote.key, AttributeScope.BLOCK, null).toJson());
    } else {
      delta.insert('\n');
    }
    compose(delta, null, ChangeSource.LOCAL);
    return lineEndOffset + 1;
  }

}
