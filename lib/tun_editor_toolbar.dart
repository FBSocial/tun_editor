import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:tun_editor/tun_editor_controller.dart';
import 'package:tun_editor/tun_editor_toolbar_api.dart';

class TunEditorToolbar extends StatefulWidget {

  final TunEditorController controller;

  const TunEditorToolbar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TunEditorToolbarState();

}

class TunEditorToolbarState extends State<TunEditorToolbar> {

  static const String VIEW_TYPE_TUN_EDITOR_TOOLBAR = "tun_editor_toolbar";

  TunEditorController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: VIEW_TYPE_TUN_EDITOR_TOOLBAR,
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
            viewType: VIEW_TYPE_TUN_EDITOR_TOOLBAR,
            layoutDirection: TextDirection.ltr,
            creationParams: {},
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener((int id) {
              TunEditorToolbarApi api = TunEditorToolbarApi(id, TunEditorToolbarHandlerImpl(controller));
              controller.registerTunEditorToolbarApi(api);
            })
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: VIEW_TYPE_TUN_EDITOR_TOOLBAR,
        layoutDirection: TextDirection.ltr,
        creationParams: {},
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      throw UnsupportedError("Unsupported platform view");
    }
  }

}

class TunEditorToolbarHandlerImpl extends TunEditorToolbarHandler {

  final TunEditorController _controller;

  TunEditorToolbarHandlerImpl(
    this._controller,
  );

  @override
  void undo() {
    _controller.undo();
  }

  @override
  void redo() {
    _controller.redo();
  }

  @override
  void setBold() {
    _controller.setBold();
  }

}

