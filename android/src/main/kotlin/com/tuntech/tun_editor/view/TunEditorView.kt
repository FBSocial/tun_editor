package com.tuntech.tun_editor.view

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import com.chinalwb.are.AREditText
import com.chinalwb.are.styles.toolbar.ARE_ToolbarDefault
import com.chinalwb.are.styles.toolitems.ARE_ToolItem_Bold
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.*

internal class TunEditorView(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

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
        areEditor.addTextChangedListener(object: TextWatcher {
            override fun beforeTextChanged(
                s: CharSequence?, start: Int,
                count: Int, after: Int
            ) {
            }
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }
            override fun afterTextChanged(s: Editable?) {
                methodChannel.invokeMethod("onTextChange", s?.toString() ?: "")
            }
        })
        if (creationParams?.containsKey("place_holder") == true) {
            val placeHolder: String = (creationParams?.get("place_holder") as? String) ?: ""
            areEditor.setHint(placeHolder)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "undo" -> {
                result.success(null)
            }
            "redo" -> {
                result.success(null)
            }
            "setBold" -> {
                areToolbarItemBold.style.setChecked(!areToolbarItemBold.style.isChecked)
                result.success(null)
            }
            "getHtml" -> {
                val html = areEditor.getHtml()
                result.success(html)
            }
        }
    }

}
