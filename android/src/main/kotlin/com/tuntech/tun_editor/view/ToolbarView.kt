package com.tuntech.tun_editor.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import com.tuntech.tun_editor.R
import io.flutter.plugin.platform.PlatformView

internal class ToolbarView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {

    private val toolbar: View = LayoutInflater.from(context).inflate(R.layout.editor_toolbar, null)


    override fun getView(): View {
        return toolbar
    }

    override fun dispose() {
    }

    init {
      println("init toolbar view")
    }
}
