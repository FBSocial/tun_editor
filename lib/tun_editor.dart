import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/documents/document.dart';
import 'package:tun_editor/models/quill_delta.dart';
import 'package:tun_editor/tun_editor_api.dart';
import 'package:tun_editor/controller.dart';

typedef MentionClickCallback = Function(String, String, String);
typedef LinkClickCallback = Function(String);

class TunEditor extends StatefulWidget {
  final TunEditorController controller;

  /// [placehodler] will show if document is empty.
  final String placeholder;

  /// [placeholderStyle] custom [placeholder] text style.
  final TextStyle? placeholderStyle;

  final bool readOnly;
  final bool scrollable;

  final EdgeInsets padding;

  final bool autoFocus;
  final FocusNode? focusNode;

  // File base path is used to load local image.
  final String fileBasePath;

  /// Image and video style. Same as [Attribute]'s rule.
  /// Support [WidthAttribute], [HeightAttribute] and [AlignAttribute].
  final Map<String, dynamic> imageStyle;
  final Map<String, dynamic> videoStyle;

  /// Mention click callback, first param is [id], next is [prefixChar],
  /// And the last is [text].
  final MentionClickCallback? onMentionClick;
  final LinkClickCallback? onLinkClick;

  const TunEditor({
    Key? key,
    required this.controller,
    required this.fileBasePath,
    this.imageStyle = const {},
    this.videoStyle = const {},
    this.placeholder = '',
    this.placeholderStyle,
    this.readOnly = false,
    this.scrollable = true,
    this.padding = const EdgeInsets.symmetric(
      vertical: 15,
      horizontal: 12,
    ),
    this.autoFocus = false,
    this.focusNode,
    this.onMentionClick,
    this.onLinkClick,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TunEditorState();
}

class TunEditorState extends State<TunEditor> with TunEditorHandler {
  static const String VIEW_TYPE_TUN_EDITOR = 'tun_editor';

  // Widget fields.
  TunEditorController get controller => widget.controller;
  String get fileBasePath => widget.fileBasePath;
  Map<String, dynamic> get imageStyle => widget.imageStyle;
  Map<String, dynamic> get videoStyle => widget.videoStyle;
  String get placeholder => widget.placeholder;
  TextStyle? get placeholderStyle => widget.placeholderStyle;
  Map<String, String> get placeholderStyleMap {
    if (placeholderStyle == null) {
      return {};
    }
    final color = placeholderStyle!.color ?? Color(0x99363940);
    final colorHex = '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}'
        '${color.alpha.toRadixString(16).padLeft(2, '0')}';

    final decoration = placeholderStyle!.decoration ?? TextDecoration.none;
    final List<String> decorationList = [];
    if (decoration.contains(TextDecoration.underline)) {
      decorationList.add('underline');
    }
    if (decoration.contains(TextDecoration.lineThrough)) {
      decorationList.add('line-through');
    }

    final fontWeight = placeholderStyle!.fontWeight ?? FontWeight.normal;

    return {
      'color': colorHex,
      'text-decoration': decorationList.join(' '),
      'font-weight': '${(fontWeight.index + 1) * 100}',
      'font-style':
          placeholderStyle!.fontStyle == FontStyle.italic ? 'italic' : 'normal',
    };
  }

  bool get readOnly => widget.readOnly;
  bool get scrollable => widget.scrollable;
  EdgeInsets get padding => widget.padding;
  bool get autoFocus => widget.autoFocus;
  FocusNode? get focusNode => widget.focusNode;
  MentionClickCallback? get mentionClickCallback => widget.onMentionClick;
  LinkClickCallback? get linkClickCallback => widget.onLinkClick;

  TunEditorApi? _tunEditorApi;

  Map<String, dynamic> creationParams = {};

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _isFocused = autoFocus;
  }

  @override
  Widget build(BuildContext context) {
    final paddingList = [
      padding.top.toInt(),
      padding.right.toInt(),
      padding.bottom.toInt(),
      padding.left.toInt(),
    ];
    if (_tunEditorApi != null) {
      if (creationParams.containsKey('placeholder') &&
          creationParams['placeholder'] != placeholder) {
        _tunEditorApi?.setPlaceholder(placeholder);
        creationParams['placeholder'] = placeholder;
      }
      if (creationParams.containsKey('readOnly') &&
          creationParams['readOnly'] != readOnly) {
        _tunEditorApi?.setReadOnly(readOnly);
        creationParams['readOnly'] = readOnly;
      }
      if (creationParams.containsKey('scrollable') &&
          creationParams['scrollable'] != scrollable) {
        _tunEditorApi?.setScrollable(scrollable);
        creationParams['scrollable'] = scrollable;
      }
      if (creationParams.containsKey('padding') &&
          !listEquals(creationParams['padding'], paddingList)) {
        _tunEditorApi?.setPadding(paddingList);
        creationParams['padding'] = paddingList;
      }
      if (creationParams.containsKey('fileBasePath') &&
          creationParams['fileBasePath'] != fileBasePath) {
        _tunEditorApi?.setFileBasePath(fileBasePath);
        creationParams['fileBasePath'] = fileBasePath;
      }
      if (creationParams.containsKey('imageStyle') &&
          !mapEquals(creationParams['imageStyle'], imageStyle)) {
        _tunEditorApi?.setImageStyle(imageStyle);
        creationParams['imageStyle'] = imageStyle;
      }
      if (creationParams.containsKey('videoStyle') &&
          !mapEquals(creationParams['videoStyle'], videoStyle)) {
        _tunEditorApi?.setVideoStyle(videoStyle);
        creationParams['videoStyle'] = videoStyle;
      }
      if (creationParams.containsKey('placeholderStyle') &&
          !mapEquals(creationParams['placeholderStyle'], placeholderStyleMap)) {
        if (placeholderStyle != null) {
          _tunEditorApi?.setPlaceholderStyle(placeholderStyle!);
          creationParams['placeholderStyle'] = placeholderStyleMap;
        }
      }
    } else {
      creationParams = {
        'fileBasePath': fileBasePath,
        'placeholder': placeholder,
        'readOnly': readOnly,
        'scrollable': scrollable,
        'padding': paddingList,
        'autoFocus': autoFocus,
        'delta': controller.document.toDelta().toFormalJson(),
        'imageStyle': imageStyle,
        'videoStyle': videoStyle,
        'placeholderStyle': placeholderStyleMap,
      };
    }

    Widget child;
    if (Platform.isAndroid) {
      // Android platform.
      child = PlatformViewLink(
        viewType: VIEW_TYPE_TUN_EDITOR,
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: {},
            hitTestBehavior: PlatformViewHitTestBehavior.translucent,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: VIEW_TYPE_TUN_EDITOR,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener((int id) {
              _tunEditorApi = TunEditorApi(id, this);
              controller.setTunEditorApi(_tunEditorApi);
            })
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      // IOS platform.
      child = UiKitView(
        viewType: VIEW_TYPE_TUN_EDITOR,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          _tunEditorApi = TunEditorApi(id, this);
          controller.setTunEditorApi(_tunEditorApi);
        },
      );
    } else {
      throw UnsupportedError('Unsupported platform view');
    }
    return Focus(
      focusNode: focusNode,
      canRequestFocus: true,
      onFocusChange: _handleFocusChange,
      child: child,
    );
  }

  @override
  void dispose() {
    focusNode?.dispose();
    controller.setTunEditorApi(null);
    controller.dispose();

    super.dispose();
  }

  @override
  Future<void> onTextChange(
    String delta,
    String oldDelta,
  ) async {
    final deltaMap = json.decode(delta) as Map;
    final oldDeltaMap = json.decode(oldDelta) as Map;
    if (deltaMap['ops'] is List<dynamic> &&
        oldDeltaMap['ops'] is List<dynamic>) {
      final deltaList = deltaMap['ops'] as List<dynamic>;
      final deltaObj = Delta.fromJson(deltaList);
      final oldDeltaList = oldDeltaMap['ops'] as List<dynamic>;
      final oldDeltaObj = Delta.fromJson(oldDeltaList);

      if (deltaObj.isNotEmpty) {
        controller.document
            .refreshDocument(deltaObj, oldDeltaObj, ChangeSource.LOCAL);
      }
    }
  }

  @override
  void onSelectionChange(int index, int length, Map<String, dynamic> format) {
    controller.syncSelection(index, length, format);
  }

  @override
  void onMentionClick(String id, String prefixChar, String text) {
    mentionClickCallback?.call(id, prefixChar, text);
  }

  @override
  void onLinkClick(String url) {
    linkClickCallback?.call(url);
  }

  @override
  void onFocusChange(bool hasFocus) {
    _isFocused = hasFocus;
    if (hasFocus) {
      focusNode?.requestFocus();
    } else {
      focusNode?.unfocus();
    }
  }

  @override
  void onPageLoaded() {
    if (_isFocused) {
      _tunEditorApi?.focus();
      _tunEditorApi?.updateSelection(controller.selection);
    } else {
      _tunEditorApi?.updateSelection(controller.selection);
      _tunEditorApi?.blur();
    }
  }

  void _handleFocusChange(bool hasFocus) {
    debugPrint('handle focus change $hasFocus');
    controller.syncFocus(hasFocus);
    if (hasFocus != _isFocused) {
      _isFocused = hasFocus;
      if (hasFocus) {
        _tunEditorApi?.focus();
      } else {
        _tunEditorApi?.blur();
      }
    }
  }
}
