package com.tuntech.tun_editor.view

import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

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
                // when (call.arguments as? String ?: Editor.TEXT_TYPE_NORMAL) {
                //     TextCons.TEXT_TYPE_NORMAL -> richEditor.removeFormat()
                //     TextCons.TEXT_TYPE_HEADLINE1 -> richEditor.setHeading(1)
                //     TextCons.TEXT_TYPE_HEADLINE2 -> richEditor.setHeading(2)
                //     TextCons.TEXT_TYPE_HEADLINE3 -> richEditor.setHeading(3)
                //     TextCons.TEXT_TYPE_LIST_BULLET -> richEditor.setBullets()
                //     TextCons.TEXT_TYPE_LIST_ORDERED -> richEditor.setNumbers()
                //     TextCons.TEXT_TYPE_QUOTE -> richEditor.setBlockquote()
                // }
                // result.success(null)
            }
            HANDLE_METHOD_SET_TEXT_STYLE -> {
                // val textStyleList: List<String> = (call.arguments as? List<*> ?: ArrayList<String>()).map {
                //     return@map it as String? ?: ""
                // }
                // richEditor.removeFormat()
                // for (textStyle in textStyleList) {
                //     when (textStyle) {
                //         TextCons.TEXT_STYLE_BOLD -> richEditor.setBold()
                //         TextCons.TEXT_STYLE_ITALIC -> richEditor.setItalic()
                //         TextCons.TEXT_STYLE_UNDERLINE -> richEditor.setUnderline()
                //         TextCons.TEXT_STYLE_STRIKE_THROUGH -> richEditor.setStrikeThrough()
                //     }
                // }
                // result.success(null)
            }
            HANDLE_METHOD_UPDATE_SELECTION -> {
                val args = call.arguments as? Map<*, *> ?: return
                val selStart = args["selStart"] as? Int ?: 0
                val selEnd = args["selEnd"] as? Int ?: 0
                // TODO Set selection
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
                // if (len > areEditor.length()) {
                //     len = areEditor.length()
                // }
                // TODO Format text
                result.success(null)
            }
            HANDLE_METHOD_REPLACE_TEXT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val index = args["index"] as? Int ?: 0
                val len = args["len"] as? Int ?: 0
                val data = args["data"] as? String ?: ""
                val ignoreFocus = args["ignoreFocus"] as Boolean? ?: false
                val autoAppendNewLineAfterImage = args["autoAppendNewLineAfterImage"] as Boolean? ?: true
                // if (index > areEditor.length()) {
                //     return
                // }
                // TODO Replace
                result.success(null)
            }
            HANDLE_METHOD_INSERT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val index = args["index"] as? Int ?: 0
                val data = args["data"] as? String ?: ""
                val replaceLength = args["replaceLength"] as? Int ?: 0
                val autoAppendNewLineAfterImage = args["autoAppendNewLineAfterImage"] as Boolean? ?: true

                // if (index > areEditor.length()) {
                //     return
                // }
                // if (replaceLength > 0) {
                //     areEditor.text =
                //         areEditor.editableText.replace(index, index + replaceLength, data)
                // } else {
                //     areEditor.text = areEditor.editableText.insert(index, data)
                // }
                // println("new text: ${areEditor.text} $index $data")
                // TODO Insert
                result.success(null)
            }
            HANDLE_METHOD_INSERT_DIVIDER -> {
                quillEditor.insertDivider()
            }
            HANDLE_METHOD_INSERT_IMAGE -> {
                val url = "https://avatars0.githubusercontent.com/u/1758864?s=460&v=4"
                // richEditor.insertImage(url, "test image")
            }

            else -> {
                println("missing plugin method: ${call.method}")
                result.notImplemented()
            }
        }
    }

}
