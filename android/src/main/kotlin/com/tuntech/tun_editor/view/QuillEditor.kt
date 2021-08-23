package com.tuntech.tun_editor.view

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.os.Build
import android.util.AttributeSet
import android.util.Base64
import android.util.Log
import android.view.MotionEvent
import android.view.inputmethod.InputMethodManager
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.net.URLEncoder


@SuppressLint("SetJavaScriptEnabled", "AddJavascriptInterface", "ClickableViewAccessibility")
class QuillEditor: WebView {

    companion object {
        val TAG: String = QuillEditor::class.java.name

        const val URL = "file:///android_asset/index.html"
    }

    constructor(context: Context): super(context)

    constructor(context: Context, attr: AttributeSet): super(context, attr)

    constructor(context: Context, attr: AttributeSet, defStyle: Int): super (context, attr, defStyle)

    constructor(context: Context, placeholder: String, padding: List<Int>, readOnly: Boolean,
                scrollable: Boolean, autoFocus: Boolean, delta: List<*>): this(context) {
        this.placeholder = placeholder
        this.readOnly = readOnly
        this.scrollable = scrollable
        this.autoFocus = autoFocus
        this.padding = padding
        this.delta = delta
    }

    private var placeholder: String = ""
    private var readOnly: Boolean = false
    private var scrollable: Boolean = false
    private var padding: List<Int> = listOf(12, 15, 12, 15)
    private var autoFocus: Boolean = false
    private var delta: List<*> = listOf<Map<String, Any>>()

    private var onTextChangeListener: ((String, String) -> Unit)? = null
    private var onSelectionChangeListener: ((Int, Int, String) -> Unit)? = null
    private var onMentionClickListener: ((String, String) -> Unit)? = null
    private var onLinkClickListener: ((String) -> Unit)? = null
    private var onFocusChangeListener: ((Boolean) -> Unit)? = null

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
                setContents(delta)
                setScrollable(scrollable)

