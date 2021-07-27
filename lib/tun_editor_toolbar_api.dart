import 'package:flutter/foundation.dart';
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

  void onSelectionChanged(Map status) {
    _channel.invokeMethod("onSelectionChanged", status);
  }

  Future<bool?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      // Common.
      case "undo":
        _handler.undo();
        break;
      case "redo":
        _handler.redo();
        break;
      case "clearStyle":
        _handler.clearStyle();
        break;
      case "onAtClick":
        _handler.testInsertAt();
        break;

      // Text types.
      case "setHeadline1":
        _handler.setHeadline1();
        break;
      case "setHeadline2":
        _handler.setHeadline2();
        break;
      case "setHeadline3":
        _handler.setHeadline3();
        break;
      case "setList":
        _handler.setList();
        break;
      case "setOrderedList":
        _handler.setOrderedList();
        break;
      case "insertDivider":
        _handler.insertDivider();
        break;
      case "setQuote":
        _handler.setQuote();
        break;
      case "setCodeBlock":
        _handler.setCodeBlock();
        break;

      // Text styles.
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
  void clearStyle();
  void testInsertAt();

  void setHeadline1();
  void setHeadline2();
  void setHeadline3();
  void setList();
  void setOrderedList();
  void insertDivider();
  void setQuote();
  void setCodeBlock();

  void setBold();
  void setItalic();
  void setUnderline();
  void setStrikeThrough();

  void onSubToolbarToggle(bool isShow);

}
