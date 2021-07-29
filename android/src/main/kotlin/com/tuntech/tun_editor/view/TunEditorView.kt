package com.tuntech.tun_editor.view

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.ScrollView
import com.tuntech.tun_editor.utils.SelectionUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.*
import kotlin.collections.ArrayList

internal class TunEditorView(
    context: Context,
    id: Int,
    creationParams: Map<String, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        const val INVOKE_METHOD_ON_TEXT_CHANGE = "onTextChange"
        const val INVOKE_METHOD_ON_SELECTION_CHANGED = "onSelectionChanged"

        const val HANDLE_METHOD_UNDO = "undo"
        const val HANDLE_METHOD_REDO = "redo"
        const val HANDLE_METHOD_CLEAR_TEXT_TYPE = "clearTextType"
        const val HANDLE_METHOD_CLEAR_TEXT_STYLE = "clearTextStyle"
        const val HANDLE_METHOD_SET_TEXT_TYPE = "setTextType"
        const val HANDLE_METHOD_SET_TEXT_STYLE = "setTextStyle"
        const val HANDLE_METHOD_UPDATE_SELECTION = "updateSelection"
        const val HANDLE_METHOD_FORMAT_TEXT = "formatText"
        const val HANDLE_METHOD_REPLACE_TEXT = "replaceText"
        const val HANDLE_METHOD_INSERT = "insert"
        const val HANDLE_METHOD_INSERT_IMAGE = "insertImage"
    }

    // View.
    private val scrollView: ScrollView = ScrollView(context)
    private val areEditor: Editor = Editor(context)

    // Method channel.
    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    private var currentStyle: String = ""

    // Text watcher related.
    private var oldText: String = ""

    override fun getView(): View {
        return scrollView
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    init {
        scrollView.isFillViewport = true
        scrollView.addView(areEditor)

        methodChannel.setMethodCallHandler(this)

        areEditor.addTextChangedListener(object: TextWatcher {
            override fun beforeTextChanged(
                s: CharSequence?, start: Int,
                count: Int, after: Int
            ) {
                oldText = s?.toString() ?: ""
            }
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val args = HashMap<String, Any>()
                args["start"] = start
                args["before"] = before
                args["count"] = count
                args["oldText"] = oldText
                args["newText"] = s?.toString() ?: ""
                args["style"] = currentStyle
                methodChannel.invokeMethod(INVOKE_METHOD_ON_TEXT_CHANGE, args)
            }
            override fun afterTextChanged(s: Editable?) {
            }
        })
        areEditor.setOnSelectionChanged { selStart, selEnd ->
            val res = SelectionUtil.checkSelectionStyle(areEditor.editableText, selStart, selEnd)
            currentStyle = res["style"] as? String ?: ""
            println("on selection changed $selStart, $selEnd: $currentStyle")
            methodChannel.invokeMethod(INVOKE_METHOD_ON_SELECTION_CHANGED, res)
        }
        if (creationParams?.containsKey("place_holder") == true) {
            val placeHolder: String = (creationParams["place_holder"] as? String) ?: ""
            areEditor.hint = placeHolder
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Common tools.
            HANDLE_METHOD_UNDO -> {
                result.success(null)
            }
            HANDLE_METHOD_REDO -> {
                result.success(null)
            }
            HANDLE_METHOD_CLEAR_TEXT_TYPE -> {
                areEditor.clearTextType()
                result.success(null)
            }
            HANDLE_METHOD_CLEAR_TEXT_STYLE -> {
                areEditor.clearTextStyle()
                result.success(null)
            }
            HANDLE_METHOD_SET_TEXT_TYPE -> {
                val textType: String = call.arguments as? String ?: Editor.TEXT_TYPE_NORMAL
                areEditor.setTextType(textType)
                result.success(null)
            }
            HANDLE_METHOD_SET_TEXT_STYLE -> {
                val textStyle: List<String> = (call.arguments as? List<*> ?: ArrayList<String>()).map {
                    return@map it as String? ?: ""
                }
                areEditor.setTextStyle(textStyle)
                result.success(null)
            }
            HANDLE_METHOD_UPDATE_SELECTION -> {
                val args = call.arguments as? Map<*, *> ?: return
                val selStart = args["selStart"] as? Int ?: 0
                val selEnd = args["selEnd"] as? Int ?: 0
                areEditor.setSelection(selStart, selEnd)
                result.success(null)
            }
            HANDLE_METHOD_FORMAT_TEXT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val attr = args["attribute"] as? String ?: return
                var index = args["index"] as? Int ?: 0
                var len = args["len"] as? Int ?: 0
                if (index < 0) {
                    index = 0
                }
                if (len > areEditor.length()) {
                    len = areEditor.length()
                }
                areEditor.formatText(attr, index, len)
                result.success(null)
            }
            HANDLE_METHOD_REPLACE_TEXT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val index = args["index"] as? Int ?: 0
                val len = args["len"] as? Int ?: 0
                val data = args["data"] as? String ?: ""
                val ignoreFocus = args["ignoreFocus"] as Boolean? ?: false
                val autoAppendNewLineAfterImage = args["autoAppendNewLineAfterImage"] as Boolean? ?: true
                if (index > areEditor.length()) {
                    return
                }
                areEditor.text =
                    areEditor.editableText.replace(index, index + len, data)
                result.success(null)
            }
            HANDLE_METHOD_INSERT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val index = args["index"] as? Int ?: 0
                val data = args["data"] as? String ?: ""
                val replaceLength = args["replaceLength"] as? Int ?: 0
                val autoAppendNewLineAfterImage = args["autoAppendNewLineAfterImage"] as Boolean? ?: true

                if (index > areEditor.length()) {
                    return
                }
                if (replaceLength > 0) {
                    areEditor.text =
                        areEditor.editableText.replace(index, index + replaceLength, data)
                } else {
                    areEditor.text = areEditor.editableText.insert(index, data)
                }
                println("new text: ${areEditor.text} $index $data")
                result.success(null)
            }
            HANDLE_METHOD_INSERT_IMAGE -> {
                // TODO Insert image.
            }

            else -> {
                println("missing plugin method: ${call.method}")
                result.notImplemented()
            }
        }
    }

}