import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:tun_editor/tun_editor_controller.dart';

class TunEditorToolbar extends StatefulWidget {

  final TunEditorController controller;

  static double get fixedToolbarHeight => TunEditorToolbarState.TOOLBAR_HEIGHT_WITHOUT_SUB;

  const TunEditorToolbar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TunEditorToolbarState();

}

class TunEditorToolbarState extends State<TunEditorToolbar> {

  static const String VIEW_TYPE_TUN_EDITOR_TOOLBAR = "tun_editor_toolbar";
  static const double TOOLBAR_HEIGHT_WITHOUT_SUB = 48;
  static const double TOOLBAR_HEIGHT_WITH_SUB = 100;

  TunEditorController get controller => widget.controller;

  double toolbarHeight = TOOLBAR_HEIGHT_WITHOUT_SUB;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (Platform.isAndroid) {
      child = PlatformViewLink(
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
              controller.attachTunEditorToolbar(id);
            })
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      child = UiKitView(
        viewType: VIEW_TYPE_TUN_EDITOR_TOOLBAR,
        layoutDirection: TextDirection.ltr,
        creationParams: {},
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      throw UnsupportedError("Unsupported platform view");
    }

    return SizedBox(
      height: TOOLBAR_HEIGHT_WITH_SUB,
      child: child,
    );
  }

}
