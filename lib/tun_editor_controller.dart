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
  Future<String> getHtml() => _tunEditorApi?.getHtml() ?? Future.value("");

  @override
  void onTextChange(String text) {
    value = TunEditorValue(text: text);
  }

}
