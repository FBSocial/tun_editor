package com.tuntech.tun_editor.view

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.core.content.ContextCompat.getSystemService

import android.view.inputmethod.InputMethodManager




@SuppressLint("SetJavaScriptEnabled", "AddJavascriptInterface")
class QuillEditor: WebView {

    companion object {
        val TAG: String = QuillEditor::class.java.name

        const val URL = "file:///android_asset/index.html"
    }

    constructor(context: Context): super(context)

    constructor(context: Context, attr: AttributeSet): super(context, attr)

    constructor(context: Context, attr: AttributeSet, defStyle: Int): super (context, attr, defStyle)

    constructor(context: Context, placeholder: String, padding: List<Int>, readOnly: Boolean,
                autoFocus: Boolean): this(context) {
        this.placeholder = placeholder
        this.readOnly = readOnly
        this.autoFocus = autoFocus
        this.padding = padding
    }

    private var placeholder: String = ""
    private var readOnly: Boolean = false
    private var autoFocus: Boolean = false
    private var padding: List<Int> = listOf()

    private var getSelectionResList: ArrayList<((Selection) -> Unit)> = ArrayList()

    private var onTextChangeListener: ((String, String) -> Unit)? = null
    private var onFocusChangedListener: ((Boolean) -> Unit)? = null

    init {
        isVerticalScrollBarEnabled = false
        isHorizontalScrollBarEnabled = false
        settings.javaScriptEnabled = true

        webChromeClient = WebChromeClient()
        webViewClient = QuillEditorWebClient(
            onPageFinished = {
                setPlaceholder(placeholder)
                setPadding(padding)
                setReadOnly(readOnly)

                if (autoFocus) {
                    focus()
                } else {
                    blur()
                }
            }
        )

        addJavascriptInterface(JSInterface(
            onGetSelectionRes = {
                for (res in getSelectionResList) {
                    res(it)
                }
                getSelectionResList.clear()
            },
            onFocusChangedListener = { hasFocus ->
                (context as Activity).runOnUiThread {
                    onFocusChangedListener?.invoke(hasFocus)
                }
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
        exec("javascript:insertImage(\"$url\", \"$alt\")")
    }

    fun focus() {
        requestFocus()
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        imm?.showSoftInput(this, 0)
        exec("javascript:focus()");
    }

    fun blur() {
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        imm?.hideSoftInputFromWindow(windowToken, 0)
        exec("javascript:blur()");
    }

    fun setOnTextChangeListener(onTextChangeListener: ((String, String) -> Unit)) {
        this.onTextChangeListener = onTextChangeListener
    }

    fun setOnFocusChangeListener(onFocusChangedListener: (Boolean) -> Unit) {
        this.onFocusChangedListener = onFocusChangedListener
    }

    private fun setPlaceholder(placeholder: String) {
        exec("javascript:setPlaceholder(\"$placeholder\")")
    }

    private fun setPadding(padding: List<Int>) {
        if (padding.size < 4) {
            Log.w(TAG, "set editor padding failed: padding size is less then 4")
            return
        }
        exec("javascript:setPadding(${padding[0]}, ${padding[1]}, ${padding[2]}, ${padding[3]})")
    }

    private fun setReadOnly(readOnly: Boolean) {
        exec("javascript:setReadOnly($readOnly)")
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
        private val onFocusChangedListener: (Boolean) -> Unit,
        private val onTextChangeListener: ((String, String) -> Unit)
    ) {
        @JavascriptInterface
        fun onSelectionChanged() {
        }

        @JavascriptInterface
        fun onFocusChanged(hasFocus: Boolean) {
            onFocusChangedListener.invoke(hasFocus)
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

    class QuillEditorWebClient(
        private val onPageFinished: () -> Unit
    ): WebViewClient() {

        override fun onPageFinished(view: WebView?, url: String?) {
            super.onPageFinished(view, url)

            if (url?.equals(URL, true) == true) {
                // Page loaded.
                onPageFinished?.invoke()
            }
        }

    }

}