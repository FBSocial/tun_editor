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

  void undo() {
    _channel.invokeMethod("undo");
  }
  void redo() {
    _channel.invokeMethod("redo");
  }

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
  void setHeadline1() {
    _channel.invokeMethod("setHeadline1");
  }
  void setHeadline2() {
    _channel.invokeMethod("setHeadline2");
  }
  void setHeadline3() {
    _channel.invokeMethod("setHeadline3");
  }
  void insertDivider() {
    _channel.invokeMethod("insertDivider");
  }
  void clearStyle() {
    _channel.invokeMethod("clearStyle");
  }

  Future<String> getHtml() async {
    final String res = await _channel.invokeMethod("getHtml");
    return res;
  }

}

mixin TunEditorHandler on ChangeNotifier {
  void onTextChange(String text);
}
