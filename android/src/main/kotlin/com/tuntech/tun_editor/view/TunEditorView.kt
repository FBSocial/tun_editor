package com.tuntech.tun_editor.view

import android.content.Context
import android.view.View
import com.tuntech.tun_editor.TextCons
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import android.animation.ObjectAnimator




internal class TunEditorView(
    val context: Context,
    id: Int,
    creationParams: Map<String, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        const val INVOKE_METHOD_ON_TEXT_CHANGE = "onTextChange"
        const val INVOKE_METHOD_ON_SELECTION_CHANGE = "onSelectionChange"
        const val INVOKE_METHOD_ON_MENTION_CLICK = "onMentionClick"
        const val INVOKE_METHOD_ON_LINK_CLICK = "onLinkClick"

        // Content related.
        const val HANDLE_METHOD_REPLACE_TEXT = "replaceText"
        const val HANDLE_METHOD_INSERT_MENTION = "insertMention"
        const val HANDLE_METHOD_INSERT_DIVIDER = "insertDivider"
        const val HANDLE_METHOD_INSERT_IMAGE = "insertImage"
        const val HANDLE_METHOD_INSERT_LINK = "insertLink"
        // Format related.
        const val HANDLE_METHOD_SET_TEXT_TYPE = "setTextType"
        const val HANDLE_METHOD_SET_TEXT_STYLE = "setTextStyle"
        const val HANDLE_METHOD_FORMAT = "format"
        const val HANDLE_METHOD_FORMAT_TEXT = "formatText"
        // Selection related.
        const val HANDLE_METHOD_UPDATE_SELECTION = "updateSelection"
        // Editor related.
        const val HANDLE_METHOD_FOCUS = "focus"
        const val HANDLE_METHOD_BLUR = "blur"
        const val HANDLE_SCROLL_TO = "scrollTo"
        const val HANDLE_SCROLL_TO_TOP = "scrollToTop"
        const val HANDLE_SCROLL_TO_BOTTOM = "scrollToBottom"
    }

    // View.
    private lateinit var quillEditor: QuillEditor

    // Method channel.
    private val methodChannel: MethodChannel = MethodChannel(messenger, "tun/editor/${id}")

    override fun getView(): View {
        return quillEditor
    }

    override fun dispose() {
        quillEditor.setOnSelectionChangeListener(null)
        quillEditor.setOnTextChangeListener(null)
        quillEditor.setOnMentionClickListener(null)
        quillEditor.setOnLinkClickListener(null)
        methodChannel.setMethodCallHandler(null)
    }

    init {
        var placeholder = ""
        var padding: List<Int> = listOf(12, 15, 12, 15)
        var autoFocus = false
        var readOnly = false
        var delta: List<*> = listOf<Map<String, Any>>()
        if (creationParams?.containsKey("placeholder") == true) {
            placeholder = (creationParams["placeholder"] as? String) ?: ""
        }
        if (creationParams?.containsKey("padding") == true) {
            padding = (creationParams["padding"] as? List<*>)?.map {
                return@map it as? Int ?: 0
            } ?: listOf()
        }
        if (creationParams?.containsKey("autoFocus") == true) {
            autoFocus = (creationParams["autoFocus"] as? Boolean) ?: false
        }
        if (creationParams?.containsKey("readOnly") == true) {
            readOnly = (creationParams["readOnly"] as? Boolean) ?: false
        }
        if (creationParams?.containsKey("delta") == true) {
            delta = (creationParams["delta"] as? List<*>) ?: listOf<Map<String, Any>>()
        }

        quillEditor = QuillEditor(context, placeholder, padding, readOnly, autoFocus, delta)
        quillEditor.setOnTextChangeListener { changeDelta, oldDelta ->
            val text = HashMap<String, String>()
            text["delta"] = changeDelta
            text["oldDelta"] = oldDelta
            methodChannel.invokeMethod(INVOKE_METHOD_ON_TEXT_CHANGE, text)
        }
        quillEditor.setOnSelectionChangeListener { index, length, format ->
            val args = HashMap<String, Any>()
            args["index"] = index
            args["length"] = length
            args["format"] = format
            methodChannel.invokeMethod(INVOKE_METHOD_ON_SELECTION_CHANGE, args)
        }
        quillEditor.setOnMentionClickListener { mentionId, text ->
            val args = HashMap<String, Any>()
            args["id"] = mentionId
            args["text"] = text
            methodChannel.invokeMethod(INVOKE_METHOD_ON_MENTION_CLICK, args)
        }
        quillEditor.setOnLinkClickListener { url ->
            methodChannel.invokeMethod(INVOKE_METHOD_ON_LINK_CLICK, url)
        }
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Content related.
            HANDLE_METHOD_REPLACE_TEXT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val index = args["index"] as? Int ?: return
                val len = args["len"] as? Int ?: return
                val data = args["data"] ?: return
                quillEditor.replaceText(index, len, data)
                result.success(null)
            }
            HANDLE_METHOD_INSERT_MENTION -> {
                val args = call.arguments as? Map<*, *> ?: return
                val id = args["id"] as? String ?: return
                val text = args["text"] as? String ?: return
                quillEditor.insertMention(id, text)
            }
            HANDLE_METHOD_INSERT_DIVIDER -> {
                quillEditor.insertDivider()
            }
            HANDLE_METHOD_INSERT_IMAGE -> {
                val url = call.arguments as? String ?: return
                quillEditor.insertImage(url)
            }
            HANDLE_METHOD_INSERT_LINK -> {
                val args = call.arguments as? Map<*, *> ?: return
                val text = args["text"] as? String ?: return
                val url = args["url"] as? String ?: return
                quillEditor.insertLink(text, url)
            }
            // Format related.
            HANDLE_METHOD_SET_TEXT_TYPE -> {
                when (call.arguments as? String ?: TextCons.TEXT_TYPE_NORMAL) {
                    TextCons.TEXT_TYPE_NORMAL -> {
                        quillEditor.format("header", false)
                        quillEditor.format("list", false)
                        quillEditor.format("blockquote", false)
                        quillEditor.format("code-block", false)
                    }
                    TextCons.TEXT_TYPE_HEADLINE1 -> quillEditor.format("header", 1)
                    TextCons.TEXT_TYPE_HEADLINE2 -> quillEditor.format("header", 2)
                    TextCons.TEXT_TYPE_HEADLINE3 -> quillEditor.format("header", 3)
                    TextCons.TEXT_TYPE_LIST_BULLET -> quillEditor.format("list", "bullet")
                    TextCons.TEXT_TYPE_LIST_ORDERED -> quillEditor.format("list", "ordered")
                    TextCons.TEXT_TYPE_QUOTE -> quillEditor.format("blockquote", true)
                    TextCons.TEXT_TYPE_CODE_BLOCK -> quillEditor.format("code-block", true)
                }
                result.success(null)
            }
            HANDLE_METHOD_SET_TEXT_STYLE -> {
                val textStyleList: List<String> = (call.arguments as? List<*> ?: ArrayList<String>()).map {
                    return@map it as String? ?: ""
                }
                quillEditor.format("bold", textStyleList.contains(TextCons.TEXT_STYLE_BOLD))
                quillEditor.format("italic", textStyleList.contains(TextCons.TEXT_STYLE_ITALIC))
                quillEditor.format("underline", textStyleList.contains(TextCons.TEXT_STYLE_UNDERLINE))
                quillEditor.format("strike", textStyleList.contains(TextCons.TEXT_STYLE_STRIKE_THROUGH))
                result.success(null)
            }
            HANDLE_METHOD_FORMAT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val name = args["name"] as? String ?: return
                val value = args["value"] ?: return
                quillEditor.format(name, value)
            }
            HANDLE_METHOD_FORMAT_TEXT -> {
                val args = call.arguments as? Map<*, *> ?: return
                val index = args["index"] as? Int ?: 0
                val len = args["len"] as? Int ?: 0
                val name = args["name"] as? String ?: return
                val value = args["value"]
                quillEditor.formatText(index, len, name, value)
                result.success(null)
            }
            // Selection related
            HANDLE_METHOD_UPDATE_SELECTION -> {
                val args = call.arguments as? Map<*, *> ?: return
                val selStart = args["selStart"] as? Int ?: 0
                val selEnd = args["selEnd"] as? Int ?: 0
                if (selEnd > selStart) {
                    quillEditor.setSelection(selStart, selEnd - selStart)
                } else {
                    quillEditor.setSelection(selEnd, selStart - selEnd)
                }
                result.success(null)
            }
            // Editor related.
            HANDLE_METHOD_FOCUS -> {
                quillEditor.focus()
                result.success(null)
            }
            HANDLE_METHOD_BLUR -> {
                quillEditor.blur()
                result.success(null)
            }
            HANDLE_SCROLL_TO -> {
                val offset = call.arguments as? Int ?: return
                val anim = ObjectAnimator.ofInt(
                    quillEditor, "scrollY",
                    quillEditor.scrollY, offset
                )
                anim.duration = 400
                anim.start()
                result.success(null)
            }
            HANDLE_SCROLL_TO_TOP -> {
                quillEditor.pageUp(true)
                result.success(null)
            }
            HANDLE_SCROLL_TO_BOTTOM -> {
                quillEditor.pageDown(true)
                result.success(null)
            }

            else -> {
                println("missing plugin method: ${call.method}")
                result.notImplemented()
            }
        }
    }

}
