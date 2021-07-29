package com.tuntech.tun_editor.utils

import android.graphics.Typeface
import android.text.Editable
import android.text.style.*
import com.chinalwb.are.spans.AreUnderlineSpan
import com.tuntech.tun_editor.view.TunEditorView

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

        val uniqueStyle: String = when {
            res["isHeadline1"] == true -> "header1"
            res["isHeadline2"] == true -> "header1"
            res["isHeadline3"] == true -> "header1"
            res["isList"] == true -> "list-bullet"
            res["isOrderedList"] == true -> "list-ordered"
            res["isQuote"] == true -> "blockquote"
            res["isCodeBlock"] == true -> "code-block"
            res["isBold"] == true -> "bold"
            res["isItalic"] == true -> "italic"
            res["isUnderline"] == true -> "underline"
            res["isStrikeThrough"] == true -> "strike"
            else -> ""
        }
        res["style"] = uniqueStyle
        return res
    }

    fun getUniqueStyle() {
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
        var headlineExist = false
        if (selStart > 0 && selStart == selEnd) {
            val styleSpans = editable.getSpans(
                selStart - 1, selStart,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is AbsoluteSizeSpan) {
                    if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_1) {
                        headlineExist = true
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
                if (styleSpans[i] is AbsoluteSizeSpan) {
                    if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_1) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            headlineExist = true
                        }
                    } else if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_1) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            headlineExist = true
                        }
                    }
                }
            }
        }
        return headlineExist
    }

    private fun isHeadline2(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        var headlineExist = false
        if (selStart > 0 && selStart == selEnd) {
            val styleSpans = editable.getSpans(
                selStart - 1, selStart,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is AbsoluteSizeSpan) {
                    if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_1) {
                        headlineExist = true
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
                if (styleSpans[i] is AbsoluteSizeSpan) {
                    if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_2) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            headlineExist = true
                        }
                    } else if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_2) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            headlineExist = true
                        }
                    }
                }
            }
        }
        return headlineExist
    }

    private fun isHeadline3(editable: Editable, selStart: Int, selEnd: Int): Boolean {
        var headlineExist = false
        if (selStart > 0 && selStart == selEnd) {
            val styleSpans = editable.getSpans(
                selStart - 1, selStart,
                CharacterStyle::class.java
            )
            for (i in styleSpans.indices) {
                if (styleSpans[i] is AbsoluteSizeSpan) {
                    if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_3) {
                        headlineExist = true
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
                if (styleSpans[i] is AbsoluteSizeSpan) {
                    if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_3) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            headlineExist = true
                        }
                    } else if ((styleSpans[i] as AbsoluteSizeSpan).size == TunEditorView.FONT_SIZE_HEADLINE_3) {
                        if (editable.getSpanStart(styleSpans[i]) <= selStart
                            && editable.getSpanEnd(styleSpans[i]) >= selEnd
                        ) {
                            headlineExist = true
                        }
                    }
                }
            }
        }
        return headlineExist
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