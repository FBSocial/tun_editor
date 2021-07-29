package com.tuntech.tun_editor.view

import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import android.widget.LinearLayout
import com.tuntech.tun_editor.R
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

internal class TunEditorToolbarView(
    context: Context,
    id: Int,
    creationParams: Map<String, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        const val INVOKE_METHOD_ON_AT_CLICK = "onAtClick"
        const val INVOKE_METHOD_ON_IMAGE_CLICK = "onImageClick"
        const val INVOKE_METHOD_ON_EMOJI = "onEmojiClick"
        const val INVOKE_METHOD_ON_SUB_TOOLBAR_TOGGLE = "onSubToolbarToggle"
        const val INVOKE_METHOD_SET_TEXT_TYPE = "setTextType"
        const val INVOKE_METHOD_SET_TEXT_STYLE = "setTextStyle"
        const val INVOKE_METHOD_INSERT_DIVIDER = "insertDivider"

        const val HANDLE_METHOD_ON_SELECTION_CHANGED = "onSelectionChanged"
    }

    // UI related.
    // FIXME use correct parent view.
    private val toolbar: View = LayoutInflater.from(context).inflate(R.layout.editor_toolbar, null)

    // Toolbar layout.
    private val viewSubToolbarPlaceholder: View = toolbar.findViewById(R.id.view_placeholder)
    private val llTextType: LinearLayout = toolbar.findViewById(R.id.ll_text_type)
    private val llTextStyle: LinearLayout = toolbar.findViewById(R.id.ll_text_style)

    // Toolbar item.
    private val ibAt: ImageButton = toolbar.findViewById(R.id.ib_at)
    private val ibImage: ImageButton = toolbar.findViewById(R.id.ib_image)
    private val ibEmoji: ImageButton = toolbar.findViewById(R.id.ib_emoji)
    private val ibTextType: ImageButton = toolbar.findViewById(R.id.ib_text_type)
    private val ibTextStyle: ImageButton = toolbar.findViewById(R.id.ib_text_style)

    // Text types.
    private val ibHeadline1: ImageButton = toolbar.findViewById(R.id.ib_headline_1)
    private val ibHeadline2: ImageButton = toolbar.findViewById(R.id.ib_headline_2)
    private val ibHeadline3: ImageButton = toolbar.findViewById(R.id.ib_headline_3)
    private val ibList: ImageButton = toolbar.findViewById(R.id.ib_list)
    private val ibOrderedList: ImageButton = toolbar.findViewById(R.id.ib_ordered_list)
    private val ibDivider: ImageButton = toolbar.findViewById(R.id.ib_divider)
    private val ibQuote: ImageButton = toolbar.findViewById(R.id.ib_quote)
    private val ibCodeBlock: ImageButton = toolbar.findViewById(R.id.ib_code_block)

    // Text style.
    private val ibBold: ImageButton = toolbar.findViewById(R.id.ib_bold)
    private val ibItalic: ImageButton = toolbar.findViewById(R.id.ib_italic)
    private val ibUnderline: ImageButton = toolbar.findViewById(R.id.ib_underline)
    private val ibStrikeThrough: ImageButton = toolbar.findViewById(R.id.ib_strike_through)

    // Toolbar item state.
    private var isShowTextType = false
    private var isShowTextStyle = false

    // Text type and text style state.
    private var currentTextType: String = Editor.TEXT_TYPE_NORMAL
    private var currentTextStyleList: ArrayList<String> = ArrayList()

    private val methodChannel = MethodChannel(messenger, "tun/editor/toolbar/${id}")

    init {
        initView()

        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return toolbar
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            HANDLE_METHOD_ON_SELECTION_CHANGED -> {
                val status = call.arguments as? Map<*, *> ?: return

                // Refresh text type.
                currentTextType = when {
                    status["isHeadline1"] == true -> Editor.TEXT_TYPE_HEADLINE1
                    status["isHeadline2"] == true -> Editor.TEXT_TYPE_HEADLINE1
                    status["isHeadline3"] == true -> Editor.TEXT_TYPE_HEADLINE1
                    status["isList"] == true -> Editor.TEXT_TYPE_HEADLINE1
                    status["isOrderedList"] == true -> Editor.TEXT_TYPE_HEADLINE1
                    status["isQuote"] == true -> Editor.TEXT_TYPE_HEADLINE1
                    status["isCodeBlock"] == true -> Editor.TEXT_TYPE_HEADLINE1
                    else -> Editor.TEXT_TYPE_NORMAL
                }
                refreshTextTypeView()

                // // Refresh text style.
                // currentTextStyleList.clear()
                // if (status["isBold"] == true) {
                //     currentTextStyleList.add(Editor.TEXT_STYLE_BOLD)
                // }
                // if (status["isItalic"] == true) {
                //     currentTextStyleList.add(Editor.TEXT_STYLE_ITALIC)
                // }
                // if (status["isUnderline"] == true) {
                //     currentTextStyleList.add(Editor.TEXT_STYLE_UNDERLINE)
                // }
                // if (status["isStrikeThrough"] == true) {
                //     currentTextStyleList.add(Editor.TEXT_STYLE_STRIKE_THROUGH)
                // }
                // refreshTextStyleView()
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    private fun initView() {
        viewSubToolbarPlaceholder.visibility = View.VISIBLE
        llTextType.visibility = View.GONE
        llTextStyle.visibility = View.GONE

        // Text type.
        ibHeadline1.setOnClickListener {
            toggleTextType(Editor.TEXT_TYPE_HEADLINE1)
        }
        ibHeadline2.setOnClickListener {
            toggleTextType(Editor.TEXT_TYPE_HEADLINE2)
        }
        ibHeadline3.setOnClickListener {
            toggleTextType(Editor.TEXT_TYPE_HEADLINE3)
        }
        ibList.setOnClickListener {
            toggleTextType(Editor.TEXT_TYPE_LIST_BULLET)
        }
        ibOrderedList.setOnClickListener {
            toggleTextType(Editor.TEXT_TYPE_LIST_ORDERED)
        }
        ibDivider.setOnClickListener {
            methodChannel.invokeMethod(INVOKE_METHOD_INSERT_DIVIDER, null)
        }
        ibQuote.setOnClickListener {
            toggleTextType(Editor.TEXT_TYPE_QUOTE)
        }
        ibCodeBlock.setOnClickListener {
            toggleTextType(Editor.TEXT_TYPE_CODE_BLOCK)
        }

        // Text style.
        ibBold.setOnClickListener {
            toggleTextStyle(Editor.TEXT_STYLE_BOLD)
        }
        ibItalic.setOnClickListener {
            toggleTextStyle(Editor.TEXT_STYLE_ITALIC)
        }
        ibUnderline.setOnClickListener {
            toggleTextStyle(Editor.TEXT_STYLE_UNDERLINE)
        }
        ibStrikeThrough.setOnClickListener {
            toggleTextStyle(Editor.TEXT_STYLE_STRIKE_THROUGH)
        }

        // Toolbar items.
        ibAt.setOnClickListener {
            methodChannel.invokeMethod(INVOKE_METHOD_ON_AT_CLICK, null)
        }
        ibImage.setOnClickListener {
            methodChannel.invokeMethod(INVOKE_METHOD_ON_IMAGE_CLICK, null)
        }
        ibEmoji.setOnClickListener {
            methodChannel.invokeMethod(INVOKE_METHOD_ON_EMOJI, null)
        }
        ibTextType.setOnClickListener {
            toggleSubToolbarTextType()
            toggleSubToolbarPlaceHolder()
        }
        ibTextStyle.setOnClickListener {
            toggleSubToolbarTextStyle()
            toggleSubToolbarPlaceHolder()
        }
    }

    private fun toggleSubToolbarTextType() {
        val isVisible = if (isShowTextType) {
            ibTextType.setBackgroundColor(Color.TRANSPARENT)
            View.GONE
        } else {
            ibTextType.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
            View.VISIBLE
        }
        // Toggle text type.
        llTextType.visibility = isVisible
        isShowTextType = !isShowTextType

        // Disable text style.
        llTextStyle.visibility = View.GONE
        ibTextStyle.setBackgroundColor(Color.TRANSPARENT)
        isShowTextStyle = false

        methodChannel.invokeMethod(INVOKE_METHOD_ON_SUB_TOOLBAR_TOGGLE, isShowTextStyle || isShowTextType)
    }

    private fun toggleSubToolbarTextStyle() {
        val isVisible = if (isShowTextStyle) {
            ibTextStyle.setBackgroundColor(Color.TRANSPARENT)
            View.GONE
        } else {
            ibTextStyle.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
            View.VISIBLE
        }
        // Toggle text style.
        toolbar.findViewById<LinearLayout>(R.id.ll_text_style).visibility = isVisible
        isShowTextStyle = !isShowTextStyle

        // Disable text type.
        llTextType.visibility = View.GONE
        ibTextType.setBackgroundColor(Color.TRANSPARENT)
        isShowTextType = false

        methodChannel.invokeMethod(INVOKE_METHOD_ON_SUB_TOOLBAR_TOGGLE, isShowTextStyle || isShowTextType)
    }

    private fun toggleSubToolbarPlaceHolder() {
        val isShowingSub = isShowTextStyle || isShowTextType
        if (isShowingSub) {
            toolbar.findViewById<View>(R.id.view_placeholder).visibility = View.GONE
        } else {
            toolbar.findViewById<View>(R.id.view_placeholder).visibility = View.VISIBLE
        }
    }

    private fun toggleTextType(textType: String) {
        if (currentTextType == textType) {
            // Reset normal text type.
            currentTextType = Editor.TEXT_TYPE_NORMAL
            refreshTextTypeView()
            methodChannel.invokeMethod(INVOKE_METHOD_SET_TEXT_TYPE, Editor.TEXT_TYPE_NORMAL)
        } else {
            // Set new text type.
            currentTextType = textType
            refreshTextTypeView()
            methodChannel.invokeMethod(INVOKE_METHOD_SET_TEXT_TYPE, textType)
        }
    }

    private fun toggleTextStyle(textStyle: String) {
        if (currentTextStyleList.contains(textStyle)) {
            // Remove text style.
            currentTextStyleList.remove(textStyle)
        } else {
            // Append text style.
            currentTextStyleList.add(textStyle)
        }
        refreshTextStyleView()
        methodChannel.invokeMethod(INVOKE_METHOD_SET_TEXT_STYLE, currentTextStyleList)
    }

    private fun refreshTextTypeView() {
        val disabledColor = Color.TRANSPARENT
        val enabledBg = R.drawable.bg_toolbar_item_focused

        // Disable all text type.
        ibHeadline1.setBackgroundColor(disabledColor)
        ibHeadline2.setBackgroundColor(disabledColor)
        ibHeadline3.setBackgroundColor(disabledColor)
        ibList.setBackgroundColor(disabledColor)
        ibOrderedList.setBackgroundColor(disabledColor)
        ibQuote.setBackgroundColor(disabledColor)
        ibCodeBlock.setBackgroundColor(disabledColor)

        // Enable current text type.
        when (currentTextType) {
            Editor.TEXT_TYPE_HEADLINE1 -> {
                ibHeadline1.setBackgroundResource(enabledBg)
            }
            Editor.TEXT_TYPE_HEADLINE2 -> {
                ibHeadline2.setBackgroundResource(enabledBg)
            }
            Editor.TEXT_TYPE_HEADLINE3 -> {
                ibHeadline3.setBackgroundResource(enabledBg)
            }
            Editor.TEXT_TYPE_LIST_BULLET -> {
                ibList.setBackgroundResource(enabledBg)
            }
            Editor.TEXT_TYPE_LIST_ORDERED -> {
                ibOrderedList.setBackgroundResource(enabledBg)
            }
            Editor.TEXT_TYPE_QUOTE -> {
                ibQuote.setBackgroundResource(enabledBg)
            }
            Editor.TEXT_TYPE_CODE_BLOCK -> {
                ibCodeBlock.setBackgroundResource(enabledBg)
            }
        }
    }

    private fun refreshTextStyleView() {
        val disabledColor = Color.TRANSPARENT
        val enabledBg = R.drawable.bg_toolbar_item_focused

        if (currentTextStyleList.contains(Editor.TEXT_STYLE_BOLD)) {
            ibBold.setBackgroundResource(enabledBg)
        } else {
            ibBold.setBackgroundColor(disabledColor)
        }
        if (currentTextStyleList.contains(Editor.TEXT_STYLE_ITALIC)) {
            ibItalic.setBackgroundResource(enabledBg)
        } else {
            ibItalic.setBackgroundColor(disabledColor)
        }
        if (currentTextStyleList.contains(Editor.TEXT_STYLE_UNDERLINE)) {
            ibUnderline.setBackgroundResource(enabledBg)
        } else {
            ibUnderline.setBackgroundColor(disabledColor)
        }
        if (currentTextStyleList.contains(Editor.TEXT_STYLE_STRIKE_THROUGH)) {
            ibStrikeThrough.setBackgroundResource(enabledBg)
        } else {
            ibStrikeThrough.setBackgroundColor(disabledColor)
        }
    }

}
