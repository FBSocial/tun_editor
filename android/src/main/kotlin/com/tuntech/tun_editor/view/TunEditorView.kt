package com.tuntech.tun_editor.view

import android.content.Context
import android.graphics.Color
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.view.ViewGroup
import android.widget.ScrollView
import com.chinalwb.are.Util
import com.tuntech.tun_editor.utils.SelectionUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.*

internal class TunEditorView(
    context: Context,
    id: Int,
    creationParams: Map<String, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        const val FONT_SIZE_HEADLINE_1: Int = 48
        const val FONT_SIZE_HEADLINE_2: Int = 40
        const val FONT_SIZE_HEADLINE_3: Int = 32
        const val FONT_SIZE_NORMAL: Int = 18
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
        areEditor.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
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
                methodChannel.invokeMethod("onTextChange", args)
            }
            override fun afterTextChanged(s: Editable?) {
            }
        })
        areEditor.setOnSelectionChanged { selStart, selEnd ->
            val res = SelectionUtil.checkSelectionStyle(areEditor.editableText, selStart, selEnd)
            currentStyle = res["style"] as? String ?: ""
            println("on selection changed $selStart, $selEnd: $currentStyle")
            methodChannel.invokeMethod("onSelectionChanged", res)
        }
        if (creationParams?.containsKey("place_holder") == true) {
            val placeHolder: String = (creationParams["place_holder"] as? String) ?: ""
            areEditor.hint = placeHolder
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Common tools.
            "undo" -> {
                result.success(null)
            }
            "redo" -> {
                result.success(null)
            }
            "clearTextType" -> {
                areEditor.clearTextType()
                result.success(null)
            }
            "clearTextStyle" -> {
                areEditor.clearTextStyle()
                result.success(null)
            }

            // Text types.
            "setHeadline1" -> {
                areEditor.setTextType(Editor.TEXT_TYPE_HEADLINE1)
                result.success(null)
            }
            "setHeadline2" -> {
                areEditor.setTextType(Editor.TEXT_TYPE_HEADLINE2)
                result.success(null)
            }
            "setHeadline3" -> {
                areEditor.setTextType(Editor.TEXT_TYPE_HEADLINE3)
                result.success(null)
            }
            "setList" -> {
                areEditor.setTextType(Editor.TEXT_TYPE_LIST_BULLET)
                result.success(null)
            }
            "setOrderedList" -> {
                areEditor.setTextType(Editor.TEXT_TYPE_LIST_ORDERED)
                result.success(null)
            }
            "insertDivider" -> {
                // TODO Insert divider.
                result.success(null)
            }
            "setQuote" -> {
                areEditor.setTextType(Editor.TEXT_TYPE_QUOTE)
                result.success(null)
            }
            "setCodeBlock" -> {
                areEditor.setTextType(Editor.TEXT_TYPE_CODE_BLOCK)
                result.success(null)
            }

            // Text styles.
            "setBold" -> {
                areEditor.setTextStyle(listOf(Editor.TEXT_STYLE_BOLD))
                result.success(null)
            }
            "setItalic" -> {
                areEditor.setTextStyle(listOf(Editor.TEXT_STYLE_ITALIC))
                result.success(null)
            }
            "setUnderline" -> {
                areEditor.setTextStyle(listOf(Editor.TEXT_STYLE_UNDERLINE))
                result.success(null)
            }
            "setStrikeThrough" -> {
                areEditor.setTextStyle(listOf(Editor.TEXT_STYLE_STRIKE_THROUGH))
                result.success(null)
            }

            "updateSelection" -> {
                val args = call.arguments as? Map<*, *> ?: return
                val selStart = args["selStart"] as? Int ?: 0
                val selEnd = args["selEnd"] as? Int ?: 0
                areEditor.setSelection(selStart, selEnd)
                result.success(null)
            }
            "formatSelectionLines" -> {
                // Work for line formatter.
                val attr = call.arguments as? String ?: ""
                val lines = Util.getCurrentSelectionLines(areEditor)
                val startIndex = Util.getThisLineStart(areEditor, lines[0])
                val endIndex = Util.getThisLineEnd(areEditor, lines[1])
                if (startIndex > endIndex || startIndex == -1 || endIndex == -1) {
                    println("invalid start or end index in lines: $startIndex $endIndex")
                    return
                }
                areEditor.formatText(attr, startIndex, endIndex - startIndex)
            }
            "formatText" -> {
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
            "replaceText" -> {
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
            }
            "insert" -> {
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
            }
            "insertImage" -> {
                // TODO Insert image.
            }

            else -> {
                println("missing plugin method: ${call.method}")
                result.notImplemented()
            }
        }
    }

}