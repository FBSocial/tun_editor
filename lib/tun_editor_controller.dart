import 'package:flutter/material.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/documents/document.dart';
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

  @override
  void dispose() {
    _subToolbarListeners.clear();

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

  // TODO Format text.
  void formatText(int index, int len, Attribute? attribute) {
  }

  // TODO Replace text.
  void replaceText(int index, int len, Object? data, TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool autoAppendNewlineAfterImage = true
  }) {
  }

  // TODO Insert.
  void insert(int index, Object? data, {
    int replaceLength = 0,
    bool autoAppendNewlineAfterImage = true,
  }) {
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
  void undo() => _tunEditorApi?.undo();
  @override
  void redo() =>_tunEditorApi?.redo();
  @override
  void clearStyle() => _tunEditorApi?.clearStyle();
  @override
  void testInsertAt() => _tunEditorApi?.setHtml();

  @override
  void setHeadline1() => _tunEditorApi?.setHeadline1();
  @override
  void setHeadline2() => _tunEditorApi?.setHeadline2();
  @override
  void setHeadline3() => _tunEditorApi?.setHeadline3();
  @override
  void setList() => _tunEditorApi?.setList();
  @override
  void setOrderedList() => _tunEditorApi?.setOrderedList();
  @override
  void insertDivider() => _tunEditorApi?.insertDivider();
  @override
  void setQuote() => _tunEditorApi?.setQuote();
  @override
  void setCodeBlock() => _tunEditorApi?.setCodeBlock();

  @override
  void setBold() => _tunEditorApi?.setBold();
  @override
  void setItalic() => _tunEditorApi?.setItalic();
  @override
  void setUnderline() => _tunEditorApi?.setUnderline();
  @override
  void setStrikeThrough() => _tunEditorApi?.setStrikeThrough();

  @override
  void onSubToolbarToggle(bool isShow) {
    for (final listener in _subToolbarListeners) {
      listener.call(isShow);
    }
  }

  Future<String> getHtml() => _tunEditorApi?.getHtml() ?? Future.value("");

  // =========== Tun editor handler ===========
  @override
  void onTextChange(String text) {
    // document.delete(0, document.length);
    // document.insert()
  }

  @override
  void onSelectionChanged(Map status) {
    final selStart = status["selStart"] as int;
    final selEnd = status["selEnd"] as int;
    _selection = TextSelection(baseOffset: selStart, extentOffset: selEnd);
    _tunEditorToolbarApi?.onSelectionChanged(status);
  }

}
