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
        const val HANDLE_METHOD_INSERT_DIVIDER = "insertDivider"
        const val HANDLE_METHOD_INSERT_IMAGE = "insertImage"
    }

    // View.
    private val quillEditor: QuillEditor = QuillEditor(context)

    // Method channel.
    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    override fun getView(): View {
        return quillEditor
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    init {
        methodChannel.setMethodCallHandler(this)

        quillEditor.setOnTextChangeListener { delta, oldDelta ->
            val text = HashMap<String, String>()
            text["delta"] = delta
            text["oldDelta"] = oldDelta
            Log.d(QuillEditor.TAG, "on text change, $delta, $oldDelta")
            methodChannel.invokeMethod(INVOKE_METHOD_ON_TEXT_CHANGE, text)
        }
       if (creationParams?.containsKey("place_holder") == true) {
            val placeHolder: String = (creationParams["place_holder"] as? String) ?: ""
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
                val url = "https://avatars0.githubusercontent.com/u/1758864?s=460&v=4"
                quillEditor.insertImage(url, "test image")
            }

            else -> {
                println("missing plugin method: ${call.method}")
                result.notImplemented()
            }
        }
    }

}
