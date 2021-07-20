import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tun_editor/tun_editor_api.dart';
import 'package:tun_editor/tun_editor_controller.dart';

class TunEditor extends StatefulWidget {

  final TunEditorController controller;
  final String defaultText;
  final String placeHolder;

  const TunEditor({
    Key? key,
    required this.controller,
    this.defaultText = "",
    this.placeHolder = "",
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TunEditorState();

}

class TunEditorState extends State<TunEditor> {

  static const String VIEW_TYPE_TUN_EDITOR = "tun_editor";

  // Creation param keys.
  static const String CREATION_PARAM_PLACERHOLDER = "place_holder";
  static const String CREATION_PARAM_DEFAULT_TEXT = "default_text";

  // Widget fields.
  TunEditorController get controller => widget.controller;
  String get defaultText => widget.defaultText;
  String get placeHolder => widget.placeHolder;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> creationParams = {
      CREATION_PARAM_PLACERHOLDER: placeHolder,
      CREATION_PARAM_DEFAULT_TEXT: defaultText,
    };

    if (Platform.isAndroid) {
      // Android platform.
      return PlatformViewLink(
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
              TunEditorApi api = TunEditorApi(id, TunEditorHandlerImpl());
              controller.registerTunEditorApi(api);
            })
            ..create();
        },
      );

    } else if (Platform.isIOS) {
      // IOS platform.
      return UiKitView(
        viewType: VIEW_TYPE_TUN_EDITOR,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      throw UnsupportedError("Unsupported platform view");
    }
  }

}

class TunEditorHandlerImpl extends TunEditorHandler {

}
