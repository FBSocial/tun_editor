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
    creationParams: Map<String?, Any?>?,
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

    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    private var lastHeadlineFontSize: Int = FONT_SIZE_NORMAL

    override fun getView(): View {
        return areEditor
    }

    override fun dispose() {
    }

    init {
        methodChannel.setMethodCallHandler(this)

        // Toolbar item.
        areToolbar.addToolbarItem(areToolbarItemBold)
        areToolbar.addToolbarItem(areToolbarItemItalic)
        areToolbar.addToolbarItem(areToolbarItemUnderline)
        areToolbar.addToolbarItem(areToolbarItemStrikethrough)
        areToolbar.addToolbarItem(areToolbarItemFontSize)

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
            "setItalic" -> {
                areToolbarItemItalic.style.setChecked(!areToolbarItemItalic.style.isChecked)
                result.success(null)
            }
            "setUnderline" -> {
                areToolbarItemUnderline.style.setChecked(!areToolbarItemUnderline.style.isChecked)
                result.success(null)
            }
            "setStrikeThrough" -> {
                areToolbarItemStrikethrough.style.setChecked(!areToolbarItemStrikethrough.style.isChecked)
                result.success(null)
            }
            "setHeadline1" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_1)
            }
            "setHeadline2" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_2)
            }
            "setHeadline3" -> {
                toggleHeadline(FONT_SIZE_HEADLINE_3)
            }

            "clearStyle" -> {
                // Disable all tool items.
                for (tool in areToolbar.toolItems) {
                    tool.style.setChecked(false)
                }
                val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
                fontSizeStyle.onFontSizeChange(FONT_SIZE_NORMAL)
            }

            "getHtml" -> {
                val html = areEditor.html
                result.success(html)
            }
        }
    }

    private fun toggleHeadline(fontSize: Int) {
        // Disable headline if font size tool is enabled and new font size is same as last
        // headline's font size.
        lastHeadlineFontSize = if (areToolbarItemFontSize.style.isChecked && lastHeadlineFontSize != fontSize) {
            areToolbarItemFontSize.style.setChecked(false)
            val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
            fontSizeStyle.onFontSizeChange(FONT_SIZE_NORMAL)
            FONT_SIZE_NORMAL
        } else {
            // Set new headline.
            areToolbarItemFontSize.style.setChecked(true)
            val fontSizeStyle = (areToolbarItemFontSize.style as? ARE_Style_FontSize) ?: return
            fontSizeStyle.onFontSizeChange(fontSize)
            fontSize
        }
    }

}
