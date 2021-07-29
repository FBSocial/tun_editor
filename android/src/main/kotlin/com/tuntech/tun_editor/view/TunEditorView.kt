package com.tuntech.tun_editor.view

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import com.chinalwb.are.styles.toolbar.ARE_ToolbarDefault
import com.chinalwb.are.styles.toolitems.*
import com.chinalwb.are.styles.toolitems.styles.ARE_Style_FontSize
import com.chinalwb.are.styles.toolitems.styles.ARE_Style_ListBullet
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

    // Text type items.
    private val areToolbarItemFontSize: ARE_ToolItem_FontSize = ARE_ToolItem_FontSize()
    private val areToolbarItemList: ARE_ToolItem_ListBullet = ARE_ToolItem_ListBullet()
    private val areToolbarItemOrderedList: ARE_ToolItem_ListNumber = ARE_ToolItem_ListNumber()
    private val areToolbarItemHr: ARE_ToolItem_Hr = ARE_ToolItem_Hr()
    private val areToolbarItemQuote: ARE_ToolItem_Quote = ARE_ToolItem_Quote()
    private val areToolbarItemCodeBlock: ARE_ToolItem_Quote = ARE_ToolItem_Quote()

    // Text style items.
    private val areEditor: Editor = Editor(context)
    private val areToolbar: ARE_ToolbarDefault = ARE_ToolbarDefault(context)
    private val areToolbarItemBold: ARE_ToolItem_Bold = ARE_ToolItem_Bold()
    private val areToolbarItemItalic: ARE_ToolItem_Italic = ARE_ToolItem_Italic()
    private val areToolbarItemUnderline: ARE_ToolItem_Underline = ARE_ToolItem_Underline()
    private val areToolbarItemStrikethrough: ARE_ToolItem_Strikethrough = ARE_ToolItem_Strikethrough()

    private val areToolbarItemImage: ARE_ToolItem_Image = ARE_ToolItem_Image()

    // Method channel.
    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    private var currentStyle: String = ""

    // Headline related.
    private var isShowHeadline: Boolean = false
    private var lastHeadlineFontSize: Int = FONT_SIZE_NORMAL

    // Text watcher related.
    private var oldText: String = ""

    override fun getView(): View {
        return areEditor
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    init {
        methodChannel.setMethodCallHandler(this)

        // Text types.
        areToolbar.addToolbarItem(areToolbarItemFontSize)
        areToolbar.addToolbarItem(areToolbarItemList)
        areToolbar.addToolbarItem(areToolbarItemOrderedList)
        areToolbar.addToolbarItem(areToolbarItemHr)
        areToolbar.addToolbarItem(areToolbarItemQuote)
        areToolbar.addToolbarItem(areToolbarItemCodeBlock)

        // Text styles.
        areToolbar.addToolbarItem(areToolbarItemBold)
        areToolbar.addToolbarItem(areToolbarItemItalic)
        areToolbar.addToolbarItem(areToolbarItemUnderline)
        areToolbar.addToolbarItem(areToolbarItemStrikethrough)

        areEditor.setToolbar(areToolbar)
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
                // Headline.
                val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
                fontSizeStyle.onFontSizeChange(FONT_SIZE_NORMAL)
                areToolbarItemList.style.setChecked(false)
                areToolbarItemOrderedList.style.setChecked(false)
                areToolbarItemQuote.style.setChecked(false)
                result.success(null)
            }
            "clearTextStyle" -> {
                // Disable all tool items.
                areToolbarItemBold.style.setChecked(false)
                areToolbarItemItalic.style.setChecked(false)
                areToolbarItemUnderline.style.setChecked(false)
                areToolbarItemStrikethrough.style.setChecked(false)
                result.success(null)
            }

            // Text types.
            "setHeadline1" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_1)
                result.success(null)
            }
            "setHeadline2" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_2)
                result.success(null)
            }
            "setHeadline3" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_3)
                result.success(null)
            }
            "setList" -> {
                areToolbarItemList.getView(areToolbar.context).performClick()
                currentStyle = if (areToolbarItemList.style.isChecked) {
                    "list-bullet"
                } else {
                    ""
                }
                result.success(null)
            }
            "setOrderedList" -> {
                areToolbarItemOrderedList.getView(areToolbar.context).performClick()
                currentStyle = if (areToolbarItemOrderedList.style.isChecked) {
                    "list-ordered"
                } else {
                    ""
                }
                result.success(null)
            }
            "insertDivider" -> {
                areToolbarItemHr.getView(areToolbar.context).performClick()
                result.success(null)
            }
            "setQuote" -> {
                areToolbarItemQuote.getView(areToolbar.context).performClick()
                currentStyle = if (areToolbarItemQuote.style.isChecked) {
                    "blockquote"
                } else {
                    ""
                }
                result.success(null)
            }
            "setCodeBlock" -> {
                areToolbarItemQuote.getView(areToolbar.context).performClick()
                currentStyle = if (areToolbarItemCodeBlock.style.isChecked) {
                    "code-block"
                } else {
                    ""
                }
                result.success(null)
            }

            // Text styles.
            "setBold" -> {
                areToolbarItemBold.getView(areToolbar.context).performClick()
                currentStyle = if (areToolbarItemBold.style.isChecked) {
                    "bold"
                } else {
                    ""
                }
                result.success(null)
            }
            "setItalic" -> {
                areToolbarItemItalic.getView(areToolbar.context).performClick()
                currentStyle = if (areToolbarItemItalic.style.isChecked) {
                    "italic"
                } else {
                    ""
                }
                result.success(null)
            }
            "setUnderline" -> {
                areToolbarItemUnderline.getView(areToolbar.context).performClick()
                currentStyle = if (areToolbarItemUnderline.style.isChecked) {
                    "underline"
                } else {
                    ""
                }
                result.success(null)
            }
            "setStrikeThrough" -> {
                areToolbarItemStrikethrough.getView(areToolbar.context).performClick()
                currentStyle = if (areToolbarItemStrikethrough.style.isChecked) {
                    "strike"
                } else {
                    ""
                }
                result.success(null)
            }

            "setHtml" -> {
                areEditor.editableText.insert(areEditor.length(), "@Jeffrey Wu")
                result.success(null)
            }
            "getHtml" -> {
                val html = areEditor.html
                result.success(html)
            }
            "updateSelection" -> {
                val args = call.arguments as? Map<*, *> ?: return
                val selStart = args["selStart"] as? Int ?: 0
                val selEnd = args["selEnd"] as? Int ?: 0
                areEditor.setSelection(selStart, selEnd)
                result.success(null)
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
                formatText(attr, index, len)
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
                areToolbarItemImage.getView(areToolbar.context).performClick()
            }

            else -> {
                println("missing plugin method: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun toggleHeadline(fontSize: Int) {
        val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
        if (fontSize == lastHeadlineFontSize) {
            // Toggle checked status if font size was not changed.
            isShowHeadline = !isShowHeadline
            lastHeadlineFontSize = if (isShowHeadline) {
                fontSize
            } else {
                FONT_SIZE_NORMAL
            }
            fontSizeStyle.onFontSizeChange(lastHeadlineFontSize)
        } else {
            // Update new font size if font size changed.
            isShowHeadline = true
            lastHeadlineFontSize = fontSize
            fontSizeStyle.onFontSizeChange(lastHeadlineFontSize)
        }
    }

    private fun formatText(attr: String, index: Int, len: Int) {
        when (attr) {
            "header1" -> {
                val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
                val oldChecked = fontSizeStyle.isChecked

                fontSizeStyle.onFontSizeChange(FONT_SIZE_HEADLINE_1)
                fontSizeStyle.setChecked(true)

                fontSizeStyle.applyStyle(areEditor.editableText, index, index + len)

                fontSizeStyle.setChecked(oldChecked)
                fontSizeStyle.onFontSizeChange(lastHeadlineFontSize)
            }
            "header2" -> {
                val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
                val oldChecked = fontSizeStyle.isChecked

                fontSizeStyle.onFontSizeChange(FONT_SIZE_HEADLINE_2)
                fontSizeStyle.setChecked(true)

                fontSizeStyle.applyStyle(areEditor.editableText, index, index + len)

                fontSizeStyle.setChecked(oldChecked)
                fontSizeStyle.onFontSizeChange(lastHeadlineFontSize)
            }
            "header3" -> {
                val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
                val oldChecked = fontSizeStyle.isChecked

                fontSizeStyle.onFontSizeChange(FONT_SIZE_HEADLINE_3)
                fontSizeStyle.setChecked(true)

                fontSizeStyle.applyStyle(areEditor.editableText, index, index + len)

                fontSizeStyle.setChecked(oldChecked)
                fontSizeStyle.onFontSizeChange(lastHeadlineFontSize)
            }
            "list-bullet" -> {
                // FIXME List format not work.
                val listStyle = (areToolbarItemList.style as? ARE_Style_ListBullet) ?: return

                val oldChecked = listStyle.isChecked
                listStyle.setChecked(true)
                listStyle.applyStyle(areEditor.editableText, index, index + len)
                listStyle.setChecked(oldChecked)
            }
            "list-ordered" -> {
                // FIXME List format not work.
                val oldChecked = areToolbarItemOrderedList.style.isChecked
                areToolbarItemOrderedList.style.setChecked(true)
                areToolbarItemOrderedList.style.applyStyle(areEditor.editableText, index, index + len)
                areToolbarItemOrderedList.style.setChecked(oldChecked)
            }
            "blockquote" -> {
                val oldChecked = areToolbarItemQuote.style.isChecked
                areToolbarItemQuote.style.setChecked(true)
                areToolbarItemQuote.style.applyStyle(areEditor.editableText, index, index + len)
                areToolbarItemQuote.style.setChecked(oldChecked)
            }
            "code-block" -> {
                // TODO Add code block format.
            }

            "bold" -> {
                val oldChecked = areToolbarItemBold.style.isChecked
                areToolbarItemBold.style.setChecked(true)
                areToolbarItemBold.style.applyStyle(areEditor.editableText, index, index + len)
                areToolbarItemBold.style.setChecked(oldChecked)
            }
            "italic" -> {
                val oldChecked = areToolbarItemItalic.style.isChecked
                areToolbarItemItalic.style.setChecked(true)
                areToolbarItemItalic.style.applyStyle(areEditor.editableText, index, index + len)
                areToolbarItemItalic.style.setChecked(oldChecked)
            }
            "underline" -> {
                val oldChecked = areToolbarItemUnderline.style.isChecked
                areToolbarItemUnderline.style.setChecked(true)
                areToolbarItemUnderline.style.applyStyle(areEditor.editableText, index, index + len)
                areToolbarItemUnderline.style.setChecked(oldChecked)
            }
            "strike" -> {
                val oldChecked = areToolbarItemStrikethrough.style.isChecked
                areToolbarItemStrikethrough.style.setChecked(true)
                areToolbarItemStrikethrough.style.applyStyle(areEditor.editableText, index, index + len)
                areToolbarItemStrikethrough.style.setChecked(oldChecked)
            }
            else -> {
                println("missing attribute: $attr")
            }
        }
    }

}