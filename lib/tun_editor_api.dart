import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tun_editor/models/documents/attribute.dart';

class TunEditorApi {

  final MethodChannel _channel;
  final TunEditorHandler _handler;

  TunEditorApi(
    int id,
    this._handler,
  ) : _channel = MethodChannel('tun/editor/$id') {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<bool?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextChange':
        final args = call.arguments as Map<dynamic, dynamic>;
        final delta = args["delta"] as String;
        final oldDelta = args["oldDelta"] as String;
        _handler.onTextChange(delta, oldDelta);
        break;

      case 'onSelectionChange':
        try {
          final args = call.arguments as Map<dynamic, dynamic>;
          final index = args["index"] as int;
          final length = args["length"] as int;
          final format = args['format'] is String
              ? json.decode(args['format'])
              : {};
          _handler.onSelectionChange(index, length, format);
        } catch(e, s) {
          print('on selection change $e $s');
        }
        break;

      default:
        print('missing method handler in tun editor');
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

  // Content related.
  void replaceText(int index, int len, Object? data) {
    _channel.invokeMethod('replaceText', {
      'index': index,
      'len': len,
      'data': data,
    });
  }
  void insertDivider() {
    _channel.invokeMethod('insertDivider');
  }
  void insertImage(String url) {
    _channel.invokeMethod('insertImage', url);
  }

  // Format related.
  void setTextType(String textType) {
    _channel.invokeMethod('setTextType', textType);
  }
  void setTextStyle(List<dynamic> textStyle) {
    _channel.invokeMethod('setTextStyle', textStyle);
  }
  void formatText(int index, int len, Attribute attribute) {
    _channel.invokeMethod('formatText', {
      'index': index,
      'len': len,
      'name': attribute.key,
      'value': attribute.value,
    });
  }

  // Selection related.
  void updateSelection(TextSelection selection) {
    _channel.invokeMethod('updateSelection', {
      'selStart': selection.baseOffset,
      'selEnd': selection.extentOffset,
    });
  }

  // Editor related.
  void focus() {
    _channel.invokeMethod('focus');
  }
  void blur() {
    _channel.invokeMethod('blur');
  }

}

mixin TunEditorHandler {
  Future<void> onTextChange(String delta, String oldDelta);
  void onSelectionChange(int index, int length, Map<String, dynamic> format);
}
