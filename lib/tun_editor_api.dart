import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TunEditorApi {

  final MethodChannel _channel;
  final TunEditorHandler _handler;

  TunEditorApi(
    int id,
    this._handler,
  ) : _channel = MethodChannel("tun/editor/$id") {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<bool?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onTextChange":
        print("on text change: ${call.arguments}");
        _handler.onTextChange(call.arguments);
        break;

      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

  // Common tools.
  void undo() {
    _channel.invokeMethod("undo");
  }
  void redo() {
    _channel.invokeMethod("redo");
  }
  void clearStyle() {
    _channel.invokeMethod("clearStyle");
  }

  // Text types.
  void setHeadline1() {
    _channel.invokeMethod("setHeadline1");
  }
  void setHeadline2() {
    _channel.invokeMethod("setHeadline2");
  }
  void setHeadline3() {
    _channel.invokeMethod("setHeadline3");
  }
  void setList() {
    _channel.invokeMethod("setList");
  }
  void setOrderedList() {
    _channel.invokeMethod("setOrderedList");
  }
  void insertDivider() {
    _channel.invokeMethod("insertDivider");
  }
  void setQuote() {
    _channel.invokeMethod("setQuote");
  }
  void setCodeBlock() {
    _channel.invokeMethod("setCodeBlock");
  }

  // Text styles.
  void setBold() {
    _channel.invokeMethod("setBold");
  }
  void setItalic() {
    _channel.invokeMethod("setItalic");
  }
  void setUnderline() {
    _channel.invokeMethod("setUnderline");
  }
  void setStrikeThrough() {
    _channel.invokeMethod("setStrikeThrough");
  }

  Future<String> getHtml() async {
    final String res = await _channel.invokeMethod("getHtml");
    return res;
  }

}

mixin TunEditorHandler on ChangeNotifier {
  void onTextChange(String text);
}
