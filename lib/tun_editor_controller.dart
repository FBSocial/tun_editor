import 'package:flutter/material.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/tun_editor_api.dart';
import 'package:tun_editor/tun_editor_toolbar_api.dart';

class TunEditorController extends ChangeNotifier with TunEditorHandler, TunEditorToolbarHandler {

  TunEditorToolbarApi? _tunEditorToolbarApi;
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
  void undo() => _tunEditorApi?.undo();
  @override
  void redo() =>_tunEditorApi?.redo();

  @override
  void setBold() => _tunEditorApi?.setBold();
  @override
  void setItalic() => _tunEditorApi?.setItalic();
  @override
  void setUnderline() => _tunEditorApi?.setUnderline();
  @override
  void setStrikeThrough() => _tunEditorApi?.setStrikeThrough();
  @override
  void setHeadline1() => _tunEditorApi?.setHeadline1();
  @override
  void setHeadline2() => _tunEditorApi?.setHeadline2();
  @override
  void setHeadline3() => _tunEditorApi?.setHeadline3();
  @override
  void clearStyle() => _tunEditorApi?.clearStyle();

  Future<String> getHtml() => _tunEditorApi?.getHtml() ?? Future.value("");

  @override
  void onTextChange(String text) {
    // document.delete(0, document.length);
    // document.insert()
  }

}