                if (autoFocus) {
                    focus()
                } else {
                    blur()
                }
            }
        )

        addJavascriptInterface(JSInterface(
            onTextChangeListener = { delta, oldDelta ->
                (context as Activity).runOnUiThread {
                    onTextChangeListener?.invoke(delta, oldDelta)
                }
            },
            onSelectionChangeListener = { index, length, format ->
                (context as Activity).runOnUiThread {
                    onSelectionChangeListener?.invoke(index, length, format)
                }
            },
            onMentionClickListener = { id, text ->
                (context as Activity).runOnUiThread {
                    onMentionClickListener?.invoke(id, text)
                }
            },
            onLinkClickListener = { url ->
                (context as Activity).runOnUiThread {
                    onLinkClickListener?.invoke(url)
                }
            },
            onFocusChangeListener = { hasFocus ->
                (context as Activity).runOnUiThread {
                    onFocusChangeListener?.invoke(hasFocus)
                }
            },
            onLoadImageListener = { path ->
                (context as Activity).runOnUiThread {
                    refreshImage(path)
                }
            }
        ), "tun")

        loadUrl(URL)
    }

    fun replaceText(index: Int, length: Int, data: Any,
                    attributes: Map<*, *>, newLineAfterImage: Boolean) {
        val attrJsonObject = JSONObject()
        for ((k, v) in attributes) {
            if (k is String) {
                attrJsonObject.put(k, v)
            }
        }
        if (data is Map<*, *>) {
            val dataJsonObject = JSONObject()
            for ((k, v) in data) {
                if (k is String) {
                    dataJsonObject.put(k, v)
                }
            }
            exec("javascript:replaceText($index, $length, $dataJsonObject, $attrJsonObject, $newLineAfterImage, true)")
        } else {
            exec("javascript:replaceText($index, $length, \"$data\", $attrJsonObject, $newLineAfterImage, false)")
        }
    }

    fun updateContents(delta: List<*>, source: String) {
        exec("javascript:updateContents(${JSONArray(delta)}, \"$source\")")
    }

    fun format(name: String, value: Any) {
        if (value is String) {
            exec("javascript:format(\"$name\", \"$value\")")
        } else {
            exec("javascript:format(\"$name\", $value)")
        }
    }

    fun formatText(index: Int, length: Int, name: String, value: Any?) {
        if (value is String) {
            exec("javascript:formatText($index, $length, \"$name\", \"$value\")")
        } else {
            exec("javascript:formatText($index, $length, \"$name\", $value)")
        }
    }

    fun setSelection(index: Int, length: Int) {
        exec("javascript:setSelection($index, $length)")
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

    fun setPlaceholder(placeholder: String) {
        exec("javascript:setPlaceholder(\"$placeholder\")")
    }

    fun setReadOnly(readOnly: Boolean) {
        exec("javascript:setReadOnly($readOnly)")
    }

    fun setScrollable(scrollable: Boolean) {
        if (scrollable) {
            setOnTouchListener(null)
        } else {
            setOnTouchListener { _, event -> event.action == MotionEvent.ACTION_MOVE }
        }
    }

    fun setPadding(padding: List<Int>) {
        if (padding.size < 4) {
            Log.w(TAG, "set editor padding failed: padding size is less then 4")
            return
        }
        exec("javascript:setPadding(${padding[0]}, ${padding[1]}, ${padding[2]}, ${padding[3]})")
    }

    fun setOnTextChangeListener(onTextChangeListener: ((String, String) -> Unit)?) {
        this.onTextChangeListener = onTextChangeListener
    }

    fun setOnSelectionChangeListener(onSelectionChangeListener: ((Int, Int, String) -> Unit)?) {
        this.onSelectionChangeListener = onSelectionChangeListener
    }

    fun setOnMentionClickListener(onMentionClick: ((String, String) -> Unit)?) {
        this.onMentionClickListener = onMentionClick
    }

    fun setOnLinkClickListener(onLinkClick: ((String) -> Unit)?) {
        this.onLinkClickListener = onLinkClick
    }

    fun setOnQuillFocusChangeListener(onFocusChangeListener: ((Boolean) -> Unit)?) {
        this.onFocusChangeListener = onFocusChangeListener
    }

    private fun setContents(delta: List<*>) {
        exec("javascript:setContents(${JSONArray(delta)})")
    }

    private fun refreshImage(path: String) {
        val file = File(path.replace("file://", ""))
        if (file.exists()) {
            val imageData = Base64.encodeToString(file.readBytes(), Base64.DEFAULT)
            val imageBase64 = URLEncoder.encode(imageData, "UTF-8")
            exec("javascript:refreshImage(\"$path\", \"data:image/png;base64,$imageBase64\")")
        } else {
            Log.w(TAG, "image file not found: $path")
        }
    }

    private fun exec(command: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            evaluateJavascript(command, null)
        } else {
            loadUrl(command)
        }
    }

    class JSInterface(
        private val onTextChangeListener: (String, String) -> Unit,
        private val onSelectionChangeListener: (Int, Int, String) -> Unit,
        private val onMentionClickListener: (String, String) -> Unit,
        private val onLinkClickListener: (String) -> Unit,
        private val onFocusChangeListener: (Boolean) -> Unit,
        private val onLoadImageListener: (String) -> Unit
    ) {
        @JavascriptInterface
        fun onSelectionChange(index: Int, length: Int, format: String) {
            onSelectionChangeListener(index, length, format)
        }

        @JavascriptInterface
        fun onTextChange(delta: String, oldDelta: String, source: String) {
            onTextChangeListener(delta, oldDelta)
        }

        @JavascriptInterface
        fun onMentionClick(id: String, text: String) {
            onMentionClickListener(id, text)
        }

        @JavascriptInterface
        fun onLinkClick(url: String) {
            onLinkClickListener(url)
        }

        @JavascriptInterface
        fun onFocusChange(hasFocus: Boolean) {
            onFocusChangeListener.invoke(hasFocus)
        }

        @JavascriptInterface
        fun loadImage(path: String) {
            onLoadImageListener.invoke(path)
        }
    }

    class QuillEditorWebClient(
        private val onPageFinished: () -> Unit
    ): WebViewClient() {

        override fun onPageFinished(view: WebView?, url: String?) {
            super.onPageFinished(view, url)

            if (url?.equals(URL, true) == true) {
                onPageFinished.invoke()
            }
        }

    }

}
