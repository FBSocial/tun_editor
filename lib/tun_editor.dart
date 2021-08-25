import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tun_editor/models/documents/attribute.dart';
import 'package:tun_editor/models/quill_delta.dart';
import 'package:tun_editor/tun_editor_api.dart';
import 'package:tun_editor/controller.dart';

typedef MentionClickCallback = Function(String, String, String);
typedef LinkClickCallback = Function(String);

class TunEditor extends StatefulWidget {

  final TunEditorController controller;
  final String placeholder;

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
  
    if (autoFocus) {
      focusNode?.requestFocus();
    }
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
      if (creationParams.containsKey('placeholder')
          && creationParams['placeholder'] != placeholder) {
        _tunEditorApi?.setPlaceholder(placeholder);
        creationParams['placeholder'] = placeholder;
      }
      if (creationParams.containsKey('readOnly')
          && creationParams['readOnly'] != readOnly) {
        _tunEditorApi?.setReadOnly(readOnly);
        creationParams['readOnly'] = readOnly;
      }
      if (creationParams.containsKey('scrollable')
          && creationParams['scrollable'] != scrollable) {
        _tunEditorApi?.setScrollable(scrollable);
        creationParams['scrollable'] = scrollable;
      }
      if (creationParams.containsKey('padding')
          && !listEquals(creationParams['padding'], paddingList)) {
        _tunEditorApi?.setPadding(paddingList);
        creationParams['padding'] = paddingList;
      }
      if (creationParams.containsKey('fileBasePath')
          && creationParams['fileBasePath'] != fileBasePath) {
        _tunEditorApi?.setFileBasePath(fileBasePath);
        creationParams['fileBasePath'] = fileBasePath;
      }
      if (creationParams.containsKey('imageStyle')
          && !mapEquals(creationParams['imageStyle'], imageStyle)) {
        _tunEditorApi?.setImageStyle(imageStyle);
        creationParams['imageStyle'] = imageStyle;
      }
      if (creationParams.containsKey('videoStyle')
          && !mapEquals(creationParams['videoStyle'], videoStyle)) {
        _tunEditorApi?.setVideoStyle(videoStyle);
        creationParams['videoStyle'] = videoStyle;
      }
    } else {
      creationParams = {
        'fileBasePath': fileBasePath,
        'placeholder': placeholder,
        'readOnly': readOnly,
        'scrollable': scrollable,
        'padding': paddingList,
        'autoFocus': autoFocus,
        'delta': controller.document.toDelta().toJson(),
        'imageStyle': imageStyle,
        'videoStyle': videoStyle,
      };
    }

    if (Platform.isAndroid) {
      // Android platform.
      return Focus(
        focusNode: focusNode,
        canRequestFocus: true,
        onFocusChange: _handleFocusChange,
        child: PlatformViewLink(
          viewType: VIEW_TYPE_TUN_EDITOR,
          surfaceFactory: (BuildContext context, PlatformViewController controller) {
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
        ),
      );

    } else if (Platform.isIOS) {
      // IOS platform.
      return UiKitView(
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
    String delta, String oldDelta,
  ) async {
    final deltaMap = json.decode(delta) as Map;
    if (deltaMap['ops'] is List<dynamic>) {
      final deltaList = deltaMap['ops'] as List<dynamic>;
      final deltaObj = Delta.fromJson(deltaList);
      if (deltaObj.isNotEmpty) {
        controller.composeDocument(deltaObj);
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

  void _handleFocusChange(bool hasFocus) {
    if (hasFocus != _isFocused) {
      _isFocused = focusNode!.hasFocus;
      if (focusNode!.hasFocus) {
        _tunEditorApi?.focus();
      } else {
        _tunEditorApi?.blur();
      }
    }
  }

}
