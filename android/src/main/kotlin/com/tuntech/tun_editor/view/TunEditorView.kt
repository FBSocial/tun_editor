package com.tuntech.tun_editor.view

import android.content.Context
import android.util.Log
import android.view.View
import com.tuntech.tun_editor.TextCons
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

internal class TunEditorView(
    val context: Context,
    id: Int,
    creationParams: Map<String, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        const val INVOKE_METHOD_ON_TEXT_CHANGE = "onTextChange"
        const val INVOKE_METHOD_ON_SELECTION_CHANGED = "onSelectionChanged"
        const val INVOKE_METHOD_ON_FOCUS_CHANGED = "onFocusChanged"

        const val HANDLE_METHOD_UNDO = "undo"
        const val HANDLE_METHOD_REDO = "redo"
        const val HANDLE_METHOD_FOCUS = "focus"
        const val HANDLE_METHOD_BLUR = "blur"
        const val HANDLE_METHOD_CLEAR_TEXT_TYPE = "clearTextType"
        const val HANDLE_METHOD_CLEAR_TEXT_STYLE = "clearTextStyle"
        const val HANDLE_METHOD_SET_TEXT_TYPE = "setTextType"
        const val HANDLE_METHOD_SET_TEXT_STYLE = "setTextStyle"
        const val HANDLE_METHOD_UPDATE_SELECTION = "updateSelection"
        const val HANDLE_METHOD_FORMAT_TEXT = "formatText"
        const val HANDLE_METHOD_REPLACE_TEXT = "replaceText"
        const val HANDLE_METHOD_INSERT = "insert"
        const val HANDLE_METHOD_INSERT_DIVIDER = "insertDivider"
        const val HANDLE_METHOD_INSERT_IMAGE = "insertImage"
    }

    // View.
    private lateinit var quillEditor: QuillEditor

    // Method channel.
    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    override fun getView(): View {
        return quillEditor
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    init {
        var placeholder = ""
        var padding: List<Int> = listOf(12, 15, 12, 15)
        var autoFocus = false
        var readOnly = false
        var delta: List<*> = listOf<Map<String, Any>>()
        if (creationParams?.containsKey("placeholder") == true) {
            placeholder = (creationParams["placeholder"] as? String) ?: ""
        }
        if (creationParams?.containsKey("padding") == true) {
            padding = (creationParams["padding"] as? List<*>)?.map {
                return@map it as? Int ?: 0
            } ?: listOf()
        }
        if (creationParams?.containsKey("autoFocus") == true) {
            autoFocus = (creationParams["autoFocus"] as? Boolean) ?: false
        }
        if (creationParams?.containsKey("readOnly") == true) {
            readOnly = (creationParams["readOnly"] as? Boolean) ?: false
        }
        if (creationParams?.containsKey("delta") == true) {
            delta = (creationParams["delta"] as? List<*>) ?: listOf<Map<String, Any>>()
        }

        quillEditor = QuillEditor(context, placeholder, padding, readOnly, autoFocus, delta)
        quillEditor.setOnTextChangeListener { delta, oldDelta ->
            val text = HashMap<String, String>()
            text["delta"] = delta
            text["oldDelta"] = oldDelta
            methodChannel.invokeMethod(INVOKE_METHOD_ON_TEXT_CHANGE, text)
        }
        quillEditor.setOnFocusChangeListener { hasFocus ->
            methodChannel.invokeMethod(INVOKE_METHOD_ON_FOCUS_CHANGED, hasFocus)
        }
        methodChannel.setMethodCallHandler(this)
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
            HANDLE_METHOD_FOCUS -> {
                quillEditor.focus()
                result.success(null)
            }
            HANDLE_METHOD_BLUR -> {
                quillEditor.blur()
                result.success(null)
            }
            HANDLE_METHOD_CLEAR_TEXT_TYPE -> {
                result.success(null)
            }
            HANDLE_METHOD_CLEAR_TEXT_STYLE -> {
                result.success(null)
            }
            HANDLE_METHOD_SET_TEXT_TYPE -> {
                when (call.arguments as? String ?: TextCons.TEXT_TYPE_NORMAL) {
                    TextCons.TEXT_TYPE_NORMAL -> quillEditor.removeCurrentFormat()
                    TextCons.TEXT_TYPE_HEADLINE1 -> quillEditor.format("header", 1)
                    TextCons.TEXT_TYPE_HEADLINE2 -> quillEditor.format("header", 2)
                    TextCons.TEXT_TYPE_HEADLINE3 -> quillEditor.format("header", 3)
                    TextCons.TEXT_TYPE_LIST_BULLET -> quillEditor.format("list", "bullet")
                    TextCons.TEXT_TYPE_LIST_ORDERED -> quillEditor.format("list", "ordered")
                    TextCons.TEXT_TYPE_QUOTE -> quillEditor.format("blockquote", true)
                    TextCons.TEXT_TYPE_CODE_BLOCK -> quillEditor.format("code-block", true)
                }
                 result.success(null)
            }
            HANDLE_METHOD_SET_TEXT_STYLE -> {
                val textStyleList: List<String> = (call.arguments as? List<*> ?: ArrayList<String>()).map {
                    return@map it as String? ?: ""
                }
                quillEditor.format("bold", textStyleList.contains(TextCons.TEXT_STYLE_BOLD))
                quillEditor.format("italic", textStyleList.contains(TextCons.TEXT_STYLE_ITALIC))
                quillEditor.format("underline", textStyleList.contains(TextCons.TEXT_STYLE_UNDERLINE))
                quillEditor.format("strike", textStyleList.contains(TextCons.TEXT_STYLE_STRIKE_THROUGH))
                result.success(null)
            }
            HANDLE_METHOD_UPDATE_SELECTION -> {
                val args = call.arguments as? Map<*, *> ?: return
                val selStart = args["selStart"] as? Int ?: 0
                val selEnd = args["selEnd"] as? Int ?: 0
                if (selEnd > selStart) {
                    quillEditor.setSelection(selStart, selEnd - selStart)
                } else {
                    quillEditor.setSelection(selEnd, selStart - selEnd)
                }
                result.success(null)
            }
            HANDLE_METHOD_FORMAT_TEXT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val index = args["index"] as? Int ?: 0
                val len = args["len"] as? Int ?: 0
                val name = args["name"] as? String ?: return
                val value = args["value"] as? String ?: return
                quillEditor.formatText(index, len, name, value)
                result.success(null)
            }
            HANDLE_METHOD_REPLACE_TEXT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val index = args["index"] as? Int ?: 0
                val len = args["len"] as? Int ?: 0
                val data = args["data"] as? String ?: ""
                val ignoreFocus = args["ignoreFocus"] as Boolean? ?: false
                val autoAppendNewLineAfterImage = args["autoAppendNewLineAfterImage"] as Boolean? ?: true
                quillEditor.replaceText(index, len, data, ignoreFocus, autoAppendNewLineAfterImage)
                result.success(null)
            }
            HANDLE_METHOD_INSERT_DIVIDER -> {
                quillEditor.insertDivider()
            }
            HANDLE_METHOD_INSERT_IMAGE -> {
                val args = call.arguments as? Map<*, *> ?: return
                val url = args["url"] as? String ?: return
                val alt = args["alt"] as? String ?: return
                quillEditor.insertImage(url, alt)
            }

            else -> {
                println("missing plugin method: ${call.method}")
                result.notImplemented()
            }
        }
    }

}
