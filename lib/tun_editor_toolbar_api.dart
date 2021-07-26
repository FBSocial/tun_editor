import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tun_editor/tun_editor_value.dart';

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
      case "setItalic":
        _handler.setItalic();
        break;
      case "setUnderline":
        _handler.setUnderline();
        break;
      case "setStrikeThrough":
        _handler.setStrikeThrough();
        break;
      case "setHeadline1":
        _handler.setHeadline1();
        break;
      case "setHeadline2":
        _handler.setHeadline2();
        break;
      case "setHeadline3":
        _handler.setHeadline3();
        break;
      case "clearStyle":
        _handler.clearStyle();
        break;
      case "insertDivider":
        _handler.insertDivider();
        break;
      case "onSubToolbarToggle":
        final bool isShow = call.arguments as bool;
        _handler.onSubToolbarToggle(isShow);
        break;

      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

}

mixin TunEditorToolbarHandler on ChangeNotifier {

  void undo();
  void redo();

  void setBold();
  void setItalic();
  void setUnderline();
  void setStrikeThrough();
  void setHeadline1();
  void setHeadline2();
  void setHeadline3();
  void insertDivider();
  void clearStyle();

  void onSubToolbarToggle(bool isShow);

}
