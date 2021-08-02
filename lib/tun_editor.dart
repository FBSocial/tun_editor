import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tun_editor/tun_editor_controller.dart';

class TunEditor extends StatefulWidget {

  final TunEditorController controller;
  final String placeholder;

  final bool readOnly;

  final EdgeInsets padding;

  final bool autoFocus;
  final FocusNode? focusNode;

  final ScrollController? scrollController;

  const TunEditor({
    Key? key,
    required this.controller,
    this.placeholder = "",
    this.readOnly = false,
    this.padding = const EdgeInsets.symmetric(
      vertical: 15,
      horizontal: 12,
    ),
    this.autoFocus = false,
    this.focusNode,
    this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TunEditorState();

}

class TunEditorState extends State<TunEditor> {

  static const String VIEW_TYPE_TUN_EDITOR = "tun_editor";

  // Widget fields.
  TunEditorController get controller => widget.controller;
  String get placeholder => widget.placeholder;
  bool get readOnly => widget.readOnly;
  EdgeInsets get padding => widget.padding;
  bool get autoFocus => widget.autoFocus;
  FocusNode? get focusNode => widget.focusNode;
  ScrollController? get scrollController => widget.scrollController;
  
  @override
  void initState() {
    super.initState();
  
    if (autoFocus) {
      focusNode?.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> creationParams = {
      'placeholder': placeholder,
      'readOnly': readOnly,
      'padding': [
        padding.top.toInt(),
        padding.right.toInt(),
        padding.bottom.toInt(),
        padding.left.toInt(),
      ],
      'autoFocus': autoFocus,
    };

    if (Platform.isAndroid) {
      // Android platform.
      return Focus(
        focusNode: focusNode,
        canRequestFocus: true,
        onFocusChange: (bool hasFocus) {
          debugPrint('on focus changed: $hasFocus');
          if (hasFocus) {
            controller.focus();
          } else {
            controller.blur();
          }
        },
        child: PlatformViewLink(
          viewType: VIEW_TYPE_TUN_EDITOR,
          surfaceFactory: (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: {},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
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
                controller.attachTunEditor(id);
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
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          controller.attachTunEditor(id);
        },
      );
    } else {
      throw UnsupportedError("Unsupported platform view");
    }
  }

  @override
  void dispose() {
    controller.detachTunEditorToolbar();
  
    super.dispose();
  }

}
