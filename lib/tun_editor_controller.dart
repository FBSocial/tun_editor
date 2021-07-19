import 'package:flutter/material.dart';
import 'package:tun_editor/tun_editor_value.dart';

class TunEditorController extends ValueNotifier<TunEditorValue> {

  TunEditorController.document({
    required String document,
  }): super(TunEditorValue.fromDocument(document));

}
