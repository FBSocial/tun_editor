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

  /// Insert mention with [id] and [text], [id] should be unqiue, will be used on click event.
  void insertMention(String id, String text) {
    _tunEditorApi?.insertMention(id, text);
  }

  /// Insert [data] at the given [index].
  /// This is a shortcut of [replaceText].
  void insert(int index, Object? data) {
    replaceText(index, 0, data, TextSelection.collapsed(offset: selection.baseOffset));
  }

  /// Insert image with given [url] to current [selection].
  void insertImage(String url) {
    _tunEditorApi?.insertImage(url);
  }

  /// Insert divider to current [selection].
  void insertDivider() {
    _tunEditorApi?.insertDivider();
    // compose(new Delta()
    //     ..retain(selection.extentOffset)
    //     ..insert('\n')
    //     ..insert({ 'divider': true }), null, ChangeSource.LOCAL);
  }

  /// Insert [text] with [link] format to current [selection].
  void insertLink(String text, String url) {
    _tunEditorApi?.insertLink(text, url);
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
    document.compose(delta, ChangeSource.LOCAL);
  }

}
