package com.tuntech.tun_editor.view

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import com.chinalwb.are.AREditText
import com.chinalwb.are.styles.toolbar.ARE_ToolbarDefault
import com.chinalwb.are.styles.toolitems.*
import com.chinalwb.are.styles.toolitems.styles.ARE_Style_FontSize
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
        const val FONT_SIZE_HEADLINE_1: Int = 48
        const val FONT_SIZE_HEADLINE_2: Int = 40
        const val FONT_SIZE_HEADLINE_3: Int = 32
        const val FONT_SIZE_NORMAL: Int = 18
    }

    private val areEditor: AREditText = AREditText(context)
    private val areToolbar: ARE_ToolbarDefault = ARE_ToolbarDefault(context)
    private val areToolbarItemBold: ARE_ToolItem_Bold = ARE_ToolItem_Bold()
    private val areToolbarItemItalic: ARE_ToolItem_Italic = ARE_ToolItem_Italic()
    private val areToolbarItemUnderline: ARE_ToolItem_Underline = ARE_ToolItem_Underline()
    private val areToolbarItemStrikethrough: ARE_ToolItem_Strikethrough = ARE_ToolItem_Strikethrough()
    private val areToolbarItemFontSize: ARE_ToolItem_FontSize = ARE_ToolItem_FontSize()
    private val areToolbarItemList: ARE_ToolItem_ListBullet = ARE_ToolItem_ListBullet()
    private val areToolbarItemOrderedList: ARE_ToolItem_ListNumber = ARE_ToolItem_ListNumber()
    private val areToolbarItemHr: ARE_ToolItem_Hr = ARE_ToolItem_Hr()
    private val areToolbarItemQuote: ARE_ToolItem_Quote = ARE_ToolItem_Quote()
    private val areToolbarItemCodeBlock: ARE_ToolItem_Quote = ARE_ToolItem_Quote()

    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    private var isShowHeadline: Boolean = false
    private var lastHeadlineFontSize: Int = FONT_SIZE_NORMAL

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
            }
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }
            override fun afterTextChanged(s: Editable?) {
                methodChannel.invokeMethod("onTextChange", s?.toString() ?: "")
            }
        })
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
            "clearStyle" -> {
                // Disable all tool items.
                for (tool in areToolbar.toolItems) {
                    tool.style.setChecked(false)
                }
                val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
                fontSizeStyle.onFontSizeChange(FONT_SIZE_NORMAL)
            }

            // Text types.
            "setHeadline1" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_1)
            }
            "setHeadline2" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_2)
            }
            "setHeadline3" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_3)
            }
            "setList" -> {
                areToolbarItemList.getView(areToolbar.context).performClick()
            }
            "setOrderedList" -> {
                areToolbarItemOrderedList.getView(areToolbar.context).performClick()
            }
            "insertDivider" -> {
                areToolbarItemHr.getView(areToolbar.context).performClick()
            }
            "setQuote" -> {
                areToolbarItemQuote.getView(areToolbar.context).performClick()
            }
            "setCodeBlock" -> {
                areToolbarItemQuote.getView(areToolbar.context).performClick()
            }

            // Text styles.
            "setBold" -> {
                areToolbarItemBold.getView(areToolbar.context).performClick()
                result.success(null)
            }
            "setItalic" -> {
                areToolbarItemItalic.getView(areToolbar.context).performClick()
                result.success(null)
            }
            "setUnderline" -> {
                areToolbarItemUnderline.getView(areToolbar.context).performClick()
                result.success(null)
            }
            "setStrikeThrough" -> {
                areToolbarItemStrikethrough.getView(areToolbar.context).performClick()
                result.success(null)
            }

            "getHtml" -> {
                val html = areEditor.html
                result.success(html)
            }

            else -> {
                println("missing plugin method: ${call.method}")
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

}
