import 'package:flutter/material.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/models/documents/style.dart';
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
    _tunEditorApi?.insert(
        index, data,
        replaceLength: replaceLength,
        autoAppendNewlineAfterImage: autoAppendNewlineAfterImage,
    );
    updateSelection(
        TextSelection.collapsed(offset: index + (data is String ? data.length : 0)),
        ChangeSource.LOCAL,
    );
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

  void attachTunEditorToolbar(int viewId) {
    _tunEditorToolbarApi = TunEditorToolbarApi(viewId, this);
  }

  // =========== Tun editor toolbar handler ===========
  @override
  void onAtClick() {
    debugPrint('on at click');
    onAt?.call();
  }
  @override
  void onImageClick() {
    debugPrint('on image click');
    onImage?.call();
  }
  @override
  void onEmojiClick() {
    debugPrint('on emoji click');
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
    int start, int before, int count,
    String oldText, String newText,
    String style,
  ) async {
    final attrs = _getAttributes(style);
    if (before <= 0) {
      // Insert.
      final delta = Delta()
          ..retain(start)
          ..insert(newText.substring(start, start + count), attrs);
      document.compose(delta, ChangeSource.LOCAL);

    } else {
      if (count <= 0) {
        // Delete.
        final delta = Delta()
            ..retain(start)
            ..delete(before);
        document.compose(delta, ChangeSource.LOCAL);

      } else {
        // Replace.
        final insertDelta = Delta()
            ..retain(start + before)
            ..insert(newText.substring(start, start + count), attrs);
        final deleteDelta = Delta()
            ..retain(start)
            ..delete(before);
        document.compose(insertDelta, ChangeSource.LOCAL);
        document.compose(deleteDelta, ChangeSource.LOCAL);
      }
    }
    notifyListeners();
  }

  @override
  void onSelectionChanged(Map<dynamic, dynamic> status) {
    final selStart = status["selStart"] as int;
    final selEnd = status["selEnd"] as int;
    _selection = TextSelection(baseOffset: selStart, extentOffset: selEnd);
    _tunEditorToolbarApi?.onSelectionChanged(status);
  }

  Map<String, dynamic>? _getAttributes(String styleStr) {
    Style style = Style();
    switch (styleStr) {
      // case 'header1':
      //   style = style.put(Attribute.h1);
      //   break;
      // case 'header2':
      //   style = style.put(Attribute.h2);
      //   break;
      // case 'header3':
      //   style = style.put(Attribute.h3);
      //   break;
      case 'list-bullet':
        style = style.put(Attribute.ul);
        break;
      case 'list-ordered':
        style = style.put(Attribute.ol);
        break;
      case 'blockquote':
        style = style.put(Attribute.blockQuote);
        break;
      case 'code-block':
        style = style.put(Attribute.codeBlock);
        break;
      case 'bold':
        style = style.put(Attribute.bold);
        break;
      case 'italic':
        style = style.put(Attribute.italic);
        break;
      case 'underline':
        style = style.put(Attribute.underline);
        break;
      case 'strike':
        style = style.put(Attribute.strikeThrough);
        break;
    }
    return style.toJson();
  }

}
