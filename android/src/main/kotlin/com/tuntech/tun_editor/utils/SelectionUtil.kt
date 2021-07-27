package com.tuntech.tun_editor.utils

import android.graphics.Typeface
import android.text.Editable
import android.text.style.CharacterStyle
import android.text.style.QuoteSpan
import android.text.style.StrikethroughSpan
import android.text.style.StyleSpan
import com.chinalwb.are.spans.AreUnderlineSpan

object SelectionUtil {

    fun checkSelectionStyle(editable: Editable, selStart: Int, selEnd: Int): HashMap<String, Any> {
        val res = HashMap<String, Any>()
        res["selStart"] = selStart
        res["selEnd"] = selEnd

        res["isHeadline1"] = isHeadline1(editable, selStart, selEnd)
        res["isHeadline2"] = isHeadline2(editable, selStart, selEnd)
        res["isHeadline3"] = isHeadline3(editable, selStart, selEnd)
        res["isList"] = isList(editable, selStart, selEnd)
        res["isOrderedList"] = isOrderedList(editable, selStart, selEnd)
        res["isQuote"] = isQuote(editable, selStart, selEnd)
        res["isCodeBlock"] = isCodeBlock(editable, selStart, selEnd)

        res["isBold"] = isBold(editable, selStart, selEnd)
        res["isItalic"] = isItalic(editable, selStart, selEnd)
        res["isUnderline"] = isUnderline(editable, selStart, selEnd)
        res["isStrikeThrough"] = isStrikeThrough(editable, selStart, selEnd)
        return res
    }

    private fun isBold(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        var boldExists = false
        if (selStart > 0 && selStart == selEnd) {
            val styleSpans = editable.getSpans(
                selStart - 1, selStart,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is StyleSpan) {
                    if ((styleSpans[i] as StyleSpan).style == Typeface.BOLD) {
                        boldExists = true
                    }
                }
            }
        } else {
            // Selection is a range
            val styleSpans = editable.getSpans(
                selStart, selEnd,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is StyleSpan) {
                    if ((styleSpans[i] as StyleSpan).style == Typeface.BOLD) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            boldExists = true
                        }
                    } else if ((styleSpans[i] as StyleSpan).style == Typeface.BOLD_ITALIC) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            boldExists = true
                        }
                    }
                }
            }
        }
        return boldExists
    }

    private fun isItalic(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        var italicExists = false
        if (selStart > 0 && selStart == selEnd) {
            val styleSpans = editable.getSpans(
                selStart - 1, selStart,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is StyleSpan) {
                    if ((styleSpans[i] as StyleSpan).style == Typeface.ITALIC) {
                        italicExists = true
                    }
                }
            }
        } else {
            // Selection is a range
            val styleSpans = editable.getSpans(
                selStart, selEnd,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is StyleSpan) {
                    if ((styleSpans[i] as StyleSpan).style == Typeface.ITALIC) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            italicExists = true
                        }
                    } else if ((styleSpans[i] as StyleSpan).style == Typeface.BOLD_ITALIC) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            italicExists = true
                        }
                    }
                }
            }
        }
        return italicExists
    }

    private fun isUnderline(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        var underlinedExists = false

        if (selStart > 0 && selStart == selEnd) {
            val styleSpans = editable.getSpans(
                selStart - 1, selStart,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is AreUnderlineSpan) {
                    underlinedExists = true
                }
            }
        } else {
            //
            // Selection is a range
            val styleSpans = editable.getSpans(
                selStart, selEnd,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is AreUnderlineSpan) {
                    if (editable.getSpanStart(styleSpans[i]) <= selStart
                        && editable.getSpanEnd(styleSpans[i]) >= selEnd
                    ) {
                        underlinedExists = true
                    }
                }
            }
        }
        return underlinedExists
    }

    private fun isStrikeThrough(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        var strikethroughExists = false

        if (selStart > 0 && selStart == selEnd) {
            val styleSpans = editable.getSpans(
                selStart - 1, selStart,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is StrikethroughSpan) {
                    strikethroughExists = true
                }
            }
        } else {
            //
            // Selection is a range
            val styleSpans = editable.getSpans(
                selStart, selEnd,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is StrikethroughSpan) {
                    if (editable.getSpanStart(styleSpans[i]) <= selStart
                        && editable.getSpanEnd(styleSpans[i]) >= selEnd
                    ) {
                        strikethroughExists = true
                    }
                }
            }
        }
        return strikethroughExists
    }

    private fun isHeadline1(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        return false
    }

    private fun isHeadline2(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        return false
    }

    private fun isHeadline3(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        return false
    }

    private fun isList(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        return false
    }

    private fun isOrderedList(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        return false
    }

    private fun isQuote(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        var quoteExists = false

        if (selStart > 0 && selStart == selEnd) {
            val quoteSpans = editable.getSpans(
                selStart - 1, selStart,
                QuoteSpan::class.java
            )
            if (quoteSpans != null && quoteSpans.isNotEmpty()) {
                quoteExists = true
            }
        } else {
            val quoteSpans = editable.getSpans(
                selStart, selEnd,
                QuoteSpan::class.java
            )
            if (quoteSpans != null && quoteSpans.isNotEmpty()) {
                if (editable.getSpanStart(quoteSpans[0]) <= selStart
                    && editable.getSpanEnd(quoteSpans[0]) >= selEnd
                ) {
                    quoteExists = true
                }
            }
        }
        return quoteExists
    }

    private fun isCodeBlock(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        return false
    }

}