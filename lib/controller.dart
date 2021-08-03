import 'package:flutter/material.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/models/quill_delta.dart';
import 'package:tun_editor/tun_editor_api.dart';

class TunEditorController extends ChangeNotifier {

  TunEditorApi? _tunEditorApi;

  final List<ValueChanged<bool>> _subToolbarListeners = [];

  // Document.
  final Document document;

  // Text selection.
  TextSelection get selection => _selection;
  TextSelection _selection;

  VoidCallback? onAt;
  VoidCallback? onImage;
  VoidCallback? onEmoji;

  TunEditorController({
    required this.document,
    required TextSelection selection,
    this.onAt,
    this.onImage,
    this.onEmoji,
  }): _selection = selection;

  factory TunEditorController.basic() {
    return TunEditorController(
      document: Document(),
      selection: TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _subToolbarListeners.clear();
    _tunEditorApi = null;

    super.dispose();
  }

  // Replace text.
  void replaceText(int index, int len, Object? data, TextSelection? textSelection) {
    document.replace(index, len, data);
    _tunEditorApi?.replaceText(index, len, data);

    if (textSelection == null) {
      updateSelection(
          TextSelection.collapsed(offset: index + (data is String ? data.length : 0)),
          ChangeSource.LOCAL,
      );
    } else {
      updateSelection(textSelection, ChangeSource.LOCAL);
    }
  }

  // Insert.
  void insert(int index, Object? data) {
    replaceText(index, 0, data, TextSelection.collapsed(offset: selection.baseOffset));
  }

  /// Insert image with given [url].
  void insertImage(String url) {
    _tunEditorApi?.insertImage(url);
  }

  void insertDivider() {
    _tunEditorApi?.insertDivider();
  }

  void setTextType(String textType) {
    _tunEditorApi?.setTextType(textType);
  }

  void setTextStyle(List<dynamic> textStyle) {
    _tunEditorApi?.setTextStyle(textStyle);
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

  void focus() {
    _tunEditorApi?.focus();
  }

  void blur() {
    _tunEditorApi?.blur();
  }

  void setTunEditorApi(TunEditorApi? api) {
    this._tunEditorApi = api;
  }

  void syncSelection(int selStart, int selEnd) {
    _selection = TextSelection(baseOffset: selStart, extentOffset: selEnd);
    notifyListeners();
  }

  void composeDocument(Delta delta) {
    document.compose(delta, ChangeSource.LOCAL);
    notifyListeners();
  }

}
