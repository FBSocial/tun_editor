package com.tuntech.tun_editor.view

import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import jp.wasabeef.richeditor.RichEditor
import java.util.*

internal class TunEditorView(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    private val editor: RichEditor = RichEditor(context)

    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    override fun getView(): View {
        return editor
    }

    override fun dispose() {
    }

    init {
        methodChannel.setMethodCallHandler(this)

        if (creationParams?.containsKey("place_holder") == true) {
            editor.setPlaceholder((creationParams?.get("place_holder") as? String) ?: "")
        }
        editor.setOnTextChangeListener { text ->
            println(text)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "undo" -> {
                editor.undo()
                result.success(null)
            }
            "redo" -> {
                editor.redo()
                result.success(null)
            }
            "setBold" -> {
                editor.setBold()
                result.success(null)
            }
        }
    }

}
