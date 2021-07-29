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
        final args = call.arguments as Map<dynamic, dynamic>;
        final start = args["start"] as int;
        final before = args["before"] as int;
        final count = args["count"] as int;
        final oldText = args["oldText"] as String;
        final newText = args["newText"] as String;
        final style = args["style"] as String;
        debugPrint("onTextChange: $start, $before, $count, $style");
        try {
          _handler.onTextChange(start, before, count, oldText, newText, style);
        } catch(e, s) {
          print('on text change: $e, $s');
        }
        break;

      case 'onSelectionChanged':
        _handler.onSelectionChanged(call.arguments);
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

  // Text types.
  void setHeadline1() {
    _channel.invokeMethod('setHeadline1');
  }
  void setHeadline2() {
    _channel.invokeMethod('setHeadline2');
  }
  void setHeadline3() {
    _channel.invokeMethod('setHeadline3');
  }
  void setList() {
    _channel.invokeMethod('setList');
  }
  void setOrderedList() {
    _channel.invokeMethod('setOrderedList');
  }
  void insertDivider() {
    _channel.invokeMethod('insertDivider');
  }
  void setQuote() {
    _channel.invokeMethod('setQuote');
  }
  void setCodeBlock() {
    _channel.invokeMethod('setCodeBlock');
  }

  // Text styles.
  void setBold() {
    _channel.invokeMethod('setBold');
  }
  void setItalic() {
    _channel.invokeMethod('setItalic');
  }
  void setUnderline() {
    _channel.invokeMethod('setUnderline');
  }
  void setStrikeThrough() {
    _channel.invokeMethod('setStrikeThrough');
  }

  void setHtml() {
    _channel.invokeMethod('setHtml');
  }
  Future<String> getHtml() async {
    final String res = await _channel.invokeMethod('getHtml');
    return res;
  }
  void updateSelection(TextSelection selection) {
    _channel.invokeMethod('updateSelection', {
      'selStart': selection.baseOffset,
      'selEnd': selection.extentOffset,
    });
  }
  void formatText(int index, int len, Attribute attribute) {
    _channel.invokeMethod('formatText', {
      'attribute': attribute.uniqueKey,
      'index': index,
      'len': len,
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

}

mixin TunEditorHandler on ChangeNotifier {
  void onTextChange(
    int start, int before, int count,
    String oldText, String newText,
    String style,
  );
  void onSelectionChanged(Map<dynamic, dynamic> status);
}
