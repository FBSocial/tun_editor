package com.tuntech.tun_editor.view

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import android.text.Editable
import android.text.Spanned
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
        formatSelectionLines(textType)
    }

    fun clearTextType() {
        mTextType = TEXT_TYPE_NORMAL
        formatSelectionLines(TEXT_TYPE_NORMAL)
    }

    fun setTextStyle(styleList: List<String>) {
        mTextStyleList.clear()
        mTextStyleList.addAll(styleList)
    }

    fun clearTextStyle() {
        mTextStyleList.clear()
    }

    private fun formatSelectionLines(textType: String) {
        // Calculate the whole line's start index and end index.
        val startLine = layout.getLineForOffset(selectionStart)
        val endLine  = layout.getLineForOffset(selectionEnd)
        val startIndex = Util.getThisLineStart(this, startLine)
        val endIndex = Util.getThisLineEnd(this, endLine)

        // Remove all span first.
        editableText.getSpans(startIndex, endIndex, AbsoluteSizeSpan::class.java).forEach {
            editableText.removeSpan(it)
        }
        editableText.getSpans(startIndex, endIndex, ListBulletSpan::class.java).forEach {
            editableText.removeSpan(it)
        }
        editableText.getSpans(startIndex, endIndex, ListNumberSpan::class.java).forEach {
            editableText.removeSpan(it)
        }
        editableText.getSpans(startIndex, endIndex, QuoteSpan::class.java).forEach {
            editableText.removeSpan(it)
        }
        formatText(textType, startIndex, startIndex + endIndex)
    }

    fun formatText(attr: String, index: Int, len: Int) {
        when (attr) {
            TEXT_TYPE_NORMAL,
            TEXT_TYPE_HEADLINE1,
            TEXT_TYPE_HEADLINE2,
            TEXT_TYPE_HEADLINE3,
            TEXT_TYPE_LIST_BULLET,
            TEXT_TYPE_LIST_ORDERED,
            TEXT_TYPE_QUOTE,
            TEXT_TYPE_CODE_BLOCK -> {
                applyTextType(index, index + len, attr)
            }

            TEXT_STYLE_BOLD, TEXT_STYLE_ITALIC, TEXT_STYLE_UNDERLINE, TEXT_STYLE_STRIKE_THROUGH -> {
                applyTextStyle(index, index + len, attr)
            }
            else -> {
                Log.w(TAG, "format text with missing attribute: $attr")
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
                    // Insert new text, apply text type and styles.
                    applyTextType(startPos, endPos, mTextType)
                    for (style in mTextStyleList) {
                        applyTextStyle(startPos, endPos, style)
                    }
                }
            }
        })
    }

    // Apply text type to the all lines between start and end.
    private fun applyTextType(start: Int, end: Int, textType: String) {
        Log.d(TAG, "apply text type: $mTextType, $start, $end")

        // Calculate the whole line's start index and end index.
        val startLine = layout.getLineForOffset(start)
        val endLine  = layout.getLineForOffset(end)
        val startIndex = Util.getThisLineStart(this, startLine)
        val endIndex = Util.getThisLineEnd(this, endLine)
        when (textType) {
            TEXT_TYPE_NORMAL -> {
                // Do nothing in text type normal.
                // text = editableText.replace(start, end, editableText.substring(start, end))
            }
            TEXT_TYPE_HEADLINE1 -> {
                applySpan(editableText, startIndex, endIndex, {
                    return@applySpan AbsoluteSizeSpan(FONT_SIZE_HEADLINE_1, true)
                }, AbsoluteSizeSpan::class.java)
            }
            TEXT_TYPE_HEADLINE2 -> {
                applySpan(editableText, startIndex, endIndex, {
                    return@applySpan AbsoluteSizeSpan(FONT_SIZE_HEADLINE_2, true)
                }, AbsoluteSizeSpan::class.java)
            }
            TEXT_TYPE_HEADLINE3 -> {
                applySpan(editableText, startIndex, endIndex, {
                    return@applySpan AbsoluteSizeSpan(FONT_SIZE_HEADLINE_3, true)
                }, AbsoluteSizeSpan::class.java)
            }
            TEXT_TYPE_LIST_BULLET -> {
                applySpan(editableText, startIndex, endIndex, {
                    return@applySpan ListBulletSpan()
                }, ListBulletSpan::class.java)
            }
            TEXT_TYPE_LIST_ORDERED -> {
                applySpan(editableText, startIndex, endIndex, {
                    return@applySpan ListNumberSpan(1)
                }, ListNumberSpan::class.java)
            }
            TEXT_TYPE_QUOTE -> {
                applySpan(editableText, startIndex, endIndex, {
                    return@applySpan QuoteSpan()
                }, QuoteSpan::class.java)
            }
            TEXT_TYPE_CODE_BLOCK -> {
                // TODO Code block span.
            }
        }
    }

    private fun applyTextStyle(start: Int, end: Int, textStyle: String) {
        Log.d(TAG, "apply text style: $textStyle, $start, $end")

        when (textStyle) {
            TEXT_STYLE_BOLD -> {
                // editableText.getSpans(start, end, StyleSpan::class.java).forEach {
                //     editableText.removeSpan(it)
                // }
                // val span = StyleSpan(Typeface.BOLD)
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                applySpan(editableText, start, end, {
                    return@applySpan StyleSpan(Typeface.BOLD)
                }, StyleSpan::class.java)
            }
            TEXT_STYLE_ITALIC -> {
                // val span = StyleSpan(Typeface.ITALIC)
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                applySpan(editableText, start, end, {
                    return@applySpan StyleSpan(Typeface.ITALIC)
                }, StyleSpan::class.java)
            }
            TEXT_STYLE_UNDERLINE -> {
                // val span = UnderlineSpan()
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                applySpan(editableText, start, end, {
                    return@applySpan UnderlineSpan()
                }, UnderlineSpan::class.java)
            }
            TEXT_STYLE_STRIKE_THROUGH -> {
                // val span = StrikethroughSpan()
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                applySpan(editableText, start, end, {
                    return@applySpan StrikethroughSpan()
                }, StrikethroughSpan::class.java)
            }
        }
    }

    private fun <E> applySpan(editable: Editable, start: Int, end: Int, newSpan: () -> E, clazzE: Class<E>) {
        if (end > start) {
            //
            // User inputs or user selects a range
            val spans: Array<E> = editable.getSpans(start, end, clazzE)
            var existingESpan: E? = null
            if (spans.isNotEmpty()) {
                existingESpan = spans[0]
            }
            if (existingESpan == null) {
                checkAndMergeSpan(editable, start, end, newSpan, clazzE)
            } else {
                val existingESpanStart: Int = editable.getSpanStart(existingESpan)
                val existingESpanEnd: Int = editable.getSpanEnd(existingESpan)
                if (existingESpanStart <= start && existingESpanEnd >= end) {
                    // The selection is just within an existing E span
                    // Do nothing for this case
                } else {
                    checkAndMergeSpan(editable, start, end, newSpan, clazzE)
                }
            }
        } else {
            //
            // User deletes
            val spans: Array<E> = editable.getSpans(start, end, clazzE)
            if (spans.isNotEmpty()) {
                var span: E? = spans[0]
                var lastSpanStart: Int = editable.getSpanStart(span)
                for (e in spans) {
                    val lastSpanStartTmp: Int = editable.getSpanStart(e)
                    if (lastSpanStartTmp > lastSpanStart) {
                        lastSpanStart = lastSpanStartTmp
                        span = e
                    }
                }
                val eStart: Int = editable.getSpanStart(span)
                val eEnd: Int = editable.getSpanEnd(span)
                Log.d(TAG, "eSpan start == $eStart, eSpan end == $eEnd")
                if (eStart >= eEnd) {
                    editable.removeSpan(span)
                }
            }
        }
    }

    private fun <E> checkAndMergeSpan(editable: Editable, start: Int, end: Int, newSpan: () -> E, clazzE: Class<E>) {
        var leftSpan: E? = null
        val leftSpans: Array<E> = editable.getSpans(start, start, clazzE)
        if (leftSpans.isNotEmpty()) {
            leftSpan = leftSpans[0]
        }
        var rightSpan: E? = null
        val rightSpans: Array<E> = editable.getSpans(end, end, clazzE)
        if (rightSpans.isNotEmpty()) {
            rightSpan = rightSpans[0]
        }
        val leftSpanStart = editable.getSpanStart(leftSpan)
        val rightSpanEnd = editable.getSpanEnd(rightSpan)
        removeAllSpans(editable, start, end, clazzE)
        if (leftSpan != null && rightSpan != null) {
            val eSpan: E = newSpan()
            editable.setSpan(eSpan, leftSpanStart, rightSpanEnd, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        } else if (leftSpan != null && rightSpan == null) {
            val eSpan: E = newSpan()
            editable.setSpan(eSpan, leftSpanStart, end, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        } else if (leftSpan == null && rightSpan != null) {
            val eSpan: E = newSpan()
            editable.setSpan(eSpan, start, rightSpanEnd, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        } else {
            val eSpan: E = newSpan()
            editable.setSpan(eSpan, start, end, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
        }
    }

    private fun <E> removeAllSpans(editable: Editable, start: Int, end: Int, clazzE: Class<E>) {
        val allSpans: Array<E> = editable.getSpans(start, end, clazzE)
        for (span in allSpans) {
            editable.removeSpan(span)
        }
    }

}