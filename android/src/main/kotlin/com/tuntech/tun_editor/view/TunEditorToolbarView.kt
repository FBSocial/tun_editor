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

    // Text types state.
    private var isHeadline1Enabled = false
    private var isHeadline2Enabled = false
    private var isHeadline3Enabled = false
    private var isListEnabled = false
    private var isOrderedListEnabled = false
    private var isQuoteEnabled = false
    private var isCodeBlockEnabled = false

    // Text style state.
    private var isBoldEnabled = false
    private var isItalicEnabled = false
    private var isUnderlineEnabled = false
    private var isStrikeThroughEnabled = false

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
            "onSelectionChanged" -> {
                val status = call.arguments as? Map<*, *> ?: return

                val isHeadline1 = status["isHeadline1"] as? Boolean ?: false
                val isHeadline2 = status["isHeadline2"] as? Boolean ?: false
                val isHeadline3 = status["isHeadline3"] as? Boolean ?: false
                val isList = status["isList"] as? Boolean ?: false
                val isOrderedList = status["isOrderedList"] as? Boolean ?: false
                val isQuote = status["isQuote"] as? Boolean ?: false
                val isCodeBlock = status["isCodeBlock"] as? Boolean ?: false

                val isBold = status["isBold"] as? Boolean ?: false
                val isItalic = status["isItalic"] as? Boolean ?: false
                val isUnderline = status["isUnderline"] as? Boolean ?: false
                val isStrikeThrough = status["isStrikeThrough"] as? Boolean ?: false

                setHeadline1Status(isHeadline1)
                setHeadline2Status(isHeadline2)
                setHeadline3Status(isHeadline3)
                setListStatus(isList)
                setOrderedListStatus(isOrderedList)
                setQuoteStatus(isQuote)
                setCodeBlockStatus(isCodeBlock)

                setBoldStatus(isBold)
                setItalicStatus(isItalic)
                setUnderlineStatus(isUnderline)
                setStrikeThroughStatus(isStrikeThrough)
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
            setHeadline1Status(!isHeadline1Enabled)
            methodChannel.invokeMethod("setHeadline1", null)
        }
        ibHeadline2.setOnClickListener {
            setHeadline2Status(!isHeadline2Enabled)
            methodChannel.invokeMethod("setHeadline2", null)
        }
        ibHeadline3.setOnClickListener {
            setHeadline3Status(!isHeadline3Enabled)
            methodChannel.invokeMethod("setHeadline3", null)
        }
        ibList.setOnClickListener {
            setListStatus(isListEnabled)
            methodChannel.invokeMethod("setList", null)
        }
        ibOrderedList.setOnClickListener {
            setOrderedListStatus(!isOrderedListEnabled)
            methodChannel.invokeMethod("setOrderedList", null)
        }
        ibDivider.setOnClickListener {
            methodChannel.invokeMethod("insertDivider", null)
        }
        ibQuote.setOnClickListener {
            setQuoteStatus(!isQuoteEnabled)
            methodChannel.invokeMethod("setQuote", null)
        }
        ibCodeBlock.setOnClickListener {
            setCodeBlockStatus(!isCodeBlockEnabled)
            methodChannel.invokeMethod("setCodeBlock", null)
        }

        // Text style.
        ibBold.setOnClickListener {
            setBoldStatus(!isBoldEnabled)
            methodChannel.invokeMethod("setBold", null)
        }
        ibItalic.setOnClickListener {
            setItalicStatus(!isItalicEnabled)
            methodChannel.invokeMethod("setItalic", null)
        }
        ibUnderline.setOnClickListener {
            setUnderlineStatus(!isUnderlineEnabled)
            methodChannel.invokeMethod("setUnderline", null)
        }
        ibStrikeThrough.setOnClickListener {
            setStrikeThroughStatus(!isStrikeThroughEnabled)
            methodChannel.invokeMethod("setStrikeThrough", null)
        }

        ibTextType.setOnClickListener {
            toggleTextType()
            toggleSubToolbarPlaceHolder()
        }
        ibTextStyle.setOnClickListener {
            toggleTextStyle()
            toggleSubToolbarPlaceHolder()
        }
    }

    private fun toggleTextType() {
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

        methodChannel.invokeMethod("onSubToolbarToggle", isShowTextStyle || isShowTextType)
    }

    private fun toggleTextStyle() {
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

        methodChannel.invokeMethod("onSubToolbarToggle", isShowTextStyle || isShowTextType)
    }

    private fun toggleSubToolbarPlaceHolder() {
        val isShowingSub = isShowTextStyle || isShowTextType
        if (isShowingSub) {
            toolbar.findViewById<View>(R.id.view_placeholder).visibility = View.GONE
        } else {
            toolbar.findViewById<View>(R.id.view_placeholder).visibility = View.VISIBLE
        }
    }

    private fun setHeadline1Status(isChecked: Boolean) {
        isHeadline1Enabled = isChecked
        if (isChecked) {
            ibHeadline1.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
            ibHeadline2.setBackgroundColor(Color.TRANSPARENT)
            ibHeadline3.setBackgroundColor(Color.TRANSPARENT)
            isHeadline2Enabled = false
            isHeadline3Enabled = false
        } else {
            ibHeadline1.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setHeadline2Status(isChecked: Boolean) {
        isHeadline2Enabled = isChecked
        if (isChecked) {
            ibHeadline2.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
            ibHeadline1.setBackgroundColor(Color.TRANSPARENT)
            ibHeadline3.setBackgroundColor(Color.TRANSPARENT)
            isHeadline1Enabled = false
            isHeadline3Enabled = false
        } else {
            ibHeadline2.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setHeadline3Status(isChecked: Boolean) {
        isHeadline3Enabled = isChecked
        if (isChecked) {
            ibHeadline3.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
            ibHeadline1.setBackgroundColor(Color.TRANSPARENT)
            ibHeadline2.setBackgroundColor(Color.TRANSPARENT)
            isHeadline1Enabled = false
            isHeadline2Enabled = false
        } else {
            ibHeadline3.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setListStatus(isChecked: Boolean) {
        isListEnabled = isChecked
        if (isChecked) {
            ibList.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
        } else {
            ibList.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setOrderedListStatus(isChecked: Boolean) {
        isOrderedListEnabled = isChecked
        if (isChecked) {
            ibOrderedList.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
        } else {
            ibOrderedList.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setQuoteStatus(isChecked: Boolean) {
        isQuoteEnabled = isChecked
        if (isChecked) {
            ibQuote.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
        } else {
            ibQuote.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setCodeBlockStatus(isChecked: Boolean) {
        isCodeBlockEnabled = isChecked
        if (isChecked) {
            ibCodeBlock.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
        } else {
            ibCodeBlock.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setBoldStatus(isChecked: Boolean) {
        isBoldEnabled = isChecked
        if (isChecked) {
            ibBold.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
        } else {
            ibBold.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setItalicStatus(isChecked: Boolean) {
        isItalicEnabled = isChecked
        if (isChecked) {
            ibItalic.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
        } else {
            ibItalic.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setUnderlineStatus(isChecked: Boolean) {
        isUnderlineEnabled = isChecked
        if (isChecked) {
            ibUnderline.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
        } else {
            ibUnderline.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    private fun setStrikeThroughStatus(isChecked: Boolean) {
        isStrikeThroughEnabled = isChecked
        if (isChecked) {
            ibStrikeThrough.setBackgroundResource(R.drawable.bg_toolbar_item_focused)
        } else {
            ibStrikeThrough.setBackgroundColor(Color.TRANSPARENT)
        }
    }

}
