package com.tuntech.tun_editor

import android.content.Context
import com.tuntech.tun_editor.view.ToolbarView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ToolbarViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return ToolbarView(context, viewId, creationParams)
    }
}
