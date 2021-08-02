import 'package:flutter/foundation.dart';
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
        try {
          final args = call.arguments as Map<dynamic, dynamic>;
          final delta = args["delta"] as String;
          final oldDelta = args["oldDelta"] as String;
          _handler.onTextChange(delta, oldDelta);
        } catch(e, s) {
          print('on text change: $e, $s');
        }
        break;

      case 'onSelectionChanged':
        _handler.onSelectionChanged(call.arguments);
        break;

      case 'onFocusChange':
        final hasFocus = call.arguments as bool;
        _handler.onFocusChanged(hasFocus);
        break;

      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

  // Common tools.
  void undo() {
    _channel.invokeMethod('undo');
  }
  void redo() {
    _channel.invokeMethod('redo');
  }
  void clearTextType() {
    _channel.invokeMethod('clearTextType');
  }
  void clearTextStyle() {
    _channel.invokeMethod('clearTextStyle');
  }
  void setTextType(String textType) {
    _channel.invokeMethod('setTextType', textType);
  }
  void setTextStyle(List<dynamic> textStyle) {
    _channel.invokeMethod('setTextStyle', textStyle);
  }
  void updateSelection(TextSelection selection) {
    _channel.invokeMethod('updateSelection', {
      'selStart': selection.baseOffset,
      'selEnd': selection.extentOffset,
    });
  }
  void formatText(int index, int len, Attribute attribute) {
    _channel.invokeMethod('formatText', {
      'index': index,
      'len': len,
      'name': attribute.key,
      'value': attribute.value,
    });
  }
  void replaceText(int index, int len, Object? data, {
    bool ignoreFocus = false,
    bool autoAppendNewlineAfterImage = true
  }) {
    _channel.invokeMethod('replaceText', {
      'index': index,
      'len': len,
      'data': data,
    });
  }
  void insert(int index, Object? data, {
    int replaceLength = 0,
    bool autoAppendNewlineAfterImage = true,
  }) {
    _channel.invokeMethod('insert', {
      'index': index,
      'data': data,
      'replaceLength': replaceLength,
      'autoAppendNewlineAfterImage': autoAppendNewlineAfterImage,
    });
  }
  void insertDivider() {
    _channel.invokeMethod('insertDivider');
  }
  void insertImage(String url, String alt) {
    _channel.invokeMethod('insertImage', {
      'url': url,
      'alt': alt,
    });
  }
  void focus() {
    _channel.invokeMethod('focus');
  }
  void blur() {
    _channel.invokeMethod('blur');
  }

}

mixin TunEditorHandler on ChangeNotifier {
  Future<void> onTextChange(
    String delta, String oldDelta,
  );
  void onSelectionChanged(Map<dynamic, dynamic> status);
  void onFocusChanged(bool hasFocus);
}
