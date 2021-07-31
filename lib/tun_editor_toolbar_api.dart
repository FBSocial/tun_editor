import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef OnSelectionChanged = Function(Map status);

class TunEditorToolbarApi {

  final TunEditorToolbarHandler _handler;
  MethodChannel? _channel;
  OnSelectionChanged? _onSelectionChanged;

  TunEditorToolbarApi(
    this._handler, {
    int? viewId,
    OnSelectionChanged? onSelectionChanged,
  })  {
    if (viewId != null) {
      _channel = MethodChannel('tun/editor/toolbar/$viewId');
      _channel?.setMethodCallHandler(_onMethodCall);
    }
    if (onSelectionChanged != null) {
      _onSelectionChanged = onSelectionChanged;
    }
  }

  void onSelectionChanged(Map status) {
    _channel?.invokeMethod('onSelectionChanged', status);
    _onSelectionChanged?.call(status);
  }

  Future<bool?> _onMethodCall(MethodCall call) async {
    debugPrint('on method call: ${call.method}');
    switch (call.method) {
      // Common.
      case 'onAtClick':
        _handler.onAtClick();
        break;
      case 'onImageClick':
        _handler.onImageClick();
        break;
      case 'onEmojiClick':
        _handler.onEmojiClick();
        break;
      case 'onSubToolbarToggle':
        final bool isShow = call.arguments as bool;
        _handler.onSubToolbarToggle(isShow);
        break;
      case 'setTextType':
        _handler.setTextType(call.arguments as String);
        break;
      case 'setTextStyle':
        debugPrint('set text style');
        _handler.setTextStyle(call.arguments as List<dynamic>);
        break;
      case 'insertDivider':
        _handler.insertDivider();
        break;

      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

}

mixin TunEditorToolbarHandler on ChangeNotifier {

  void onAtClick();
  void onImageClick();
  void onEmojiClick();
  void onSubToolbarToggle(bool isShow);
  void setTextType(String textType);
  void setTextStyle(List<dynamic> textStyle);
  void insertDivider();

}
