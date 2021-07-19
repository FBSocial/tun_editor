
import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TunEditor {

  static const String VIEW_TYPE_TUN_EDITOR = "tun_editor";
  static const String VIEW_TYPE_TUN_EDITOR_TOOLBAR = "tun_editor_toolbar";

  static const MethodChannel _channel =
      const MethodChannel('tun_editor');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Widget buildEditor() {
    if (Platform.isAndroid) {
      // return AndroidView(
      //   viewType: VIEW_TYPE_TUN_EDITOR,
      //   layoutDirection: TextDirection.ltr,
      //   creationParams: {
      //     "title": "Hello World",
      //   },
      //   creationParamsCodec: StandardMessageCodec(),
      // );
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
            creationParams: {},
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: VIEW_TYPE_TUN_EDITOR,
        layoutDirection: TextDirection.ltr,
        creationParams: {},
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      throw UnsupportedError("Unsupported platform view");
    }
  }

  static Widget toolbar() {
    if (Platform.isAndroid) {
      // return AndroidView(
      //   viewType: VIEW_TYPE_TUN_EDITOR,
      //   layoutDirection: TextDirection.ltr,
      //   creationParams: {
      //     "title": "Hello World",
      //   },
      //   creationParamsCodec: StandardMessageCodec(),
      // );
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
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: VIEW_TYPE_TUN_EDITOR,
        layoutDirection: TextDirection.ltr,
        creationParams: {},
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      throw UnsupportedError("Unsupported platform view");
    }
  }

}
