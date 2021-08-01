package com.tuntech.tun_editor.view

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.util.AttributeSet
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient

@SuppressLint("SetJavaScriptEnabled")
class QuillEditor: WebView {

    companion object {
        val TAG: String = QuillEditor::class.java.name

        const val URL = "file:///android_asset/index.html"
    }

    constructor(context: Context): super(context)

    constructor(context: Context, attr: AttributeSet): super(context, attr)

    constructor(context: Context, attr: AttributeSet, defStyle: Int): super (context, attr, defStyle)

    init {
        isVerticalScrollBarEnabled = false
        isHorizontalScrollBarEnabled = false
        settings.javaScriptEnabled = true

        webChromeClient = WebChromeClient()
        webViewClient = QuillEditorWebClient()

        addJavascriptInterface(JSInterface(), "tun")

        loadUrl(URL)
    }

    fun insertDivider() {
        exec("javascript:insertDivider()")
    }

    private fun exec(command: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            evaluateJavascript(command, null)
        } else {
            loadUrl(command)
        }
    }

    class JSInterface {
        @JavascriptInterface
        fun onSelectionChanged() {
            Log.d(TAG, "on selection changed on native")
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