import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class EditText extends StatefulWidget {
  const EditText({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditTextState();
}

class EditTextState extends State<EditText> {
  static const String VIEW_TYPE_EDIT_TEXT = 'edit_text';
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: VIEW_TYPE_EDIT_TEXT,
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
            viewType: VIEW_TYPE_EDIT_TEXT,
            layoutDirection: TextDirection.ltr,
            creationParams: {},
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener((int id) {
            })
            ..create();
        },
      );
    } else {
      return UiKitView(
        viewType: VIEW_TYPE_EDIT_TEXT,
        layoutDirection: TextDirection.ltr,
        creationParams: {},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
        },
      );
    }
  }
}
