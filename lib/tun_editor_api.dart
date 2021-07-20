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

}

abstract class TunEditorHandler {
}
