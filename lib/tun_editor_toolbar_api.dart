import 'package:flutter/services.dart';

class TunEditorToolbarApi {

  final MethodChannel _channel;
  final TunEditorToolbarHandler _handler;

  TunEditorToolbarApi(
    int id,
    this._handler
  ) : _channel = MethodChannel("tun/editor/toolbar/$id") {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<bool?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case "undo":
        _handler.undo();
        break;

      case "redo":
        _handler.redo();
        break;

      case "setBold":
        _handler.setBold();
        break;

      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

}

abstract class TunEditorToolbarHandler {

  void undo();
  void redo();
  void setBold();

}
