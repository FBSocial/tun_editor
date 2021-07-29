package com.tuntech.tun_editor.view

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import android.text.Editable
import android.text.Spannable
import android.text.TextWatcher
import android.text.style.*
import android.util.AttributeSet
import android.util.Log
import android.util.TypedValue
import android.view.inputmethod.EditorInfo
import androidx.appcompat.widget.AppCompatEditText
import com.chinalwb.are.Util
import com.chinalwb.are.spans.ListBulletSpan
import com.chinalwb.are.spans.ListNumberSpan

class Editor: AppCompatEditText {

    companion object {
        val TAG: String = Editor::class.java.name

        // Text type.
        const val TEXT_TYPE_NORMAL = "normal"
        const val TEXT_TYPE_HEADLINE1 = "header1"
        const val TEXT_TYPE_HEADLINE2 = "header2"
        const val TEXT_TYPE_HEADLINE3 = "header3"
        const val TEXT_TYPE_LIST_BULLET = "list-bullet"
        const val TEXT_TYPE_LIST_ORDERED = "list-ordered"
        const val TEXT_TYPE_QUOTE = "blockquote"
        const val TEXT_TYPE_CODE_BLOCK = "code-block"

        // Text style.
        const val TEXT_STYLE_BOLD = "bold"
        const val TEXT_STYLE_ITALIC = "italic"
        const val TEXT_STYLE_UNDERLINE = "underline"
        const val TEXT_STYLE_STRIKE_THROUGH = "strike"

        // Headline font size.
        const val FONT_SIZE_HEADLINE_1: Int = 48
        const val FONT_SIZE_HEADLINE_2: Int = 40
        const val FONT_SIZE_HEADLINE_3: Int = 32
        const val FONT_SIZE_NORMAL: Int = 18
    }

    private var onSelectionChanged: ((Int, Int) -> Unit)? = null

    private var mTextType: String = TEXT_TYPE_NORMAL
    private var mTextStyleList: ArrayList<String> = ArrayList()

    constructor(context: Context): super(context)

    constructor(context: Context, attributeSet: AttributeSet): super(context, attributeSet)

    constructor(context: Context, attributeSet: AttributeSet, defStyle: Int): super(context, attributeSet, defStyle)

    init {
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.O) {
            setLayerType(LAYER_TYPE_SOFTWARE, null)
        }
        // this.setMovementMethod(new AREMovementMethod());
        isFocusableInTouchMode = true
        setBackgroundColor(Color.WHITE)
        inputType = (EditorInfo.TYPE_CLASS_TEXT or EditorInfo.TYPE_TEXT_FLAG_MULTI_LINE
                or EditorInfo.TYPE_TEXT_FLAG_NO_SUGGESTIONS)
        var padding = 8
        padding = Util.getPixelByDp(context, padding)
        setPadding(padding, padding, padding, padding)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, FONT_SIZE_NORMAL.toFloat())

        initListener()
    }

    override fun onSelectionChanged(selStart: Int, selEnd: Int) {
        super.onSelectionChanged(selStart, selEnd)
        onSelectionChanged?.invoke(selStart, selEnd)
    }

    fun setOnSelectionChanged(onSelectionChanged: ((Int, Int) -> Unit)) {
        this.onSelectionChanged = onSelectionChanged
    }

    fun setTextType(textType: String) {
        mTextType = textType
    }

    fun clearTextType() {
        mTextType = TEXT_TYPE_NORMAL
    }

    fun setTextStyle(styleList: List<String>) {
        mTextStyleList.clear()
        mTextStyleList.addAll(styleList)
    }

    fun clearTextStyle() {
        mTextStyleList.clear()
    }

    fun formatText(attr: String, index: Int, len: Int) {
        when (attr) {
            TEXT_TYPE_NORMAL -> {
                // val span = AbsoluteSizeSpan(FONT_SIZE_NORMAL, true)
                // editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_HEADLINE1 -> {
                val span = AbsoluteSizeSpan(FONT_SIZE_HEADLINE_1, true)
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_HEADLINE2 -> {
                val span = AbsoluteSizeSpan(FONT_SIZE_HEADLINE_2, true)
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_HEADLINE3 -> {
                val span = AbsoluteSizeSpan(FONT_SIZE_HEADLINE_3, true)
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_LIST_BULLET -> {
                val span = ListBulletSpan()
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_LIST_ORDERED -> {
                val span = ListNumberSpan()
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_QUOTE -> {
                val span = QuoteSpan()
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_CODE_BLOCK -> {
                // TODO Code block span.
            }

            TEXT_STYLE_BOLD -> {
                val span = StyleSpan(Typeface.BOLD)
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_STYLE_ITALIC -> {
                val span = StyleSpan(Typeface.ITALIC)
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_STYLE_UNDERLINE-> {
                val span = UnderlineSpan()
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_STYLE_STRIKE_THROUGH -> {
                val span = StrikethroughSpan()
                editableText.setSpan(span, index, index + len, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            else -> {
                println("missing attribute: $attr")
            }
        }
    }

    private fun initListener() {
        addTextChangedListener(object: TextWatcher {

            var startPos = 0
            var endPos = 0

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                startPos = start
                endPos = startPos + count
            }

            override fun afterTextChanged(s: Editable?) {
                if (endPos > startPos) {
                    // Insert new text, apply text type and style.
                    applyTextType(startPos, endPos)
                    applyTextStyle(startPos, endPos)
                }
            }
        })
    }

    private fun applyTextType(start: Int, end: Int) {
        Log.d(TAG, "apply text type: $mTextType")
        when (mTextType) {
            TEXT_TYPE_NORMAL -> {
                // val span = AbsoluteSizeSpan(FONT_SIZE_NORMAL, true)
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_HEADLINE1 -> {
                editableText.getSpans(start, end, AbsoluteSizeSpan::class.java).forEach {
                    editableText.removeSpan(it)
                }
                val span = AbsoluteSizeSpan(FONT_SIZE_HEADLINE_1, true)
                editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_HEADLINE2 -> {
                val span = AbsoluteSizeSpan(FONT_SIZE_HEADLINE_2, true)
                editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_HEADLINE3 -> {
                val span = AbsoluteSizeSpan(FONT_SIZE_HEADLINE_3, true)
                editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_LIST_BULLET -> {
                val span = ListBulletSpan()
                editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_LIST_ORDERED -> {
                val span = ListNumberSpan()
                editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_QUOTE -> {
                val span = QuoteSpan()
                editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
            }
            TEXT_TYPE_CODE_BLOCK -> {
                // TODO Code bloc span.
            }
        }
    }

    private fun applyTextStyle(start: Int, end: Int) {
        for (style in mTextStyleList) {
            Log.d(TAG, "apply text style: $mTextStyleList")
            when (style) {
                TEXT_STYLE_BOLD -> {
                    editableText.getSpans(start, end, StyleSpan::class.java).forEach {
                        editableText.removeSpan(it)
                    }
                    val span = StyleSpan(Typeface.BOLD)
                    editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                }
                TEXT_STYLE_ITALIC -> {
                    val span = StyleSpan(Typeface.ITALIC)
                    editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                }
                TEXT_STYLE_UNDERLINE -> {
                    val span = UnderlineSpan()
                    editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                }
                TEXT_STYLE_STRIKE_THROUGH -> {
                    val span = StrikethroughSpan()
                    editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                }
            }
        }
    }

}