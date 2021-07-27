package com.tuntech.tun_editor.view

import android.content.Context
import android.util.AttributeSet
import com.chinalwb.are.AREditText

class Editor : AREditText {

    private var onSelectionChanged: ((Int, Int) -> Unit)? = null

    constructor(context: Context): super(context)

    constructor(context: Context, attributeSet: AttributeSet): super(context, attributeSet)

    constructor(context: Context, attributeSet: AttributeSet, defStyle: Int): super(context, attributeSet, defStyle)

    override fun onSelectionChanged(selStart: Int, selEnd: Int) {
        super.onSelectionChanged(selStart, selEnd)
        onSelectionChanged?.invoke(selStart, selEnd)
    }

    fun setOnSelectionChanged(onSelectionChanged: ((Int, Int) -> Unit)) {
        this.onSelectionChanged = onSelectionChanged
    }

}