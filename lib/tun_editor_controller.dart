import 'package:flutter/material.dart';
import 'package:tun_editor/tun_editor_api.dart';
import 'package:tun_editor/tun_editor_toolbar_api.dart';
import 'package:tun_editor/tun_editor_value.dart';

class TunEditorController extends ValueNotifier<TunEditorValue> {

  TunEditorToolbarApi? _tunEditorToolbarApi;
  TunEditorApi? _tunEditorApi;

  TunEditorController.document({
    required String document,
  }): super(TunEditorValue.fromDocument(document));

  void registerTunEditorApi(TunEditorApi api) {
    _tunEditorApi = api;
  }

  void registerTunEditorToolbarApi(TunEditorToolbarApi api) {
    _tunEditorToolbarApi = api;
  }

  void undo() {
    _tunEditorApi?.undo();
  }

  void redo() {
    _tunEditorApi?.redo();
  }

  void setBold() {
    _tunEditorApi?.setBold();
  }

}
