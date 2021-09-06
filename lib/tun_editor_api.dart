import 'dart:convert';

import 'package:flutter/services.dart';
// import 'package:tun_editor/models/documents/attribute.dart';
// import 'package:tun_editor/models/documents/document.dart';
// import 'package:tun_editor/models/documents/nodes/embed.dart';
// import 'package:tun_editor/models/quill_delta.dart';
import 'package:flutter_quill/flutter_quill.dart';

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
        final delta = args['delta'] as String;
        final oldDelta = args['oldDelta'] as String;
        _handler.onTextChange(delta, oldDelta);
        break;

      case 'onSelectionChange':
        try {
          final args = call.arguments as Map<dynamic, dynamic>;
          final index = args['index'] as int;
          final length = args['length'] as int;
          final format = args['format'] is String
              ? json.decode(args['format'])
              : {};
          _handler.onSelectionChange(index, length, format);
        } catch(e, s) {
          print('on selection change $e $s');
        }
        break;

      case 'onMentionClick':
        final args = call.arguments as Map<dynamic, dynamic>;
        final id = args['id'] as String;
        final prefixChar = args['prefixChar'] as String;
        final text = args['text'] as String;
        _handler.onMentionClick(id, prefixChar, text);
        break;

      case 'onLinkClick':
        final url = call.arguments as String;
        _handler.onLinkClick(url);
        break;

      case 'onFocusChange':
        final hasFocus = call.arguments as bool;
        _handler.onFocusChange(hasFocus);
        break;

      default:
        print('missing method handler in tun editor');
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

  // Content related.
  void replaceText(int index, int len, Object? data, {
    List<Attribute> attributes = const [],
    bool autoAppendNewlineAfterImage = true,
  }) {
    final Map<String, dynamic> attrMap = {};
    for (final attr in attributes) {
      attrMap[attr.key] = attr.value;
    }
    _channel.invokeMethod('replaceText', {
      'index': index,
      'len': len,
      'data': data is Embeddable ? data.toFormalJson() : data,
      'attributes': attrMap,
      'newLineAfterImage': autoAppendNewlineAfterImage,
    });
  }
  void updateContents(Delta delta, ChangeSource source) {
    _channel.invokeMethod('updateContents', {
      'delta': delta.toFormalJson(),
      'source': source == ChangeSource.LOCAL ? 'user' : 'api',
    });
  }

  // Format related.
  void setTextType(String textType) {
    _channel.invokeMethod('setTextType', textType);
  }
  void setTextStyle(List<dynamic> textStyle) {
    _channel.invokeMethod('setTextStyle', textStyle);
  }
  void format(String name, dynamic value) {
    _channel.invokeMethod('format', {
      'name': name,
      'value': value,
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

  // Selection related.
  void updateSelection(TextSelection selection) {
    _channel.invokeMethod('updateSelection', {
      'selStart': selection.baseOffset,
      'selEnd': selection.extentOffset,
    });
  }

  // Editor related.
  void focus() {
    _channel.invokeMethod('focus');
  }
  void blur() {
    _channel.invokeMethod('blur');
  }
  void scrollTo(int offset) {
    _channel.invokeMethod('scrollTo', offset);
  }
  void scrollToTop() {
    _channel.invokeMethod('scrollToTop');
  }
  void scrollToBottom() {
    _channel.invokeMethod('scrollToBottom');
  }
  void setPlaceholder(String placeholder) {
    _channel.invokeMethod('setPlaceholder', placeholder);
  }
  void setReadOnly(bool readOnly) {
    _channel.invokeMethod('setReadOnly', readOnly);
  }
  void setScrollable(bool scrollable) {
    _channel.invokeMethod('setScrollable', scrollable);
  }
  void setPadding(List<int> padding) {
    _channel.invokeMethod('setPadding', padding);
  }
  void setFileBasePath(String fileBasePath) {
    _channel.invokeMethod('setFileBasePath', fileBasePath);
  }
  void setImageStyle(Map<String, dynamic> style) {
    _channel.invokeMethod('setImageStyle', style);
  }
  void setVideoStyle(Map<String, dynamic> style) {
    _channel.invokeMethod('setVideoStyle', style);
  }
  void setPlaceholderStyle(TextStyle style) {
    final color = style.color ?? Color(0x99363940);
    final colorHex = '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}'
        '${color.alpha.toRadixString(16).padLeft(2, '0')}';

    final decoration = style.decoration ?? TextDecoration.none;
    final List<String> decorationList = [];
    if (decoration.contains(TextDecoration.underline)) {
      decorationList.add('underline');
    }
    if (decoration.contains(TextDecoration.lineThrough)) {
      decorationList.add('line-through');
    }

    final fontWeight = style.fontWeight ?? FontWeight.normal;

    final Map<String, String> args = {
      'color': colorHex,
      'text-decoration': decorationList.join(' '),
      'font-weight': '${(fontWeight.index + 1) * 100}',
      'font-style': style.fontStyle == FontStyle.italic ? 'italic' : 'normal',
    };
    _channel.invokeMethod('setPlaceholderStyle', args);
  }

}

mixin TunEditorHandler {
  Future<void> onTextChange(String delta, String oldDelta);
  void onSelectionChange(int index, int length, Map<String, dynamic> format);
  void onMentionClick(String id, String prefixChar, String text);
  void onLinkClick(String url);
  void onFocusChange(bool hasFocus);
}
