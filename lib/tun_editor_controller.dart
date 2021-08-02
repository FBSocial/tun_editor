import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/models/quill_delta.dart';
import 'package:tun_editor/tun_editor_api.dart';
import 'package:tun_editor/tun_editor_toolbar_api.dart';

class TunEditorController extends ChangeNotifier with TunEditorHandler, TunEditorToolbarHandler {

  TunEditorToolbarApi? _tunEditorToolbarApi;
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
    _tunEditorToolbarApi = null;

    super.dispose();
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

  void formatText(int index, int len, Attribute attribute) {
    _tunEditorApi?.formatText(index, len, attribute);
  }

  // Replace text.
  void replaceText(int index, int len, Object? data, TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool autoAppendNewlineAfterImage = true
  }) {
    document.replace(index, len, data);
    _tunEditorApi?.replaceText(
        index, len, data,
        ignoreFocus: ignoreFocus,
        autoAppendNewlineAfterImage: autoAppendNewlineAfterImage,
    );

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
  void insert(int index, Object? data, {
    int replaceLength = 0,
    bool autoAppendNewlineAfterImage = true,
  }) {
    replaceText(index, 0, data, TextSelection.collapsed(offset: selection.baseOffset));
  }

  /// Insert image with [url] and [alt]
  void insertImage(String url, String alt) {
    _tunEditorApi?.insertImage(url, alt);
  }

  void focus() {
    _tunEditorApi?.focus();
  }

  void blur() {
    _tunEditorApi?.blur();
  }

  void addSubToolbarListener(ValueChanged<bool> onSubToolbarToggle) {
    this._subToolbarListeners.add(onSubToolbarToggle);
  }

  void removeSubToolbarListener(ValueChanged<bool> onSubToolbarToggle) {
    this._subToolbarListeners.remove(onSubToolbarToggle);
  }

  void attachTunEditor(int viewId) {
    _tunEditorApi = TunEditorApi(viewId, this);
  }

  void detachTunEditor() {
    _tunEditorApi = null;
  }

  void attachTunEditorToolbar({
    int? viewId,
    OnSelectionChanged? onSelectionChanged,
  }) {
    _tunEditorToolbarApi = TunEditorToolbarApi(
      this,
      viewId: viewId,
      onSelectionChanged: onSelectionChanged,
    );
  }

  void detachTunEditorToolbar() {
    _tunEditorToolbarApi = null;
  }

  // =========== Tun editor toolbar handler ===========
  @override
  void onAtClick() {
    onAt?.call();
  }
  @override
  void onImageClick() {
    onImage?.call();
  }
  @override
  void onEmojiClick() {
    onEmoji?.call();
  }
  @override
  void onSubToolbarToggle(bool isShow) {
    for (final listener in _subToolbarListeners) {
      listener.call(isShow);
    }
  }
  @override
  void setTextType(String textType) {
    _tunEditorApi?.setTextType(textType);
  }
  @override
  void setTextStyle(List<dynamic> textStyle) {
    _tunEditorApi?.setTextStyle(textStyle);
  }
  @override
  void insertDivider() {
    _tunEditorApi?.insertDivider();
  }

  // =========== Tun editor handler ===========
  @override
  Future<void> onTextChange(
    String delta, String oldDelta,
  ) async {
    final deltaMap = json.decode(delta) as Map;
    final deltaObj = deltaMap['ops'] as List<dynamic>;
    document.compose(Delta.fromJson(deltaObj), ChangeSource.LOCAL);
    notifyListeners();
  }

  @override
  void onSelectionChanged(Map<dynamic, dynamic> status) {
    final selStart = status["selStart"] as int;
    final selEnd = status["selEnd"] as int;
    _selection = TextSelection(baseOffset: selStart, extentOffset: selEnd);
    _tunEditorToolbarApi?.onSelectionChanged(status);
  }

  @override
  void onFocusChanged(bool hasFocus) {
  }

}
