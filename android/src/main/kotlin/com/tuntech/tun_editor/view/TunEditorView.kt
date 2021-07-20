package com.tuntech.tun_editor.view

import android.content.Context
import android.view.View
import com.chinalwb.are.AREditText
import com.chinalwb.are.styles.toolbar.ARE_ToolbarDefault
import com.chinalwb.are.styles.toolitems.ARE_ToolItem_Bold
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
    private val areEditor: AREditText = AREditText(context)
    private val areToolbar: ARE_ToolbarDefault = ARE_ToolbarDefault(context)
    private val areToolbarItemBold: ARE_ToolItem_Bold = ARE_ToolItem_Bold()

    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    override fun getView(): View {
        return areEditor
    }

    override fun dispose() {
    }

    init {
        methodChannel.setMethodCallHandler(this)

        areToolbar.addToolbarItem(areToolbarItemBold)
        areEditor.setToolbar(areToolbar)
        if (creationParams?.containsKey("place_holder") == true) {
            val placeHolder: String = (creationParams?.get("place_holder") as? String) ?: ""
            editor.setPlaceholder(placeHolder)
            areEditor.setHint(placeHolder)
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
                areToolbarItemBold.style.setChecked(!areToolbarItemBold.style.isChecked)
            }
        }
    }

}
