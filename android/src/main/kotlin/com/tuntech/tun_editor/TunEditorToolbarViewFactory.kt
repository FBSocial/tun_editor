package com.tuntech.tun_editor

import android.content.Context
import com.tuntech.tun_editor.view.TunEditorToolbarView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class TunEditorToolbarViewFactory(
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return TunEditorToolbarView(context, viewId, creationParams, messenger)
    }
}
