package com.tuntech.tun_editor.view

import android.content.Context
import android.view.View
import android.widget.EditText
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView


internal class EditTextView(
    val context: Context,
    id: Int,
    creationParams: Map<String, Any?>?,
    messenger: BinaryMessenger
) : PlatformView {

    // View.
    private var editText: EditText = EditText(context)

    init {
        editText.hint = "Native edit text"
    }

    override fun getView(): View {
        return editText
    }

    override fun dispose() {
    }

}
