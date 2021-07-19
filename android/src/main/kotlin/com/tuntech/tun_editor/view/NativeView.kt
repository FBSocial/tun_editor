package com.tuntech.tun_editor.view

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import jp.wasabeef.richeditor.RichEditor

internal class NativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {

    private val editor: View = RichEditor(context)

    override fun getView(): View {
        return editor
    }

    override fun dispose() {
    }

    init {
      println("init native view")
    }
}
