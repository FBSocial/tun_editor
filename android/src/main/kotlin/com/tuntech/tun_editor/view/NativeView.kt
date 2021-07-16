package com.tuntech.tun_editor.view

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.EditText
import io.flutter.plugin.platform.PlatformView

internal class NativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {

    private val textView: EditText = EditText(context)

    override fun getView(): View {
        return textView
    }

    override fun dispose() {}

    init {
        textView.textSize = 24f
        println("create params: ${creationParams?.keys}, ${creationParams?.values}")
        textView.setBackgroundColor(Color.rgb(255, 255, 255))
        textView.setText("Rendered on a native Android view (id: $id)")
        textView.setTextColor(Color.RED)
    }
}
