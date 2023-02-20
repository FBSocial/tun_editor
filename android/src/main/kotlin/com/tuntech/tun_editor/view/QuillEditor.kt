package com.tuntech.tun_editor.view

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
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
import java.net.URLClassLoader
import java.net.URLEncoder


@SuppressLint("SetJavaScriptEnabled", "AddJavascriptInterface", "ClickableViewAccessibility")
class QuillEditor : WebView {

    companion object {
        val TAG: String = QuillEditor::class.java.name

        const val URL = "file:///android_asset/editor/index.html"
    }

    constructor(context: Context) : super(context)

    constructor(context: Context, attr: AttributeSet) : super(context, attr)

    constructor(context: Context, attr: AttributeSet, defStyle: Int) : super(
        context,
        attr,
        defStyle
    )

    constructor(
        context: Context,
        placeholder: String,
        padding: List<Int>,
        readOnly: Boolean,
        scrollable: Boolean,
        autoFocus: Boolean,
        delta: List<*>,
        fileBasePath: String,
        imageStyle: Map<String, Any>,
        videoStyle: Map<String, Any>,
        placeholderStyle: Map<String, Any>,
        enableMarkdownSyntax: Boolean
    ) : this(context) {
        this.placeholder = placeholder
        this.readOnly = readOnly
        this.scrollable = scrollable
        this.autoFocus = autoFocus
        this.padding = padding
        this.delta = delta
        this.fileBasePath = fileBasePath
        this.imageStyle = imageStyle
        this.videoStyle = videoStyle
        this.placeholderStyle = placeholderStyle
        this.enableMarkdownSyntax = enableMarkdownSyntax
    }

    private var placeholder: String = ""
    private var readOnly: Boolean = false
    private var scrollable: Boolean = false
    private var padding: List<Int> = listOf(12, 15, 12, 15)
    private var autoFocus: Boolean = false
    private var delta: List<*> = listOf<Map<String, Any>>()
    private var fileBasePath: String = ""
    private var imageStyle: Map<String, Any> = mapOf()
    private var videoStyle: Map<String, Any> = mapOf()
    private var placeholderStyle: Map<String, Any> = mapOf()
    private var enableMarkdownSyntax: Boolean = false

    private var onTextChangeListener: ((String, String) -> Unit)? = null
    private var onSelectionChangeListener: ((Int, Int, String) -> Unit)? = null
    private var onMentionClickListener: ((String, String, String) -> Unit)? = null
    private var onLinkClickListener: ((String) -> Unit)? = null
    private var onFocusChangeListener: ((Boolean) -> Unit)? = null
    private var onPageLoadedListener: (() -> Unit)? = null

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
                setScrollable(scrollable)
                setFileBasePath(fileBasePath)
                setImageStyle(imageStyle)
                setVideoStyle(videoStyle)
                setPlaceholderStyle(placeholderStyle)
                setContents(delta)
                setupMarkdownSyntax(enableMarkdownSyntax)

