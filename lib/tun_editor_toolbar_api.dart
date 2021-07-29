import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TunEditorToolbarApi {

  final MethodChannel _channel;
  final TunEditorToolbarHandler _handler;

  TunEditorToolbarApi(
    int id,
    this._handler
  ) : _channel = MethodChannel('tun/editor/toolbar/$id') {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  void onSelectionChanged(Map status) {
    _channel.invokeMethod('onSelectionChanged', status);
  }

  Future<bool?> _onMethodCall(MethodCall call) async {
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
        _handler.setTextStyle(call.arguments as List<dynamic>);
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

}
