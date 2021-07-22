import 'package:flutter/material.dart';
import 'package:tun_editor/tun_editor_api.dart';
import 'package:tun_editor/tun_editor_toolbar_api.dart';
import 'package:tun_editor/tun_editor_value.dart';

class TunEditorController extends ValueNotifier<TunEditorValue> with TunEditorHandler, TunEditorToolbarHandler {

  TunEditorToolbarApi? _tunEditorToolbarApi;
  TunEditorApi? _tunEditorApi;

  TunEditorController.document({
    required String text,
  }): super(TunEditorValue(text: text));

  void attachTunEditor(int viewId) {
    _tunEditorApi = TunEditorApi(viewId, this);
  }

  void attachTunEditorToolbar(int viewId) {
    _tunEditorToolbarApi = TunEditorToolbarApi(viewId, this);
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

  Future<String> getHtml() => _tunEditorApi?.getHtml() ?? Future.value("");

  @override
  void onTextChange(String text) {
    value = TunEditorValue(text: text);
  }

}
