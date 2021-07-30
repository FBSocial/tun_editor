package com.tuntech.tun_editor.view

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.os.Build
import android.text.*
import android.text.style.*
import android.util.AttributeSet
import android.util.Log
import android.util.TypedValue
import android.view.inputmethod.EditorInfo
import androidx.appcompat.widget.AppCompatEditText
import com.chinalwb.are.Constants
import com.chinalwb.are.Util
import com.chinalwb.are.spans.AreHrSpan
import com.chinalwb.are.spans.AreQuoteSpan
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

        initGlobalValues()
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
        formatSelectionLines()
    }

    fun clearTextType() {
        mTextType = TEXT_TYPE_NORMAL
        formatSelectionLines()
    }

    fun setTextStyle(styleList: List<String>) {
        mTextStyleList.clear()
        mTextStyleList.addAll(styleList)
        formatSelectionCursor()
    }

    fun clearTextStyle() {
        mTextStyleList.clear()
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
                applyTextType(index, index + len, TEXT_TYPE_HEADLINE1, false)
                when (mTextType) {
                    TEXT_TYPE_HEADLINE1 -> {
                        applyTextType(index, index + len, TEXT_TYPE_HEADLINE1, mTextType == TEXT_TYPE_HEADLINE1)
                    }
                    TEXT_TYPE_HEADLINE2 -> {
                        applyTextType(index, index + len, TEXT_TYPE_HEADLINE2, mTextType == TEXT_TYPE_HEADLINE2)
                    }
                    TEXT_TYPE_HEADLINE3 -> {
                        applyTextType(index, index + len, TEXT_TYPE_HEADLINE3, mTextType == TEXT_TYPE_HEADLINE3)
                    }
                }
                applyTextType(index, index + len, TEXT_TYPE_LIST_BULLET, attr == TEXT_TYPE_LIST_BULLET)
                applyTextType(index, index + len, TEXT_TYPE_LIST_ORDERED, attr == TEXT_TYPE_LIST_ORDERED)
                applyTextType(index, index + len, TEXT_TYPE_QUOTE, attr == TEXT_TYPE_QUOTE)
                applyTextType(index, index + len, TEXT_TYPE_CODE_BLOCK, attr == TEXT_TYPE_CODE_BLOCK)
            }

            TEXT_STYLE_BOLD, TEXT_STYLE_ITALIC, TEXT_STYLE_UNDERLINE, TEXT_STYLE_STRIKE_THROUGH -> {
                applyTextStyle(index, index + len, TEXT_STYLE_BOLD, mTextStyleList.contains(
                    TEXT_STYLE_BOLD))
                applyTextStyle(index, index + len, TEXT_STYLE_ITALIC, mTextStyleList.contains(
                    TEXT_STYLE_ITALIC))
                applyTextStyle(index, index + len, TEXT_STYLE_UNDERLINE, mTextStyleList.contains(
                    TEXT_STYLE_UNDERLINE))
                applyTextStyle(index, index + len, TEXT_STYLE_STRIKE_THROUGH, mTextStyleList.contains(
                    TEXT_STYLE_STRIKE_THROUGH))
            }
            else -> {
                Log.w(TAG, "format text with missing attribute: $attr")
            }
        }
    }

    fun insertDivider() {
        val ssb = SpannableStringBuilder()
        ssb.append(Constants.CHAR_NEW_LINE)
        ssb.append(Constants.CHAR_NEW_LINE)
        ssb.append(Constants.ZERO_WIDTH_SPACE_STR)
        ssb.append(Constants.CHAR_NEW_LINE)
        ssb.setSpan(AreHrSpan(), 2, 3, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        editableText.replace(selectionStart, selectionEnd, ssb)
    }

    private fun initGlobalValues() {
        val wh = Util.getScreenWidthAndHeight(context)
        Constants.SCREEN_WIDTH = wh[0]
        Constants.SCREEN_HEIGHT = wh[1]
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
                    applyTextType(startPos, endPos, TEXT_TYPE_HEADLINE1, false)
                    when (mTextType) {
                        TEXT_TYPE_HEADLINE1 -> {
                            applyTextType(startPos, endPos, TEXT_TYPE_HEADLINE1, mTextType == TEXT_TYPE_HEADLINE1)
                        }
                        TEXT_TYPE_HEADLINE2 -> {
                            applyTextType(startPos, endPos, TEXT_TYPE_HEADLINE2, mTextType == TEXT_TYPE_HEADLINE2)
                        }
                        TEXT_TYPE_HEADLINE3 -> {
                            applyTextType(startPos, endPos, TEXT_TYPE_HEADLINE3, mTextType == TEXT_TYPE_HEADLINE3)
                        }
                    }
                    applyTextType(startPos, endPos, TEXT_TYPE_LIST_BULLET, mTextType == TEXT_TYPE_LIST_BULLET)
                    applyTextType(startPos, endPos, TEXT_TYPE_LIST_ORDERED, mTextType == TEXT_TYPE_LIST_ORDERED)
                    applyTextType(startPos, endPos, TEXT_TYPE_QUOTE, mTextType == TEXT_TYPE_QUOTE)
                    applyTextType(startPos, endPos, TEXT_TYPE_CODE_BLOCK, mTextType == TEXT_TYPE_CODE_BLOCK)

                    applyTextStyle(startPos, endPos, TEXT_STYLE_BOLD, mTextStyleList.contains(
                        TEXT_STYLE_BOLD))
                    applyTextStyle(startPos, endPos, TEXT_STYLE_ITALIC, mTextStyleList.contains(
                        TEXT_STYLE_ITALIC))
                    applyTextStyle(startPos, endPos, TEXT_STYLE_UNDERLINE, mTextStyleList.contains(
                        TEXT_STYLE_UNDERLINE))
                    applyTextStyle(startPos, endPos, TEXT_STYLE_STRIKE_THROUGH, mTextStyleList.contains(
                        TEXT_STYLE_STRIKE_THROUGH))
                }
            }
        })
    }

    private fun formatSelectionLines() {
        // Calculate the whole line's start index and end index.
        val startLine = layout.getLineForOffset(selectionStart)
        val endLine  = layout.getLineForOffset(selectionEnd)
        val startIndex = Util.getThisLineStart(this, startLine)
        var endIndex = Util.getThisLineEnd(this, endLine)
        if (endIndex > 0) {
            endIndex--
        }

        // Remove all span first.
        // removeAllSpans(startIndex, endIndex)
        applyTextType(startIndex, endIndex, TEXT_TYPE_HEADLINE1, false)
        when (mTextType) {
            TEXT_TYPE_HEADLINE1 -> {
                applyTextType(startIndex, endIndex, TEXT_TYPE_HEADLINE1, mTextType == TEXT_TYPE_HEADLINE1)
            }
            TEXT_TYPE_HEADLINE2 -> {
                applyTextType(startIndex, endIndex, TEXT_TYPE_HEADLINE2, mTextType == TEXT_TYPE_HEADLINE2)
            }
            TEXT_TYPE_HEADLINE3 -> {
                applyTextType(startIndex, endIndex, TEXT_TYPE_HEADLINE3, mTextType == TEXT_TYPE_HEADLINE3)
            }
        }
        applyTextType(startIndex, endIndex, TEXT_TYPE_LIST_BULLET, mTextType == TEXT_TYPE_LIST_BULLET)
        applyTextType(startIndex, endIndex, TEXT_TYPE_LIST_ORDERED, mTextType == TEXT_TYPE_LIST_ORDERED)
        applyTextType(startIndex, endIndex, TEXT_TYPE_QUOTE, mTextType == TEXT_TYPE_QUOTE)
        applyTextType(startIndex, endIndex, TEXT_TYPE_CODE_BLOCK, mTextType == TEXT_TYPE_CODE_BLOCK)
    }

    private fun formatSelectionCursor() {
        // removeAllSpans(selectionStart, selectionEnd)
        applyTextStyle(selectionStart, selectionEnd, TEXT_STYLE_BOLD, mTextStyleList.contains(
            TEXT_STYLE_BOLD))
        applyTextStyle(selectionStart, selectionEnd, TEXT_STYLE_ITALIC, mTextStyleList.contains(
            TEXT_STYLE_ITALIC))
        applyTextStyle(selectionStart, selectionEnd, TEXT_STYLE_UNDERLINE, mTextStyleList.contains(
            TEXT_STYLE_UNDERLINE))
        applyTextStyle(selectionStart, selectionEnd, TEXT_STYLE_STRIKE_THROUGH, mTextStyleList.contains(
            TEXT_STYLE_STRIKE_THROUGH))
    }

    private fun removeAllSpans(start: Int, end: Int) {
        // Remove all span first.
        editableText.getSpans(start, end, AbsoluteSizeSpan::class.java).forEach {
            editableText.removeSpan(it)
        }
        editableText.getSpans(start, end, ListBulletSpan::class.java).forEach {
            editableText.removeSpan(it)
        }
        editableText.getSpans(start, end, ListNumberSpan::class.java).forEach {
            editableText.removeSpan(it)
        }
        editableText.getSpans(start, end, AreQuoteSpan::class.java).forEach {
            editableText.removeSpan(it)
        }
    }

    // Apply text type to the all lines between start and end.
    private fun applyTextType(start: Int, end: Int, textType: String, isChecked: Boolean) {
        Log.d(TAG, "apply text type: $textType, $start, $end, $isChecked")

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
                applySpan(editableText, startIndex, endIndex, isChecked, {
                    return@applySpan AbsoluteSizeSpan(FONT_SIZE_HEADLINE_1, true)
                }, AbsoluteSizeSpan::class.java)
            }
            TEXT_TYPE_HEADLINE2 -> {
                applySpan(editableText, startIndex, endIndex, isChecked, {
                    return@applySpan AbsoluteSizeSpan(FONT_SIZE_HEADLINE_2, true)
                }, AbsoluteSizeSpan::class.java)
            }
            TEXT_TYPE_HEADLINE3 -> {
                applySpan(editableText, startIndex, endIndex, isChecked, {
                    return@applySpan AbsoluteSizeSpan(FONT_SIZE_HEADLINE_3, true)
                }, AbsoluteSizeSpan::class.java)
            }
            TEXT_TYPE_LIST_BULLET -> {
                applySpan(editableText, startIndex, endIndex, isChecked, {
                    return@applySpan ListBulletSpan()
                }, ListBulletSpan::class.java)
            }
            TEXT_TYPE_LIST_ORDERED -> {
                applySpan(editableText, startIndex, endIndex, isChecked, {
                    return@applySpan ListNumberSpan(1)
                }, ListNumberSpan::class.java)
            }
            TEXT_TYPE_QUOTE -> {
                applySpan(editableText, startIndex, endIndex, isChecked, {
                    return@applySpan AreQuoteSpan()
                }, AreQuoteSpan::class.java)
            }
            TEXT_TYPE_CODE_BLOCK -> {
                // TODO Code block span.
            }
        }
    }

    private fun applyTextStyle(start: Int, end: Int, textStyle: String, isChecked: Boolean) {
        Log.d(TAG, "apply text style: $textStyle, $start, $end, $isChecked")

        when (textStyle) {
            TEXT_STYLE_BOLD -> {
                // editableText.getSpans(start, end, StyleSpan::class.java).forEach {
                //     editableText.removeSpan(it)
                // }
                // val span = StyleSpan(Typeface.BOLD)
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                applySpan(editableText, start, end, isChecked, {
                    return@applySpan StyleSpan(Typeface.BOLD)
                }, StyleSpan::class.java)
            }
            TEXT_STYLE_ITALIC -> {
                // val span = StyleSpan(Typeface.ITALIC)
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                applySpan(editableText, start, end, isChecked, {
                    return@applySpan StyleSpan(Typeface.ITALIC)
                }, StyleSpan::class.java)
            }
            TEXT_STYLE_UNDERLINE -> {
                // val span = UnderlineSpan()
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                applySpan(editableText, start, end, isChecked, {
                    return@applySpan UnderlineSpan()
                }, UnderlineSpan::class.java)
            }
            TEXT_STYLE_STRIKE_THROUGH -> {
                // val span = StrikethroughSpan()
                // editableText.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
                applySpan(editableText, start, end, isChecked, {
                    return@applySpan StrikethroughSpan()
                }, StrikethroughSpan::class.java)
            }
        }
    }

    private fun <E> applySpan(editable: Editable, start: Int, end: Int, isChecked: Boolean, newSpan: () -> E, clazzE: Class<E>) {
        if (isChecked) {
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
        } else {
            //
            // User un-checks the style
            if (end > start) {
                // User inputs or user selects a range
                val spans = editable.getSpans(start, end, clazzE)
                if (spans.isNotEmpty()) {
                    val span = spans[0]
                    if (null != span) {
                        //
                        // User stops the style, and wants to show
                        // un-UNDERLINE characters
                        val ess = editable.getSpanStart(span) // ess == existing span start
                        val ese = editable.getSpanEnd(span) // ese = existing span end
                        if (start >= ese) {
                            // User inputs to the end of the existing e span
                            // End existing e span
                            editable.removeSpan(span)
                            editable.setSpan(span, ess, start - 1, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                        } else if (start == ess && end == ese) {
                            // Case 1 desc:
                            // *BBBBBB*
                            // All selected, and un-check e
                            editable.removeSpan(span)
                        } else if (start > ess && end < ese) {
                            // Case 2 desc:
                            // BB*BB*BB
                            // *BB* is selected, and un-check e
                            editable.removeSpan(span)
                            val spanLeft = newSpan()
                            editable.setSpan(spanLeft, ess, start, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                            val spanRight = newSpan()
                            editable.setSpan(spanRight, end, ese, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                        } else if (start == ess && end < ese) {
                            // Case 3 desc:
                            // *BBBB*BB
                            // *BBBB* is selected, and un-check e
                            editable.removeSpan(span)
                            editable.setSpan(newSpan(), end, ese, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                        } else if (start > ess && end == ese) {
                            // Case 4 desc:
                            // BB*BBBB*
                            // *BBBB* is selected, and un-check e
                            editable.removeSpan(span)
                            editable.setSpan(newSpan(), ess, start, Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                        }
                    }
                }
            // } else if (end == start) {
            //     //
            //     // User changes focus position
            //     // Do nothing for this case
            // } else {
            //     //
            //     // User deletes
            //     val spans = editable.getSpans(start, end, clazzE)
            //     if (spans.isNotEmpty()) {
            //         val span = spans[0]
            //         if (null != span) {
            //             val eStart = editable.getSpanStart(span)
            //             val eEnd = editable.getSpanEnd(span)
            //             if (eStart >= eEnd) {
            //                 //
            //                 // Invalid case, this will never happen.
            //             } else {
            //                 //
            //                 // Do nothing, the default behavior is to extend
            //                 // the span's area.
            //             }
            //         }
            //     }
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