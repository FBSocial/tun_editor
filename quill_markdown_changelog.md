# 本文档主要记录 quill_markdown 下源码的改动内容

## 禁用 mention 样式转义 markdown

1. `src/app.js` 变更 onInlineExecute 方法
2. `src/app.js` 变更 onFullTextExecute 方法

```
class MarkdownActivity {
  onInlineExecute () {
    const selection = this.quillJS.getSelection()
    if (!selection) return
    const [line, offset] = this.quillJS.getLine(selection.index)
    const text = line.domNode.textContent
    const lineStart = selection.index - offset
    const format = this.quillJS.getFormat(lineStart)
    if (format['code-block']) {
      // if exists text in code-block, to skip.
      return
    }

    // Skip if has mention blot.
    let current = line.children.head
    while (current !== null) {
      if (current.statics.blotName === 'mention') {
        return
      }
      current = current.next
    }

    for (let match of this.matches) {
      const matchedText = typeof match.pattern === 'function' ? match.pattern(text) : text.match(match.pattern)
      if (matchedText) {
        match.action(text, selection, match.pattern, lineStart)
        return
      }
    }
  }

  async onFullTextExecute (virtualSelection) {
    let selection = virtualSelection || this.quillJS.getSelection()
    if (!selection) return false
    const [line, offset] = this.quillJS.getLine(selection.index)

    if (!line || offset < 0) return false
    const lineStart = selection.index - offset
    const format = this.quillJS.getFormat(lineStart)
    if (format['code-block']) {
      // if exists text in code-block, to skip.
      return false
    }

    // Skip if has mention blot.
    let current = line.children.head
    while (current !== null) {
      if (current.statics.blotName === 'mention') {
        return false
      }
      current = current.next
    }

    const beforeNode = this.quillJS.getLine(lineStart - 1)[0]
    const beforeLineText = beforeNode && beforeNode.domNode.textContent
    const text = line.domNode.textContent + ' '
    selection.length = selection.index++
    // remove block rule.
    if (typeof beforeLineText === 'string' && beforeLineText.length > 0 && text === ' ') {
      const releaseTag = this.fullMatches.find(e => e.name === line.domNode.tagName.toLowerCase())
      if (releaseTag && releaseTag.release) {
        releaseTag.release(selection)
        return false
      }
    }

    for (let match of this.fullMatches) {
      const matchedText = typeof match.pattern === 'function' ? match.pattern(text) : text.match(match.pattern)
      if (matchedText) {
        // eslint-disable-next-line no-return-await
        return await match.action(text, selection, match.pattern, lineStart)
      }
    }
    return false
  }
}
```
