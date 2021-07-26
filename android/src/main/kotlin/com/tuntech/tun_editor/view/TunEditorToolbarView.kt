package com.tuntech.tun_editor.view

import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
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
    creationParams: Map<String?, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    // UI related.
    private val toolbar: View = LayoutInflater.from(context).inflate(
        R.layout.editor_toolbar, null)

    private var isShowTextType = false
    private var isShowTextStyle = false

    private val methodChannel = MethodChannel(messenger, "tun/editor/toolbar/${id}")

    init {
        toolbar.findViewById<View>(R.id.view_placeholder).visibility = View.VISIBLE
        toolbar.findViewById<LinearLayout>(R.id.ll_text_type).visibility = View.GONE
        toolbar.findViewById<LinearLayout>(R.id.ll_text_style).visibility = View.GONE

        toolbar.findViewById<ImageButton>(R.id.ib_bold).setOnClickListener {
            methodChannel.invokeMethod("setBold", null)
        }
        toolbar.findViewById<ImageButton>(R.id.ib_italic).setOnClickListener {
            methodChannel.invokeMethod("setItalic", null)
        }
        toolbar.findViewById<ImageButton>(R.id.ib_underline).setOnClickListener {
            methodChannel.invokeMethod("setUnderline", null)
        }
        toolbar.findViewById<ImageButton>(R.id.ib_strike_through).setOnClickListener {
            methodChannel.invokeMethod("setStrikeThrough", null)
        }

        toolbar.findViewById<ImageButton>(R.id.ib_headline_1).setOnClickListener {
            methodChannel.invokeMethod("setHeadline1", null)
        }
        toolbar.findViewById<ImageButton>(R.id.ib_headline_2).setOnClickListener {
            methodChannel.invokeMethod("setHeadline2", null)
        }
        toolbar.findViewById<ImageButton>(R.id.ib_headline_3).setOnClickListener {
            methodChannel.invokeMethod("setHeadline3", null)
        }
        toolbar.findViewById<ImageButton>(R.id.ib_divider).setOnClickListener {
            methodChannel.invokeMethod("insertDivider", null)
        }

        toolbar.findViewById<ImageButton>(R.id.ib_text_type).setOnClickListener {
            toggleTextType()
            toggleSubToolbarPlaceHolder()
        }
        toolbar.findViewById<ImageButton>(R.id.ib_text_style).setOnClickListener {
            toggleTextStyle()
            toggleSubToolbarPlaceHolder()
        }
//        toolbar.actionClearStyle.setOnClickListener {
//            methodChannel.invokeMethod("clearStyle", null)
//        }

        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return toolbar
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
        }
    }

    override fun dispose() {
    }

    private fun toggleTextType() {
        val isVisible = if (isShowTextType) {
            toolbar.findViewById<LinearLayout>(R.id.ll_text_type).setBackgroundColor(Color.TRANSPARENT)
            View.GONE
        } else {
            toolbar.findViewById<LinearLayout>(R.id.ll_text_type).setBackgroundResource(R.drawable.bg_toolbar)
            View.VISIBLE
        }
        // Toggle text type.
        toolbar.findViewById<LinearLayout>(R.id.ll_text_type).visibility = isVisible
        isShowTextType = !isShowTextType

        // Disabel text style.
        toolbar.findViewById<LinearLayout>(R.id.ll_text_style).visibility = View.GONE
        isShowTextStyle = false

        methodChannel.invokeMethod("onSubToolbarToggle", isShowTextStyle || isShowTextType)
    }

    private fun toggleTextStyle() {
        val isVisible = if (isShowTextStyle) {
            toolbar.findViewById<LinearLayout>(R.id.ll_text_style).setBackgroundColor(Color.TRANSPARENT)
            View.GONE
        } else {
            toolbar.findViewById<LinearLayout>(R.id.ll_text_style).setBackgroundResource(R.drawable.bg_toolbar)
            View.VISIBLE
        }
        // Toggle text style.
        toolbar.findViewById<LinearLayout>(R.id.ll_text_style).visibility = isVisible
        isShowTextStyle = !isShowTextStyle

        // Disable text type.
        toolbar.findViewById<LinearLayout>(R.id.ll_text_type).visibility = View.GONE
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

}
