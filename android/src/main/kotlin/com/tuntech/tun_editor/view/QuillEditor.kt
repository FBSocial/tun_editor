package com.tuntech.tun_editor.view

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.os.Build
import android.util.AttributeSet
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient

@SuppressLint("SetJavaScriptEnabled", "AddJavascriptInterface")
class QuillEditor: WebView {

    companion object {
        val TAG: String = QuillEditor::class.java.name

        const val URL = "file:///android_asset/index.html"
    }

    constructor(context: Context): super(context)

    constructor(context: Context, attr: AttributeSet): super(context, attr)

    constructor(context: Context, attr: AttributeSet, defStyle: Int): super (context, attr, defStyle)

    private var getSelectionResList: ArrayList<((Selection) -> Unit)> = ArrayList()

    private var onTextChangeListener: ((String, String) -> Unit)? = null

    init {
        isVerticalScrollBarEnabled = false
        isHorizontalScrollBarEnabled = false
        settings.javaScriptEnabled = true

        webChromeClient = WebChromeClient()
        webViewClient = QuillEditorWebClient()

        addJavascriptInterface(JSInterface(
            onGetSelectionRes = {
                for (res in getSelectionResList) {
                    res(it)
                }
                getSelectionResList.clear()
            },
            onTextChangeListener = { delta, oldDelta ->
                (context as Activity).runOnUiThread {
                    onTextChangeListener?.invoke(delta, oldDelta)
                }
            }
        ), "tun")

        loadUrl(URL)
    }

    fun insertDivider() {
        exec("javascript:insertDivider()")
    }

    fun format(name: String, value: Any) {
        if (value is String) {
            exec("javascript:format(\"$name\", \"$value\")")
        } else {
            exec("javascript:format(\"$name\", $value)")
        }
    }

    fun removeFormat(index: Int, length: Int) {
        exec("javascript:removeFormat($index, $length)")
    }

    fun removeCurrentFormat() {
        exec("javascript:removeCurrentFormat()")
    }

    fun getSelection(getSelectionRes: (Selection) -> Unit, focus: Boolean = true) {
        this.getSelectionResList.add(getSelectionRes)
        exec("javascript:getSelection($focus)")
    }

    fun setSelection(index: Int, length: Int) {
        exec("javascript:setSelection($index, $length)")
    }

    fun formatText(index: Int, length: Int, name: String, value: Any) {
        if (value is String) {
            exec("javascript:formatText($index, $length, $name, \"$value\")")
        } else {
            exec("javascript:formatText($index, $length, $name, $value)")
        }
    }

    fun replaceText(index: Int, length: Int, data: String, ignoreFocus: Boolean, autoAppendNewLineAfterImage: Boolean) {
        exec("javascript::replaceText($index, $length, $data, $ignoreFocus, $autoAppendNewLineAfterImage)")
    }

    fun insertImage(url: String, alt: String) {
        exec("javascript::insertImage(\"$url\", \"$alt\")")
    }

    fun setOnTextChangeListener(onTextChangeListener: ((String, String) -> Unit)) {
        this.onTextChangeListener = onTextChangeListener
    }

    private fun exec(command: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            evaluateJavascript(command, null)
        } else {
            loadUrl(command)
        }
    }

    data class Selection(
        val index: Int,
        val length: Int
    )

    class JSInterface(
        private val onGetSelectionRes: (Selection) -> Unit,
        private val onTextChangeListener: ((String, String) -> Unit)
    ) {
        @JavascriptInterface
        fun onSelectionChanged() {
            Log.d(TAG, "on selection changed on native")
        }

        @JavascriptInterface
        fun getSelectionRes(index: Int, length: Int) {
            val selection = Selection(index, length)
            onGetSelectionRes(selection)
        }

        @JavascriptInterface
        fun onTextChange(delta: String, oldDelta: String, source: String) {
            onTextChangeListener(delta, oldDelta)
        }
    }

    class QuillEditorWebClient: WebViewClient() {

        override fun onPageFinished(view: WebView?, url: String?) {
            super.onPageFinished(view, url)

            if (url?.equals(URL, true) == true) {
                // Page loaded.
            }
        }

    }

}