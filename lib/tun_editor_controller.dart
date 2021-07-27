import 'package:flutter/material.dart';
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

  // TODO Update selection
  void updateSelection() {
  }

  @override
  void dispose() {
    _subToolbarListeners.clear();

    super.dispose();
  }

  // =========== Tun editor toolbar handler ===========
  @override
  void undo() => _tunEditorApi?.undo();
  @override
  void redo() =>_tunEditorApi?.redo();
  @override
  void clearStyle() => _tunEditorApi?.clearStyle();

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
  void onSelectionChanged(Map status) => _tunEditorToolbarApi?.onSelectionChanged(status);

}