                // if (autoFocus) {
                //     focus()
                // } else {
                //     blur()
                // }
                onPageLoadedListener?.invoke()
            }
        )

        addJavascriptInterface(JSInterface(
            onTextChangeListener = { delta, oldDelta ->
                scanForActivity(context)?.runOnUiThread {
                    onTextChangeListener?.invoke(delta, oldDelta)
                }
            },
            onSelectionChangeListener = { index, length, format ->
                scanForActivity(context)?.runOnUiThread {
                    onSelectionChangeListener?.invoke(index, length, format)
                }
            },
            onMentionClickListener = { id, prefixChar, text ->
                scanForActivity(context)?.runOnUiThread {
                    onMentionClickListener?.invoke(id, prefixChar, text)
                }
            },
            onLinkClickListener = { url ->
                scanForActivity(context)?.runOnUiThread {
                    onLinkClickListener?.invoke(url)
                }
            },
            onFocusChangeListener = { hasFocus ->
                scanForActivity(context)?.runOnUiThread {
                    onFocusChangeListener?.invoke(hasFocus)
                }
            },
            onLoadImageListener = { filename ->
                scanForActivity(context)?.runOnUiThread {
                    refreshImage(filename)
                }
            },
            onLoadVideoThumbListener = { filename ->
                scanForActivity(context)?.runOnUiThread {
                    refreshVideoThumb(filename)
                }
            }
        ), "tun")

        loadUrl(URL)
    }


    /**
     * 修复 Context 强制转化 Activity 的问题
     */
    private fun scanForActivity(cont: Context?): Activity? {
        if (cont == null)
            return null
        else if (cont is Activity)
            return cont as Activity?
        else if (cont is ContextWrapper)
            return scanForActivity((cont as ContextWrapper).getBaseContext())
        return null
    }

    fun replaceText(
        index: Int, length: Int, data: Any, attributes: Map<*, *>,
        newLineAfterImage: Boolean, ignoreFocus: Boolean, selection: Map<*, *>
    ) {
        val attrJsonObject = JSONObject()
        for ((k, v) in attributes) {
            if (k is String) {
                attrJsonObject.put(k, v)
            }
        }
        val selectionJsonObject = JSONObject()
        for ((k, v) in selection) {
            if (k is String) {
                selectionJsonObject.put(k, v)
            }
        }
        if (data is Map<*, *>) {
            val dataJsonObject = JSONObject()
            for ((k, v) in data) {
                if (k is String) {
                    dataJsonObject.put(k, v)
                }
            }
            exec("javascript:replaceText($index, $length, $dataJsonObject, $attrJsonObject, $newLineAfterImage, true, $ignoreFocus, $selectionJsonObject)")
        } else {
            exec("javascript:replaceText($index, $length, \"$data\", $attrJsonObject, $newLineAfterImage, false, $ignoreFocus, $selectionJsonObject)")
        }
    }

    fun updateContents(delta: List<*>, source: String, ignoreFocus: Boolean, selection: Map<*, *>) {
        val selectionJsonObject = JSONObject()
        for ((k, v) in selection) {
            if (k is String) {
                selectionJsonObject.put(k, v)
            }
        }
        exec("javascript:updateContents(${JSONArray(delta)}, \"$source\", $ignoreFocus, $selectionJsonObject)")
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

    fun setSelection(index: Int, length: Int, ignoreFocus: Boolean) {
        exec("javascript:setSelection($index, $length, $ignoreFocus)")
    }

    fun focus() {
        requestFocus()
        exec("javascript:focus()");
        toggleKeyboard(true)
    }

    fun blur() {
        exec("javascript:blur()");
    }

    fun setPlaceholder(placeholder: String) {
        this.placeholder = placeholder
        exec("javascript:setPlaceholder(\"$placeholder\")")
    }

    fun setReadOnly(readOnly: Boolean) {
        this.readOnly = readOnly
        exec("javascript:setReadOnly($readOnly)")
    }

    fun setScrollable(scrollable: Boolean) {
        this.scrollable = scrollable
        if (scrollable) {
            setOnTouchListener(null)
        } else {
            setOnTouchListener { _, event -> event.action == MotionEvent.ACTION_MOVE }
        }
    }

    fun setPadding(padding: List<Int>) {
        this.padding = padding
        if (padding.size < 4) {
            Log.w(TAG, "set editor padding failed: padding size is less then 4")
            return
        }
        exec("javascript:setPadding(${padding[0]}, ${padding[1]}, ${padding[2]}, ${padding[3]})")
    }

    fun setFileBasePath(fileBasePath: String) {
        this.fileBasePath = fileBasePath
    }

    fun setImageStyle(style: Map<String, Any>) {
        imageStyle = style
        val styleObject = JSONObject()
        for ((k, v) in style) {
            styleObject.put(k, v)
        }
        exec("javascript:setImageStyle($styleObject)")
    }

    fun setVideoStyle(style: Map<String, Any>) {
        videoStyle = style
        val styleObject = JSONObject()
        for ((k, v) in style) {
            styleObject.put(k, v)
        }
        exec("javascript:setVideoStyle($styleObject)")
    }

    fun setPlaceholderStyle(style: Map<String, Any>) {
        placeholderStyle = style
        val styleObject = JSONObject()
        for ((k, v) in style) {
            styleObject.put(k, v)
        }
        exec("javascript:setPlaceholderStyle($styleObject)")
    }

    fun setOnTextChangeListener(onTextChangeListener: ((String, String) -> Unit)?) {
        this.onTextChangeListener = onTextChangeListener
    }

    fun setOnSelectionChangeListener(onSelectionChangeListener: ((Int, Int, String) -> Unit)?) {
        this.onSelectionChangeListener = onSelectionChangeListener
    }

    fun setOnMentionClickListener(onMentionClick: ((String, String, String) -> Unit)?) {
        this.onMentionClickListener = onMentionClick
    }

    fun setOnLinkClickListener(onLinkClick: ((String) -> Unit)?) {
        this.onLinkClickListener = onLinkClick
    }

    fun setOnQuillFocusChangeListener(onFocusChangeListener: ((Boolean) -> Unit)?) {
        this.onFocusChangeListener = onFocusChangeListener
    }

    fun setOnPageLoadedListener(onPageLoadedListener: (() -> Unit)?) {
        this.onPageLoadedListener = onPageLoadedListener
    }

    private fun setContents(delta: List<*>) {
        exec("javascript:setContents(${JSONArray(delta)})")
    }

    private fun setupMarkdownSyntax(enableMarkdownSyntax: Boolean) {
        exec("javascript:setupMarkdownSyntax($enableMarkdownSyntax)")
    }

    private fun refreshImage(filename: String) {
        val file = File(fileBasePath, filename)
        if (file.exists()) {
            val imageData = Base64.encodeToString(file.readBytes(), Base64.DEFAULT)
            val imageBase64 = URLEncoder.encode(imageData, "UTF-8")
            exec("javascript:refreshImage(\"$filename\", \"data:image/png;base64,$imageBase64\")")
        } else {
            Log.w(TAG, "image file not found: ${file.path}")
        }
    }

    private fun refreshVideoThumb(filename: String) {
        val file = File(fileBasePath, filename)
        if (file.exists()) {
            val imageData = Base64.encodeToString(file.readBytes(), Base64.DEFAULT)
            val imageBase64 = URLEncoder.encode(imageData, "UTF-8")
            exec("javascript:refreshVideoThumb(\"$filename\", \"data:image/png;base64,$imageBase64\")")
        } else {
            Log.w(TAG, "image file not found: ${file.path}")
        }
    }

    private fun exec(command: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            evaluateJavascript(command, null)
        } else {
            loadUrl(command)
        }
    }

    private fun toggleKeyboard(isShow: Boolean) {
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        if (isShow) {
            imm.showSoftInput(this, 0)
        } else {
            imm.hideSoftInputFromWindow(windowToken, 0)
        }
    }

    class JSInterface(
        private val onTextChangeListener: (String, String) -> Unit,
        private val onSelectionChangeListener: (Int, Int, String) -> Unit,
        private val onMentionClickListener: (String, String, String) -> Unit,
        private val onLinkClickListener: (String) -> Unit,
        private val onFocusChangeListener: (Boolean) -> Unit,
        private val onLoadImageListener: (String) -> Unit,
        private val onLoadVideoThumbListener: (String) -> Unit
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
        fun onMentionClick(id: String, prefixChar: String, text: String) {
            onMentionClickListener(id, prefixChar, text)
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
        fun loadImage(filename: String) {
            onLoadImageListener.invoke(filename)
        }

        @JavascriptInterface
        fun loadVideoThumb(filename: String) {
            onLoadVideoThumbListener.invoke(filename)
        }
    }

    class QuillEditorWebClient(
        private val onPageFinished: () -> Unit
    ) : WebViewClient() {

        override fun onPageFinished(view: WebView?, url: String?) {
            super.onPageFinished(view, url)

            if (url?.equals(URL, true) == true) {
                onPageFinished.invoke()
            }
        }

    }

}
