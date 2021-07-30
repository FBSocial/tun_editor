//
//  EditorType.swift
//  tun_editor
//
//  Created by Jeffrey Wu on 2021/7/30.
//

import Foundation

enum TextType: String {
    case normal = "normal"
    case headline1 = "header1"
    case headline2 = "header2"
    case headline3 = "header3"
    case listBullet = "list-bullet"
    case listOrdered = "list-ordered"
    case quote = "blockQuote"
    case codeBlock = "code-block"
}

enum TextStyle: String {
    case bold = "bold"
    case italic = "italic"
    case underline = "underline"
    case strikeThrough = "strike"
}
