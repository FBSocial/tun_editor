package com.tuntech.tun_editor

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformViewRegistry

/** TunEditorPlugin */
class TunEditorPlugin: FlutterPlugin {

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    val messenger = binding.binaryMessenger

    val registry: PlatformViewRegistry = binding.platformViewRegistry
    registry.registerViewFactory("tun_editor", TunEditorViewFactory(messenger))
    registry.registerViewFactory("tun_editor_toolbar", TunEditorToolbarViewFactory(messenger))
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
